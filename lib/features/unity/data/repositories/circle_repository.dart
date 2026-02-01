import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Circle operations
class CircleRepository {
  CircleRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _circles =>
      _firestore.collection('circles');

  /// Get members subcollection for a circle
  CollectionReference<Map<String, dynamic>> _members(String circleId) {
    return _circles.doc(circleId).collection('members');
  }

  /// Get invites collection
  CollectionReference<Map<String, dynamic>> get _invites =>
      _firestore.collection('circle_invites');

  /// Stream of user's circles
  Stream<List<Circle>> getUserCirclesStream(String userId) {
    // Query circles where user is in the memberIds array
    return _circles
        .where('memberIds', arrayContains: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Circle.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get a single circle by ID
  Stream<Circle?> getCircleStream(String circleId) {
    return _circles.doc(circleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Circle.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get a circle by ID (one-time)
  Future<Circle?> getCircle(String circleId) async {
    final doc = await _circles.doc(circleId).get();
    if (!doc.exists) return null;
    return Circle.fromFirestore(doc.data()!, doc.id);
  }

  /// Create a new circle
  Future<String> createCircle(Circle circle, CircleMember creator) async {
    final batch = _firestore.batch();

    // Create the circle with creator in memberIds
    final circleRef = _circles.doc();
    batch.set(
      circleRef,
      circle
          .copyWith(
            id: circleRef.id,
            memberIds: [creator.userId],
            memberCount: 1,
          )
          .toFirestore(),
    );

    // Add creator as owner in members subcollection
    final memberRef = _members(circleRef.id).doc(creator.userId);
    batch.set(
      memberRef,
      creator
          .copyWith(
            circleId: circleRef.id,
            role: CircleMemberRole.owner,
          )
          .toFirestore(),
    );

    await batch.commit();
    return circleRef.id;
  }

  /// Update a circle
  Future<void> updateCircle(Circle circle) async {
    await _circles.doc(circle.id).update(circle.toFirestore());
  }

  /// Delete a circle
  Future<void> deleteCircle(String circleId) async {
    // Delete all members first
    final members = await _members(circleId).get();
    final batch = _firestore.batch();

    for (final member in members.docs) {
      batch.delete(member.reference);
    }

    batch.delete(_circles.doc(circleId));
    await batch.commit();
  }

  /// Archive a circle
  Future<void> archiveCircle(String circleId) async {
    await _circles.doc(circleId).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get circle members
  Stream<List<CircleMember>> getMembersStream(String circleId) {
    return _members(circleId)
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleMember.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get a specific member
  Future<CircleMember?> getMember(String circleId, String userId) async {
    final doc = await _members(circleId).doc(userId).get();
    if (!doc.exists) return null;
    return CircleMember.fromFirestore(doc.data()!, doc.id);
  }

  /// Check if user is a member
  Future<bool> isMember(String circleId, String userId) async {
    final doc = await _members(circleId).doc(userId).get();
    return doc.exists;
  }

  /// Add a member to a circle
  Future<void> addMember(String circleId, CircleMember member) async {
    final batch = _firestore.batch();

    // Add member to subcollection
    batch.set(
      _members(circleId).doc(member.userId),
      member.copyWith(circleId: circleId).toFirestore(),
    );

    // Update circle: increment member count and add to memberIds array
    batch.update(_circles.doc(circleId), {
      'memberCount': FieldValue.increment(1),
      'memberIds': FieldValue.arrayUnion([member.userId]),
      'lastActivityAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Remove a member from a circle
  Future<void> removeMember(String circleId, String userId) async {
    final batch = _firestore.batch();

    batch.delete(_members(circleId).doc(userId));

    // Update circle: decrement member count and remove from memberIds array
    batch.update(_circles.doc(circleId), {
      'memberCount': FieldValue.increment(-1),
      'memberIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Update a member
  Future<void> updateMember(String circleId, CircleMember member) async {
    await _members(circleId).doc(member.userId).update(member.toFirestore());
  }

  /// Promote member to admin
  Future<void> promoteMember(String circleId, String userId) async {
    await _members(circleId).doc(userId).update({
      'role': CircleMemberRole.admin.name,
    });

    // Also add to circle's admin list
    await _circles.doc(circleId).update({
      'admins': FieldValue.arrayUnion([userId]),
    });
  }

  /// Demote admin to member
  Future<void> demoteMember(String circleId, String userId) async {
    await _members(circleId).doc(userId).update({
      'role': CircleMemberRole.member.name,
    });

    // Remove from circle's admin list
    await _circles.doc(circleId).update({
      'admins': FieldValue.arrayRemove([userId]),
    });
  }

  /// Discover public circles
  Stream<List<Circle>> discoverCirclesStream({
    int limit = 20,
  }) {
    return _circles
        .where('visibility', isEqualTo: CircleVisibility.public.name)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Circle.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Search circles
  Future<List<Circle>> searchCircles(String query) async {
    final queryLower = query.toLowerCase();
    final snapshot = await _circles
        .where('visibility', isEqualTo: CircleVisibility.public.name)
        .where('isArchived', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => Circle.fromFirestore(doc.data(), doc.id))
        .where((c) =>
            c.name.toLowerCase().contains(queryLower) ||
            c.tags.any((t) => t.toLowerCase().contains(queryLower)))
        .toList();
  }

  /// Get circle by invite code
  Future<Circle?> getCircleByInviteCode(String inviteCode) async {
    final snapshot = await _circles
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Circle.fromFirestore(doc.data(), doc.id);
  }

  /// Generate a new invite code for a circle
  Future<String> generateInviteCode(String circleId) async {
    final code = _generateRandomCode();
    await _circles.doc(circleId).update({
      'inviteCode': code,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return code;
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        6, (i) => chars[(random + i * 7) % chars.length]).join();
  }

  /// Create an invite
  Future<String> createInvite(CircleInvite invite) async {
    final docRef = await _invites.add(invite.toFirestore());
    return docRef.id;
  }

  /// Get pending invites for a user
  Stream<List<CircleInvite>> getPendingInvitesStream(String userId) {
    return _invites
        .where('invitedUserId', isEqualTo: userId)
        .where('status', isEqualTo: CircleInviteStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleInvite.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Accept an invite
  Future<void> acceptInvite(String inviteId, CircleMember member) async {
    final batch = _firestore.batch();

    // Update invite status
    batch.update(_invites.doc(inviteId), {
      'status': CircleInviteStatus.accepted.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Add member to circle subcollection
    batch.set(
      _members(member.circleId).doc(member.userId),
      member.toFirestore(),
    );

    // Update circle: increment member count and add to memberIds array
    batch.update(_circles.doc(member.circleId), {
      'memberCount': FieldValue.increment(1),
      'memberIds': FieldValue.arrayUnion([member.userId]),
      'lastActivityAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Decline an invite
  Future<void> declineInvite(String inviteId) async {
    await _invites.doc(inviteId).update({
      'status': CircleInviteStatus.declined.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update circle activity timestamp
  Future<void> touchCircle(String circleId) async {
    await _circles.doc(circleId).update({
      'lastActivityAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment completed challenges count
  Future<void> incrementCompletedChallenges(String circleId) async {
    await _circles.doc(circleId).update({
      'totalChallengesCompleted': FieldValue.increment(1),
    });
  }

  /// Update active challenge count
  Future<void> updateActiveChallengeCount(
    String circleId,
    int count,
  ) async {
    await _circles.doc(circleId).update({
      'activeChallengeCount': count,
    });
  }
}
