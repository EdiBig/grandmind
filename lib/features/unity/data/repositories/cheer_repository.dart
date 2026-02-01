import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Cheer operations
class CheerRepository {
  CheerRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _cheers =>
      _firestore.collection('cheers');

  /// Stream of received cheers for a user
  Stream<List<Cheer>> getReceivedCheersStream(
    String userId, {
    int limit = 50,
  }) {
    return _cheers
        .where('receiverId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of sent cheers for a user
  Stream<List<Cheer>> getSentCheersStream(
    String userId, {
    int limit = 50,
  }) {
    return _cheers
        .where('senderId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get unread cheers count
  Stream<int> getUnreadCheersCountStream(String userId) {
    return _cheers
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get unread cheers
  Stream<List<Cheer>> getUnreadCheersStream(String userId) {
    return _cheers
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Send a cheer
  Future<String> sendCheer(Cheer cheer) async {
    final docRef = await _cheers.add(cheer.toFirestore());
    return docRef.id;
  }

  /// Delete a cheer
  Future<void> deleteCheer(String cheerId) async {
    await _cheers.doc(cheerId).delete();
  }

  /// Mark a cheer as read
  Future<void> markAsRead(String cheerId) async {
    await _cheers.doc(cheerId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all cheers as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();

    final unreadCheers = await _cheers
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadCheers.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get cheers for a specific activity
  Stream<List<Cheer>> getCheersForActivityStream(String activityId) {
    return _cheers
        .where('activityId', isEqualTo: activityId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get cheers for a specific post
  Stream<List<Cheer>> getCheersForPostStream(String postId) {
    return _cheers
        .where('postId', isEqualTo: postId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Check if user has cheered a post
  Future<bool> hasUserCheeredPost(String userId, String postId) async {
    final snapshot = await _cheers
        .where('senderId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Get user's cheer for a post
  Future<Cheer?> getUserCheerForPost(String userId, String postId) async {
    final snapshot = await _cheers
        .where('senderId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Cheer.fromFirestore(doc.data(), doc.id);
  }

  /// Send cheer for activity
  Future<String> sendActivityCheer({
    required String senderId,
    required String receiverId,
    required CheerType type,
    required String activityId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) async {
    final cheer = Cheer.forActivity(
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      activityId: activityId,
      challengeId: challengeId,
      message: message,
      isAnonymous: isAnonymous,
    );
    return sendCheer(cheer);
  }

  /// Send cheer for post
  Future<String> sendPostCheer({
    required String senderId,
    required String receiverId,
    required CheerType type,
    required String postId,
    String? circleId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) async {
    final cheer = Cheer.forPost(
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      postId: postId,
      circleId: circleId,
      challengeId: challengeId,
      message: message,
      isAnonymous: isAnonymous,
    );
    return sendCheer(cheer);
  }

  /// Send encouragement cheer
  Future<String> sendEncouragementCheer({
    required String senderId,
    required String receiverId,
    required CheerType type,
    String? challengeId,
    String? circleId,
    String? message,
    bool isAnonymous = false,
  }) async {
    final cheer = Cheer.encouragement(
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      challengeId: challengeId,
      circleId: circleId,
      message: message,
      isAnonymous: isAnonymous,
    );
    return sendCheer(cheer);
  }

  /// Get cheer stats for a user
  Future<CheerStats> getCheerStats(String userId) async {
    final received = await _cheers
        .where('receiverId', isEqualTo: userId)
        .get();

    final sent = await _cheers
        .where('senderId', isEqualTo: userId)
        .get();

    // Calculate stats
    final receivedByType = <String, int>{};
    final senders = <String>{};

    for (final doc in received.docs) {
      final type = doc.data()['type'] as String?;
      final senderId = doc.data()['senderId'] as String?;
      if (type != null) {
        receivedByType[type] = (receivedByType[type] ?? 0) + 1;
      }
      if (senderId != null) {
        senders.add(senderId);
      }
    }

    final sentByType = <String, int>{};
    final receivers = <String>{};

    for (final doc in sent.docs) {
      final type = doc.data()['type'] as String?;
      final receiverId = doc.data()['receiverId'] as String?;
      if (type != null) {
        sentByType[type] = (sentByType[type] ?? 0) + 1;
      }
      if (receiverId != null) {
        receivers.add(receiverId);
      }
    }

    return CheerStats(
      totalReceived: received.docs.length,
      totalSent: sent.docs.length,
      receivedByType: receivedByType,
      sentByType: sentByType,
      uniqueSenders: senders.length,
      uniqueReceivers: receivers.length,
    );
  }

  /// Get cheers in a challenge between users
  Stream<List<Cheer>> getChallengeCheersStream(
    String challengeId, {
    int limit = 100,
  }) {
    return _cheers
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get cheers in a circle
  Stream<List<Cheer>> getCircleCheersStream(
    String circleId, {
    int limit = 100,
  }) {
    return _cheers
        .where('circleId', isEqualTo: circleId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cheer.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get recent cheers between two users
  Future<List<Cheer>> getCheersBetweenUsers(
    String userId1,
    String userId2, {
    int limit = 10,
  }) async {
    // Get cheers sent from user1 to user2
    final sent = await _cheers
        .where('senderId', isEqualTo: userId1)
        .where('receiverId', isEqualTo: userId2)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    // Get cheers sent from user2 to user1
    final received = await _cheers
        .where('senderId', isEqualTo: userId2)
        .where('receiverId', isEqualTo: userId1)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .get();

    final allCheers = [
      ...sent.docs.map((doc) => Cheer.fromFirestore(doc.data(), doc.id)),
      ...received.docs.map((doc) => Cheer.fromFirestore(doc.data(), doc.id)),
    ];

    allCheers.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return allCheers.take(limit).toList();
  }
}
