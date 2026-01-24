import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/models/challenge_progress_model.dart';
import '../../data/repositories/challenge_repository.dart';
import '../../data/services/challenge_progress_service.dart';

final challengesProvider = StreamProvider<List<ChallengeModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.getChallengesStream(activeOnly: true);
});

final userChallengeParticipantsProvider =
    StreamProvider<List<ChallengeParticipantModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.getUserChallengesStream(userId);
});

final challengeParticipantsProvider =
    StreamProvider.family<List<ChallengeParticipantModel>, String>(
  (ref, challengeId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    final repo = ref.watch(challengeRepositoryProvider);
    return repo.getChallengeParticipantsStream(challengeId);
  },
);

final challengeProvider = StreamProvider.family<ChallengeModel?, String>(
  (ref, challengeId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }
    final repo = ref.watch(challengeRepositoryProvider);
    return repo.getChallengeStream(challengeId);
  },
);

/// Provider for challenge leaderboard
final challengeLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, challengeId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final progressService = ref.watch(challengeProgressServiceProvider);
  return progressService.getLeaderboard(
    challengeId: challengeId,
    currentUserId: userId,
  );
});

/// Provider for user's progress history in a challenge
final challengeProgressHistoryProvider = FutureProvider.family<
    List<ChallengeProgressEntry>, ({String challengeId, String userId})>(
  (ref, params) async {
    final progressService = ref.watch(challengeProgressServiceProvider);
    return progressService.getProgressHistory(
      challengeId: params.challengeId,
      userId: params.userId,
    );
  },
);

/// Provider for user's milestones in a challenge
final challengeMilestonesProvider = FutureProvider.family<
    List<ChallengeMilestone>, ({String challengeId, String userId})>(
  (ref, params) async {
    final progressService = ref.watch(challengeProgressServiceProvider);
    return progressService.getMilestones(
      challengeId: params.challengeId,
      userId: params.userId,
    );
  },
);

/// Provider for daily progress summary
final dailyProgressProvider = FutureProvider.family<DailyProgressSummary,
    ({String challengeId, String userId, DateTime date})>(
  (ref, params) async {
    final progressService = ref.watch(challengeProgressServiceProvider);
    return progressService.getDailyProgress(
      challengeId: params.challengeId,
      userId: params.userId,
      date: params.date,
    );
  },
);

/// Provider for current user's participation in a challenge
final userParticipationProvider = FutureProvider.family<
    ChallengeParticipantModel?, String>((ref, challengeId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repo = ref.watch(challengeRepositoryProvider);
  return repo.getParticipant(challengeId: challengeId, userId: userId);
});

/// Notifier for recording progress
class ChallengeProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final ChallengeProgressService _progressService;

  ChallengeProgressNotifier(this._progressService)
      : super(const AsyncValue.data(null));

  Future<void> recordWorkoutProgress({
    required String challengeId,
    required String userId,
    required String workoutLogId,
    int workoutCount = 1,
    int? caloriesBurned,
    int? durationMinutes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _progressService.recordWorkoutProgress(
        challengeId: challengeId,
        userId: userId,
        workoutLogId: workoutLogId,
        workoutCount: workoutCount,
        caloriesBurned: caloriesBurned,
        durationMinutes: durationMinutes,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordHabitProgress({
    required String challengeId,
    required String userId,
    required String habitLogId,
    required String habitName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _progressService.recordHabitProgress(
        challengeId: challengeId,
        userId: userId,
        habitLogId: habitLogId,
        habitName: habitName,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> syncHealthProgress({
    required String userId,
    int? todaySteps,
    double? todayDistanceKm,
    int? todayWorkouts,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _progressService.syncProgressForUser(
        userId: userId,
        todaySteps: todaySteps,
        todayDistanceKm: todayDistanceKm,
        todayWorkouts: todayWorkouts,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final challengeProgressNotifierProvider =
    StateNotifierProvider<ChallengeProgressNotifier, AsyncValue<void>>((ref) {
  final progressService = ref.watch(challengeProgressServiceProvider);
  return ChallengeProgressNotifier(progressService);
});
