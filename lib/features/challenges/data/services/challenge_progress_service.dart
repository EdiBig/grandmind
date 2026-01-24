import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_model.dart';
import '../models/challenge_participant_model.dart';
import '../models/challenge_progress_model.dart';
import '../models/challenge_activity_model.dart';
import '../models/challenge_consent_model.dart';
import '../repositories/challenge_repository.dart';
import '../repositories/challenge_gdpr_repository.dart';

/// Service for tracking and updating challenge progress
class ChallengeProgressService {
  final FirebaseFirestore _firestore;
  final ChallengeRepository _challengeRepository;
  final ChallengeGDPRRepository _gdprRepository;

  ChallengeProgressService({
    FirebaseFirestore? firestore,
    required ChallengeRepository challengeRepository,
    required ChallengeGDPRRepository gdprRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _challengeRepository = challengeRepository,
        _gdprRepository = gdprRepository;

  static const String _progressCollection = 'challengeProgress';
  static const String _milestonesCollection = 'challengeMilestones';
  static const String _activitiesCollection = 'challengeActivities';
  static const String _participantsCollection = 'challengeParticipants';

  /// Record progress for a participant
  Future<void> recordProgress({
    required String challengeId,
    required String userId,
    required int progressValue,
    required ProgressType progressType,
    required ProgressSourceType sourceType,
    String? sourceId,
    Map<String, dynamic>? metadata,
  }) async {
    // Get participant
    final participant = await _challengeRepository.getParticipant(
      challengeId: challengeId,
      userId: userId,
    );

    if (participant == null || participant.leftAt != null) {
      throw Exception('User is not an active participant in this challenge');
    }

    // Get challenge to validate goal type
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null || !challenge.isLive) {
      throw Exception('Challenge not found or not active');
    }

    // Create progress entry
    final entry = ChallengeProgressEntry(
      id: '',
      participantId: participant.id,
      challengeId: challengeId,
      userId: userId,
      progressValue: progressValue,
      progressType: progressType,
      sourceType: sourceType,
      sourceId: sourceId,
      recordedAt: DateTime.now(),
      metadata: metadata,
    );

    // Run transaction to update progress and check milestones
    await _firestore.runTransaction((transaction) async {
      // Add progress entry
      final progressRef = _firestore.collection(_progressCollection).doc();
      transaction.set(progressRef, entry.toFirestore());

      // Update participant's total progress
      final participantRef =
          _firestore.collection(_participantsCollection).doc(participant.id);
      final newProgress = participant.currentProgress + progressValue;

      transaction.update(participantRef, {
        'currentProgress': newProgress,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    });

    // Check and award milestones (outside transaction for simplicity)
    await _checkMilestones(
      challengeId: challengeId,
      userId: userId,
      participant: participant,
      challenge: challenge,
      newProgressValue: progressValue,
    );

    // Post to activity feed if user consented
    await _postActivityIfConsented(
      challengeId: challengeId,
      userId: userId,
      activityType: ChallengeActivityType.progressLogged,
      data: {
        'progressValue': progressValue,
        'progressType': progressType.name,
        'totalProgress': participant.currentProgress + progressValue,
      },
    );
  }

  /// Record progress from a workout log
  Future<void> recordWorkoutProgress({
    required String challengeId,
    required String userId,
    required String workoutLogId,
    int workoutCount = 1,
    int? caloriesBurned,
    int? durationMinutes,
  }) async {
    await recordProgress(
      challengeId: challengeId,
      userId: userId,
      progressValue: workoutCount,
      progressType: ProgressType.workouts,
      sourceType: ProgressSourceType.workoutLog,
      sourceId: workoutLogId,
      metadata: {
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      },
    );
  }

  /// Record progress from health sync (steps, distance)
  Future<void> recordHealthSyncProgress({
    required String challengeId,
    required String userId,
    required String healthDataId,
    int? steps,
    double? distanceKm,
    int? activeMinutes,
  }) async {
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null) return;

    int progressValue = 0;
    ProgressType progressType = ProgressType.steps;

    switch (challenge.goalType) {
      case ChallengeGoalType.steps:
        progressValue = steps ?? 0;
        progressType = ProgressType.steps;
        break;
      case ChallengeGoalType.distance:
        progressValue = ((distanceKm ?? 0) * 1000).toInt(); // Convert to meters
        progressType = ProgressType.distance;
        break;
      default:
        return; // Health sync not applicable for this goal type
    }

    if (progressValue > 0) {
      await recordProgress(
        challengeId: challengeId,
        userId: userId,
        progressValue: progressValue,
        progressType: progressType,
        sourceType: ProgressSourceType.healthSync,
        sourceId: healthDataId,
        metadata: {
          if (steps != null) 'steps': steps,
          if (distanceKm != null) 'distanceKm': distanceKm,
          if (activeMinutes != null) 'activeMinutes': activeMinutes,
        },
      );
    }
  }

  /// Record progress from habit completion
  Future<void> recordHabitProgress({
    required String challengeId,
    required String userId,
    required String habitLogId,
    required String habitName,
  }) async {
    await recordProgress(
      challengeId: challengeId,
      userId: userId,
      progressValue: 1,
      progressType: ProgressType.habit,
      sourceType: ProgressSourceType.habitCompletion,
      sourceId: habitLogId,
      metadata: {
        'habitName': habitName,
      },
    );
  }

  /// Check and award milestones
  Future<void> _checkMilestones({
    required String challengeId,
    required String userId,
    required ChallengeParticipantModel participant,
    required ChallengeModel challenge,
    required int newProgressValue,
  }) async {
    final newTotal = participant.currentProgress + newProgressValue;
    final progressPercentage = (newTotal / challenge.goalTarget) * 100;
    final oldPercentage =
        (participant.currentProgress / challenge.goalTarget) * 100;

    // Check percentage milestones
    final milestoneThresholds = [25, 50, 75, 100];
    for (final threshold in milestoneThresholds) {
      if (progressPercentage >= threshold && oldPercentage < threshold) {
        await _awardMilestone(
          challengeId: challengeId,
          userId: userId,
          milestoneType: threshold == 100
              ? MilestoneType.goalCompleted
              : MilestoneType.progressPercentage,
          threshold: threshold,
        );
      }
    }

    // Check if this is first activity
    if (participant.currentProgress == 0 && newProgressValue > 0) {
      await _awardMilestone(
        challengeId: challengeId,
        userId: userId,
        milestoneType: MilestoneType.firstActivity,
        threshold: 1,
      );
    }
  }

  /// Award a milestone to a user
  Future<void> _awardMilestone({
    required String challengeId,
    required String userId,
    required MilestoneType milestoneType,
    required int threshold,
  }) async {
    // Check if milestone already exists
    final existing = await _firestore
        .collection(_milestonesCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .where('milestoneType', isEqualTo: milestoneType.name)
        .where('threshold', isEqualTo: threshold)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already awarded

    final milestone = ChallengeMilestone(
      id: '',
      challengeId: challengeId,
      userId: userId,
      milestoneType: milestoneType,
      threshold: threshold,
      achievedAt: DateTime.now(),
    );

    await _firestore.collection(_milestonesCollection).add(milestone.toFirestore());

    // Post milestone to activity feed
    final activityType = milestoneType == MilestoneType.goalCompleted
        ? ChallengeActivityType.goalCompleted
        : ChallengeActivityType.milestoneReached;

    await _postActivityIfConsented(
      challengeId: challengeId,
      userId: userId,
      activityType: activityType,
      data: {
        'milestoneType': milestoneType.name,
        'threshold': threshold,
      },
    );
  }

  /// Post activity to feed if user has consented
  Future<void> _postActivityIfConsented({
    required String challengeId,
    required String userId,
    required ChallengeActivityType activityType,
    Map<String, dynamic>? data,
  }) async {
    // Check consent
    final consent = await _gdprRepository.getUserConsent(userId);
    final hasActivityConsent =
        consent?.hasConsent(ConsentType.activityDataSharing) ?? false;

    // Get user display info
    final participant = await _challengeRepository.getParticipant(
      challengeId: challengeId,
      userId: userId,
    );

    final activity = ChallengeActivityBuilder()
        .challengeId(challengeId)
        .userId(userId)
        .activityType(activityType)
        .visibility(
          hasActivityConsent
              ? ActivityVisibility.participants
              : ActivityVisibility.private,
        )
        .userInfo(
          displayName: participant?.displayName ?? 'Anonymous',
          consentedToSharing: hasActivityConsent,
        )
        .data(data ?? {})
        .description(_getActivityDescription(activityType, data))
        .build();

    await _firestore
        .collection(_activitiesCollection)
        .add(activity.toFirestore());
  }

  String _getActivityDescription(
    ChallengeActivityType type,
    Map<String, dynamic>? data,
  ) {
    switch (type) {
      case ChallengeActivityType.progressLogged:
        final value = data?['progressValue'] ?? 0;
        final progressType = data?['progressType'] ?? 'progress';
        return 'Logged $value $progressType';
      case ChallengeActivityType.milestoneReached:
        final threshold = data?['threshold'] ?? 0;
        return 'Reached $threshold% of goal';
      case ChallengeActivityType.goalCompleted:
        return 'Completed the challenge goal!';
      case ChallengeActivityType.personalBest:
        return 'Achieved a personal best!';
      default:
        return 'Made progress';
    }
  }

  /// Get progress history for a participant
  Future<List<ChallengeProgressEntry>> getProgressHistory({
    required String challengeId,
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection(_progressCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .orderBy('recordedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeProgressEntry.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get milestones for a participant
  Future<List<ChallengeMilestone>> getMilestones({
    required String challengeId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(_milestonesCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .orderBy('achievedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeMilestone.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get leaderboard for a challenge
  Future<List<LeaderboardEntry>> getLeaderboard({
    required String challengeId,
    required String currentUserId,
    int limit = 50,
  }) async {
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null) return [];

    final snapshot = await _firestore
        .collection(_participantsCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('leftAt', isNull: true)
        .orderBy('currentProgress', descending: true)
        .limit(limit)
        .get();

    final entries = <LeaderboardEntry>[];
    var rank = 0;

    for (final doc in snapshot.docs) {
      rank++;
      final participant =
          ChallengeParticipantModel.fromFirestore(doc.data(), doc.id);

      // Check if user consented to rankings
      final consent = await _gdprRepository.getUserConsent(participant.userId);
      final showInRankings =
          participant.optInRankings &&
          (consent?.hasConsent(ConsentType.publicRankings) ?? false);

      if (!showInRankings && participant.userId != currentUserId) {
        // Hide from leaderboard but maintain rank count
        continue;
      }

      entries.add(LeaderboardEntry(
        rank: rank,
        participantId: participant.id,
        challengeId: challengeId,
        userId: participant.userId,
        displayName: showInRankings || participant.userId == currentUserId
            ? participant.displayName
            : 'Anonymous',
        currentProgress: participant.currentProgress,
        progressPercentage:
            (participant.currentProgress / challenge.goalTarget) * 100,
        lastActivityAt: participant.lastActivityAt,
        isCurrentUser: participant.userId == currentUserId,
      ));
    }

    return entries;
  }

  /// Get daily progress summary
  Future<DailyProgressSummary> getDailyProgress({
    required String challengeId,
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final progressSnapshot = await _firestore
        .collection(_progressCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .where('recordedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('recordedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final milestoneSnapshot = await _firestore
        .collection(_milestonesCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .where('achievedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('achievedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final entries = progressSnapshot.docs
        .map((doc) => ChallengeProgressEntry.fromFirestore(doc.data(), doc.id))
        .toList();

    final milestones = milestoneSnapshot.docs
        .map((doc) => ChallengeMilestone.fromFirestore(doc.data(), doc.id))
        .toList();

    final totalProgress =
        entries.fold<int>(0, (acc, entry) => acc + entry.progressValue);

    return DailyProgressSummary(
      date: date,
      totalProgress: totalProgress,
      entries: entries,
      milestoneAchieved: milestones,
    );
  }

  /// Sync progress from external sources for all active challenges
  Future<void> syncProgressForUser({
    required String userId,
    int? todaySteps,
    double? todayDistanceKm,
    int? todayWorkouts,
  }) async {
    // Get user's active challenge participations
    final participations = await _firestore
        .collection(_participantsCollection)
        .where('userId', isEqualTo: userId)
        .where('leftAt', isNull: true)
        .get();

    for (final doc in participations.docs) {
      final participation =
          ChallengeParticipantModel.fromFirestore(doc.data(), doc.id);
      final challenge =
          await _challengeRepository.getChallenge(participation.challengeId);

      if (challenge == null || !challenge.isLive) continue;

      // Record appropriate progress based on challenge goal type
      switch (challenge.goalType) {
        case ChallengeGoalType.steps:
          if (todaySteps != null && todaySteps > 0) {
            await recordHealthSyncProgress(
              challengeId: challenge.id,
              userId: userId,
              healthDataId: 'sync_${DateTime.now().toIso8601String()}',
              steps: todaySteps,
            );
          }
          break;
        case ChallengeGoalType.distance:
          if (todayDistanceKm != null && todayDistanceKm > 0) {
            await recordHealthSyncProgress(
              challengeId: challenge.id,
              userId: userId,
              healthDataId: 'sync_${DateTime.now().toIso8601String()}',
              distanceKm: todayDistanceKm,
            );
          }
          break;
        case ChallengeGoalType.workouts:
          if (todayWorkouts != null && todayWorkouts > 0) {
            await recordWorkoutProgress(
              challengeId: challenge.id,
              userId: userId,
              workoutLogId: 'sync_${DateTime.now().toIso8601String()}',
              workoutCount: todayWorkouts,
            );
          }
          break;
        case ChallengeGoalType.habit:
          // Habits are synced via habit completion events
          break;
      }
    }
  }
}

/// Provider for challenge progress service
final challengeProgressServiceProvider = Provider<ChallengeProgressService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final gdprRepository = ref.watch(challengeGDPRRepositoryProvider);
  return ChallengeProgressService(
    challengeRepository: challengeRepository,
    gdprRepository: gdprRepository,
  );
});
