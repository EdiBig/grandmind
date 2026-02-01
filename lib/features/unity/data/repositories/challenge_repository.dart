import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Unity Challenge operations
class UnityChallengeRepository {
  UnityChallengeRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _challenges =>
      _firestore.collection('challenges');

  /// Stream of active challenges
  Stream<List<Challenge>> getActiveChallengesStream() {
    return _challenges
        .where('status', isEqualTo: ChallengeStatus.active.name)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of featured challenges
  Stream<List<Challenge>> getFeaturedChallengesStream() {
    return _challenges
        .where('isFeatured', isEqualTo: true)
        .where('status', whereIn: [
          ChallengeStatus.active.name,
          ChallengeStatus.upcoming.name,
        ])
        .orderBy('startDate')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of upcoming challenges
  Stream<List<Challenge>> getUpcomingChallengesStream() {
    return _challenges
        .where('status', isEqualTo: ChallengeStatus.upcoming.name)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get a single challenge by ID (stream)
  Stream<Challenge?> getChallengeStream(String challengeId) {
    return _challenges.doc(challengeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Challenge.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get a single challenge by ID (one-time)
  Future<Challenge?> getChallenge(String challengeId) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) return null;
    return Challenge.fromFirestore(doc.data()!, doc.id);
  }

  /// Create a new challenge
  Future<String> createChallenge(Challenge challenge) async {
    final docRef = await _challenges.add(challenge.toFirestore());
    return docRef.id;
  }

  /// Update an existing challenge
  Future<void> updateChallenge(Challenge challenge) async {
    await _challenges.doc(challenge.id).update(challenge.toFirestore());
  }

  /// Delete a challenge
  Future<void> deleteChallenge(String challengeId) async {
    await _challenges.doc(challengeId).delete();
  }

  /// Increment participant count
  Future<void> incrementParticipants(String challengeId) async {
    await _challenges.doc(challengeId).update({
      'participantCount': FieldValue.increment(1),
    });
  }

  /// Decrement participant count
  Future<void> decrementParticipants(String challengeId) async {
    await _challenges.doc(challengeId).update({
      'participantCount': FieldValue.increment(-1),
    });
  }

  /// Search challenges by name or tags
  Future<List<Challenge>> searchChallenges(String query) async {
    // Note: Firestore doesn't support full-text search natively
    // This is a simple prefix search; consider Algolia/Typesense for production
    final queryLower = query.toLowerCase();
    final snapshot = await _challenges
        .where('status', whereIn: [
          ChallengeStatus.active.name,
          ChallengeStatus.upcoming.name,
        ])
        .get();

    return snapshot.docs
        .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
        .where((c) =>
            c.name.toLowerCase().contains(queryLower) ||
            c.tags.any((t) => t.toLowerCase().contains(queryLower)))
        .toList();
  }

  /// Get challenges by category
  Stream<List<Challenge>> getChallengesByCategoryStream(String category) {
    return _challenges
        .where('category', isEqualTo: category)
        .where('status', whereIn: [
          ChallengeStatus.active.name,
          ChallengeStatus.upcoming.name,
        ])
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get challenges for a specific circle
  Stream<List<Challenge>> getCircleChallengesStream(String circleId) {
    return _challenges
        .where('circleId', isEqualTo: circleId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get challenges created by a user
  Stream<List<Challenge>> getUserCreatedChallengesStream(String userId) {
    return _challenges
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Update challenge status
  Future<void> updateChallengeStatus(
    String challengeId,
    ChallengeStatus status,
  ) async {
    await _challenges.doc(challengeId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Batch update challenge statuses (for scheduled jobs)
  Future<void> activatePendingChallenges() async {
    final now = Timestamp.now();
    final batch = _firestore.batch();

    final pendingChallenges = await _challenges
        .where('status', isEqualTo: ChallengeStatus.upcoming.name)
        .where('startDate', isLessThanOrEqualTo: now)
        .get();

    for (final doc in pendingChallenges.docs) {
      batch.update(doc.reference, {
        'status': ChallengeStatus.active.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Complete ended challenges
  Future<void> completeEndedChallenges() async {
    final now = Timestamp.now();
    final batch = _firestore.batch();

    final activeChallenges = await _challenges
        .where('status', isEqualTo: ChallengeStatus.active.name)
        .where('endDate', isLessThan: now)
        .get();

    for (final doc in activeChallenges.docs) {
      batch.update(doc.reference, {
        'status': ChallengeStatus.completed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get milestones for a challenge
  Future<List<Milestone>> getMilestones(String challengeId) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) return [];

    final data = doc.data()!;
    final milestones = data['milestones'] as List<dynamic>?;
    if (milestones == null) return [];

    return milestones.asMap().entries.map((e) {
      return Milestone.fromFirestore(
        e.value as Map<String, dynamic>,
        e.key.toString(),
      );
    }).toList();
  }

  /// Update milestones for a challenge
  Future<void> updateMilestones(
    String challengeId,
    List<Milestone> milestones,
  ) async {
    await _challenges.doc(challengeId).update({
      'milestones': milestones.map((m) => m.toFirestore()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
