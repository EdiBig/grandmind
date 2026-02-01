import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Challenge Participation operations
class ParticipationRepository {
  ParticipationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _participations =>
      _firestore.collection('challenge_participations');

  /// Get daily progress subcollection for a participation
  CollectionReference<Map<String, dynamic>> _dailyProgress(
      String participationId) {
    return _participations.doc(participationId).collection('daily_progress');
  }

  /// Stream of user's participations
  Stream<List<ChallengeParticipation>> getUserParticipationsStream(
    String userId,
  ) {
    return _participations
        .where('userId', isEqualTo: userId)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeParticipation.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of user's active participations
  Stream<List<ChallengeParticipation>> getActiveParticipationsStream(
    String userId,
  ) {
    return _participations
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: ParticipationStatus.active.name)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeParticipation.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get a single participation by ID
  Stream<ChallengeParticipation?> getParticipationStream(
      String participationId) {
    return _participations.doc(participationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChallengeParticipation.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get participation by ID (one-time)
  Future<ChallengeParticipation?> getParticipation(
      String participationId) async {
    final doc = await _participations.doc(participationId).get();
    if (!doc.exists) return null;
    return ChallengeParticipation.fromFirestore(doc.data()!, doc.id);
  }

  /// Find participation by user and challenge
  Future<ChallengeParticipation?> findByUserAndChallenge(
    String userId,
    String challengeId,
  ) async {
    final snapshot = await _participations
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return ChallengeParticipation.fromFirestore(doc.data(), doc.id);
  }

  /// Create a new participation
  Future<String> createParticipation(
      ChallengeParticipation participation) async {
    final docRef = await _participations.add(participation.toFirestore());
    return docRef.id;
  }

  /// Update a participation
  Future<void> updateParticipation(
      ChallengeParticipation participation) async {
    await _participations
        .doc(participation.id)
        .update(participation.toFirestore());
  }

  /// Delete a participation
  Future<void> deleteParticipation(String participationId) async {
    await _participations.doc(participationId).delete();
  }

  /// Record daily progress
  Future<void> recordDailyProgress(
    String participationId,
    DailyProgress progress,
  ) async {
    await _dailyProgress(participationId)
        .doc(progress.dateKey)
        .set(progress.toFirestore());

    // Update participation totals
    await _participations.doc(participationId).update({
      'currentProgress': FieldValue.increment(progress.effectiveValue),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'totalActiveDays': FieldValue.increment(progress.isRestDay ? 0 : 1),
    });
  }

  /// Get daily progress for a date range
  Future<List<DailyProgress>> getDailyProgress(
    String participationId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _dailyProgress(participationId);

    if (startDate != null) {
      final startKey =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      query = query.where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey);
    }

    if (endDate != null) {
      final endKey =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      query = query.where(FieldPath.documentId, isLessThanOrEqualTo: endKey);
    }

    final snapshot = await query.orderBy(FieldPath.documentId).get();
    return snapshot.docs
        .map((doc) => DailyProgress.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get daily progress stream
  Stream<List<DailyProgress>> getDailyProgressStream(
    String participationId,
  ) {
    return _dailyProgress(participationId)
        .orderBy(FieldPath.documentId, descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyProgress.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get progress for a specific date
  Future<DailyProgress?> getDailyProgressForDate(
    String participationId,
    DateTime date,
  ) async {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final doc = await _dailyProgress(participationId).doc(dateKey).get();
    if (!doc.exists) return null;
    return DailyProgress.fromFirestore(doc.data()!, dateKey);
  }

  /// Count active participants for a challenge
  Future<int> countActiveParticipants(String challengeId) async {
    final snapshot = await _participations
        .where('challengeId', isEqualTo: challengeId)
        .where('status', isEqualTo: ParticipationStatus.active.name)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get challenge participants (for leaderboard)
  Stream<List<ChallengeParticipation>> getChallengeParticipantsStream(
    String challengeId, {
    bool activeOnly = true,
    bool rankingsOnly = false,
  }) {
    Query<Map<String, dynamic>> query =
        _participations.where('challengeId', isEqualTo: challengeId);

    if (activeOnly) {
      query = query.where('status', isEqualTo: ParticipationStatus.active.name);
    }

    if (rankingsOnly) {
      query = query.where('showInRankings', isEqualTo: true);
    }

    return query
        .orderBy('currentProgress', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeParticipation.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Update participation status
  Future<void> updateStatus(
    String participationId,
    ParticipationStatus status,
  ) async {
    final updates = <String, dynamic>{
      'status': status.name,
    };

    if (status == ParticipationStatus.completed) {
      updates['completedAt'] = FieldValue.serverTimestamp();
      updates['percentComplete'] = 100;
    }

    await _participations.doc(participationId).update(updates);
  }

  /// Record a rest day
  Future<void> recordRestDay(
    String participationId,
    RestDay restDay,
  ) async {
    // Create daily progress entry for rest day
    final progress = DailyProgress.restDay(
      date: restDay.date,
      reason: restDay.reason,
      note: restDay.note,
    );

    await _dailyProgress(participationId)
        .doc(progress.dateKey)
        .set(progress.toFirestore());

    // Update rest day count
    await _participations.doc(participationId).update({
      'restDaysUsed': FieldValue.increment(1),
      'lastActivityAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update streak
  Future<void> updateStreak(
    String participationId, {
    required int currentStreak,
    int? longestStreak,
  }) async {
    final updates = <String, dynamic>{
      'currentStreak': currentStreak,
    };

    if (longestStreak != null) {
      updates['longestStreak'] = longestStreak;
    }

    await _participations.doc(participationId).update(updates);
  }

  /// Increment cheers received
  Future<void> incrementCheersReceived(String participationId) async {
    await _participations.doc(participationId).update({
      'cheersReceived': FieldValue.increment(1),
    });
  }

  /// Increment cheers sent
  Future<void> incrementCheersSent(String participationId) async {
    await _participations.doc(participationId).update({
      'cheersSent': FieldValue.increment(1),
    });
  }

  /// Unlock a milestone
  Future<void> unlockMilestone(
    String participationId,
    String milestoneId,
  ) async {
    await _participations.doc(participationId).update({
      'milestonesUnlocked': FieldValue.arrayUnion([milestoneId]),
    });
  }

  /// Get weekly rest days for a participation
  Future<List<RestDay>> getWeeklyRestDays(
    String participationId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final progress = await getDailyProgress(
      participationId,
      startDate: weekStart,
      endDate: weekEnd,
    );

    // Convert rest day progress entries to RestDay objects
    return progress
        .where((p) => p.isRestDay)
        .map((p) => RestDay(
              id: p.dateKey,
              userId: '', // Not stored in daily progress
              date: p.date,
              reason: p.restDayReason ?? RestDayReason.other,
              note: p.note,
            ))
        .toList();
  }

  /// Batch update progress percentage for all participants
  Future<void> recalculateProgress(
    String challengeId,
    double target,
  ) async {
    final batch = _firestore.batch();

    final participants = await _participations
        .where('challengeId', isEqualTo: challengeId)
        .get();

    for (final doc in participants.docs) {
      final data = doc.data();
      final currentProgress = (data['currentProgress'] as num?)?.toDouble() ?? 0;
      final percentComplete =
          target > 0 ? (currentProgress / target * 100).clamp(0, 100) : 0;

      batch.update(doc.reference, {
        'percentComplete': percentComplete,
      });
    }

    await batch.commit();
  }
}
