import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/services/services.dart';

/// Repository providers
final unityChallengeRepositoryProvider = Provider<UnityChallengeRepository>((ref) {
  return UnityChallengeRepository();
});

final participationRepositoryProvider = Provider<ParticipationRepository>((ref) {
  return ParticipationRepository();
});

/// Service providers
final challengeProgressServiceProvider = Provider<ChallengeProgressService>((ref) {
  final participationRepo = ref.watch(participationRepositoryProvider);
  final challengeRepo = ref.watch(unityChallengeRepositoryProvider);
  return ChallengeProgressService(
    participationRepository: participationRepo,
    challengeRepository: challengeRepo,
  );
});

final adaptiveChallengeServiceProvider = Provider<AdaptiveChallengeService>((ref) {
  return AdaptiveChallengeService();
});

/// Stream of active challenges
final activeChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final repo = ref.watch(unityChallengeRepositoryProvider);
  return repo.getActiveChallengesStream();
});

/// Stream of featured challenges
final featuredChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final repo = ref.watch(unityChallengeRepositoryProvider);
  return repo.getFeaturedChallengesStream();
});

/// Stream of upcoming challenges
final upcomingChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final repo = ref.watch(unityChallengeRepositoryProvider);
  return repo.getUpcomingChallengesStream();
});

/// Challenge by ID
final challengeByIdProvider =
    StreamProvider.family<Challenge?, String>((ref, challengeId) {
  final repo = ref.watch(unityChallengeRepositoryProvider);
  return repo.getChallengeStream(challengeId);
});

/// User's participations
final userParticipationsProvider =
    StreamProvider<List<ChallengeParticipation>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(participationRepositoryProvider);
  return repo.getUserParticipationsStream(userId);
});

/// User's active participations
final activeParticipationsProvider =
    StreamProvider<List<ChallengeParticipation>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(participationRepositoryProvider);
  return repo.getActiveParticipationsStream(userId);
});

/// Participation by ID
final participationByIdProvider =
    StreamProvider.family<ChallengeParticipation?, String>(
        (ref, participationId) {
  final repo = ref.watch(participationRepositoryProvider);
  return repo.getParticipationStream(participationId);
});

/// User's participation in a specific challenge
final userChallengeParticipationProvider =
    FutureProvider.family<ChallengeParticipation?, String>(
        (ref, challengeId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repo = ref.watch(participationRepositoryProvider);
  return repo.findByUserAndChallenge(userId, challengeId);
});

/// Daily progress for a participation
final dailyProgressProvider = StreamProvider.family<List<DailyProgress>, String>(
    (ref, participationId) {
  final repo = ref.watch(participationRepositoryProvider);
  return repo.getDailyProgressStream(participationId);
});

/// Challenge participants
final challengeParticipantsProvider =
    StreamProvider.family<List<ChallengeParticipation>, String>(
        (ref, challengeId) {
  final repo = ref.watch(participationRepositoryProvider);
  return repo.getChallengeParticipantsStream(challengeId);
});

/// Join challenge notifier
class JoinChallengeNotifier extends StateNotifier<AsyncValue<String?>> {
  JoinChallengeNotifier(this._participationRepo, this._challengeRepo)
      : super(const AsyncValue.data(null));

  final ParticipationRepository _participationRepo;
  final UnityChallengeRepository _challengeRepo;

  Future<void> joinChallenge({
    required String challengeId,
    required DifficultyTier tier,
    required bool whisperMode,
    required bool showInRankings,
    required bool shareInFeed,
    String? displayName,
    String? avatarUrl,
    String? circleId,
    String? invitedBy,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      // Check if already participating
      final existing =
          await _participationRepo.findByUserAndChallenge(userId, challengeId);
      if (existing != null) {
        state = AsyncValue.error(
            'Already participating in this challenge', StackTrace.current);
        return;
      }

      // Get challenge for tier target
      final challenge = await _challengeRepo.getChallenge(challengeId);
      final tierTarget =
          challenge?.tiers?.targetForTier(tier) ?? challenge?.goal.targetValue;

      // Create participation
      final participation = ChallengeParticipation(
        id: '',
        challengeId: challengeId,
        userId: userId,
        joinedAt: DateTime.now(),
        selectedTier: tier,
        whisperModeEnabled: whisperMode,
        showInRankings: showInRankings,
        shareActivityInFeed: shareInFeed,
        displayName: displayName,
        avatarUrl: avatarUrl,
        tierTarget: tierTarget,
        circleId: circleId,
        invitedBy: invitedBy,
        healthDisclaimerAccepted: true,
        dataConsentGiven: true,
      );

      final participationId =
          await _participationRepo.createParticipation(participation);

      // Increment participant count
      await _challengeRepo.incrementParticipants(challengeId);

      state = AsyncValue.data(participationId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final joinChallengeProvider =
    StateNotifierProvider<JoinChallengeNotifier, AsyncValue<String?>>((ref) {
  final participationRepo = ref.watch(participationRepositoryProvider);
  final challengeRepo = ref.watch(unityChallengeRepositoryProvider);
  return JoinChallengeNotifier(participationRepo, challengeRepo);
});

/// Record progress notifier
class RecordProgressNotifier extends StateNotifier<AsyncValue<void>> {
  RecordProgressNotifier(this._progressService)
      : super(const AsyncValue.data(null));

  final ChallengeProgressService _progressService;

  Future<void> recordProgress({
    required String participationId,
    required double value,
    required DateTime date,
    String? workoutId,
    double? readinessScore,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _progressService.recordWorkoutProgress(
        participationId: participationId,
        value: value,
        date: date,
        workoutId: workoutId,
        readinessScore: readinessScore,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final recordProgressProvider =
    StateNotifierProvider<RecordProgressNotifier, AsyncValue<void>>((ref) {
  final progressService = ref.watch(challengeProgressServiceProvider);
  return RecordProgressNotifier(progressService);
});

/// Record rest day notifier
class RecordRestDayNotifier extends StateNotifier<AsyncValue<void>> {
  RecordRestDayNotifier(this._participationRepo)
      : super(const AsyncValue.data(null));

  final ParticipationRepository _participationRepo;

  Future<void> recordRestDay({
    required String participationId,
    required RestDayReason reason,
    String? note,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final restDay = RestDay(
        id: '',
        userId: userId,
        date: DateTime.now(),
        reason: reason,
        note: note,
      );

      await _participationRepo.recordRestDay(participationId, restDay);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final recordRestDayProvider =
    StateNotifierProvider<RecordRestDayNotifier, AsyncValue<void>>((ref) {
  final participationRepo = ref.watch(participationRepositoryProvider);
  return RecordRestDayNotifier(participationRepo);
});

/// Leave challenge notifier
class LeaveChallengeNotifier extends StateNotifier<AsyncValue<void>> {
  LeaveChallengeNotifier(this._participationRepo, this._challengeRepo)
      : super(const AsyncValue.data(null));

  final ParticipationRepository _participationRepo;
  final UnityChallengeRepository _challengeRepo;

  Future<void> leaveChallenge(String participationId) async {
    state = const AsyncValue.loading();

    try {
      final participation =
          await _participationRepo.getParticipation(participationId);
      if (participation == null) {
        state = AsyncValue.error('Participation not found', StackTrace.current);
        return;
      }

      // Update status to withdrawn
      await _participationRepo.updateStatus(
        participationId,
        ParticipationStatus.withdrawn,
      );

      // Decrement participant count
      await _challengeRepo.decrementParticipants(participation.challengeId);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveChallengeProvider =
    StateNotifierProvider<LeaveChallengeNotifier, AsyncValue<void>>((ref) {
  final participationRepo = ref.watch(participationRepositoryProvider);
  final challengeRepo = ref.watch(unityChallengeRepositoryProvider);
  return LeaveChallengeNotifier(participationRepo, challengeRepo);
});

/// Leaderboard provider
final challengeLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>(
        (ref, challengeId) async {
  final progressService = ref.watch(challengeProgressServiceProvider);
  return progressService.getLeaderboard(challengeId: challengeId);
});

/// On-track status provider
final onTrackStatusProvider =
    FutureProvider.family<OnTrackResult?, String>((ref, participationId) async {
  final participationRepo = ref.watch(participationRepositoryProvider);
  final challengeRepo = ref.watch(unityChallengeRepositoryProvider);
  final progressService = ref.watch(challengeProgressServiceProvider);

  final participation =
      await participationRepo.getParticipation(participationId);
  if (participation == null) return null;

  final challenge =
      await challengeRepo.getChallenge(participation.challengeId);
  if (challenge == null) return null;

  return progressService.isOnTrack(
    participation: participation,
    challenge: challenge,
  );
});
