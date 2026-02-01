import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for calculating and managing challenge progress
class ChallengeProgressService {
  ChallengeProgressService({
    required ParticipationRepository participationRepository,
    required UnityChallengeRepository challengeRepository,
  })  : _participationRepository = participationRepository,
        _challengeRepository = challengeRepository;

  final ParticipationRepository _participationRepository;
  final UnityChallengeRepository _challengeRepository;

  /// Calculate accumulation progress (sum toward total target)
  Future<ProgressResult> calculateAccumulationProgress({
    required String participationId,
    required double target,
  }) async {
    final progress =
        await _participationRepository.getDailyProgress(participationId);

    final totalProgress =
        progress.fold<double>(0, (sum, p) => sum + p.effectiveValue);
    final percentComplete =
        target > 0 ? (totalProgress / target * 100).clamp(0, 100) : 0;

    return ProgressResult(
      currentProgress: totalProgress,
      targetProgress: target,
      percentComplete: percentComplete.toDouble(),
      daysActive: progress.where((p) => !p.isRestDay).length,
      restDaysTaken: progress.where((p) => p.isRestDay).length,
    );
  }

  /// Calculate streak progress (consecutive days)
  Future<StreakResult> calculateStreakProgress({
    required String participationId,
    required int targetStreakLength,
    required DateTime startDate,
  }) async {
    final progress = await _participationRepository.getDailyProgress(
      participationId,
      startDate: startDate,
    );

    // Sort by date
    progress.sort((a, b) => a.date.compareTo(b.date));

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? lastActiveDate;

    for (final daily in progress) {
      if (daily.isRestDay || daily.targetMet) {
        if (lastActiveDate == null) {
          currentStreak = 1;
        } else {
          final daysDiff = daily.date.difference(lastActiveDate).inDays;
          if (daysDiff == 1) {
            currentStreak++;
          } else if (daysDiff > 1) {
            // Streak broken
            currentStreak = 1;
          }
        }
        lastActiveDate = daily.date;
        longestStreak =
            currentStreak > longestStreak ? currentStreak : longestStreak;
      } else if (lastActiveDate != null) {
        final daysDiff = daily.date.difference(lastActiveDate).inDays;
        if (daysDiff > 1) {
          // Streak broken by missed day (not rest day)
          currentStreak = 0;
        }
      }
    }

    // Check if streak is still active (last activity was yesterday or today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lastActiveDate != null) {
      final daysSinceLastActivity = today.difference(lastActiveDate).inDays;
      if (daysSinceLastActivity > 1) {
        currentStreak = 0;
      }
    }

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      targetStreak: targetStreakLength,
      isComplete: longestStreak >= targetStreakLength,
      percentComplete: targetStreakLength > 0
          ? (longestStreak / targetStreakLength * 100).clamp(0, 100)
          : 0,
    );
  }

  /// Calculate frequency progress (X times per period)
  Future<FrequencyResult> calculateFrequencyProgress({
    required String participationId,
    required int targetCount,
    required FrequencyPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final progress = await _participationRepository.getDailyProgress(
      participationId,
      startDate: startDate,
      endDate: endDate,
    );

    // Group by period
    final Map<String, List<DailyProgress>> periodGroups = {};

    for (final daily in progress) {
      final periodKey = _getPeriodKey(daily.date, period);
      periodGroups.putIfAbsent(periodKey, () => []);
      periodGroups[periodKey]!.add(daily);
    }

    // Count completed periods
    int completedPeriods = 0;
    int totalPeriods = 0;

    for (final group in periodGroups.values) {
      final activedays = group.where((p) => p.targetMet || p.isRestDay).length;
      totalPeriods++;
      if (activedays >= targetCount) {
        completedPeriods++;
      }
    }

    // Current period progress
    final currentPeriodKey = _getPeriodKey(DateTime.now(), period);
    final currentPeriodProgress = periodGroups[currentPeriodKey] ?? [];
    final currentPeriodCount =
        currentPeriodProgress.where((p) => p.targetMet || p.isRestDay).length;

    return FrequencyResult(
      targetCountPerPeriod: targetCount,
      period: period,
      completedPeriods: completedPeriods,
      totalPeriods: totalPeriods,
      currentPeriodCount: currentPeriodCount,
      currentPeriodTarget: targetCount,
    );
  }

  String _getPeriodKey(DateTime date, FrequencyPeriod period) {
    switch (period) {
      case FrequencyPeriod.daily:
        return '${date.year}-${date.month}-${date.day}';
      case FrequencyPeriod.weekly:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return '${weekStart.year}-${weekStart.month}-${weekStart.day}';
      case FrequencyPeriod.monthly:
        return '${date.year}-${date.month}';
    }
  }

  /// Check if user is on track to complete the challenge
  Future<OnTrackResult> isOnTrack({
    required ChallengeParticipation participation,
    required Challenge challenge,
  }) async {
    final now = DateTime.now();
    final totalDays = challenge.endDate.difference(challenge.startDate).inDays;
    final elapsedDays = now.difference(challenge.startDate).inDays;

    if (elapsedDays <= 0) {
      return OnTrackResult(
        isOnTrack: true,
        currentProgress: 0,
        expectedProgress: 0,
        progressDiff: 0,
        daysRemaining: totalDays,
        message: 'Challenge starts soon!',
      );
    }

    final target = participation.tierTarget ?? challenge.goal.targetValue;
    final expectedProgress = (target / totalDays) * elapsedDays;
    final progressDiff = participation.currentProgress - expectedProgress;
    final isOnTrack = progressDiff >= 0;

    String message;
    if (progressDiff > expectedProgress * 0.2) {
      message = "You're ahead of schedule! Keep it up!";
    } else if (isOnTrack) {
      message = "You're on track. Great work!";
    } else if (progressDiff > -expectedProgress * 0.1) {
      message = "Just a little behind, you've got this!";
    } else {
      message = 'Consider adjusting your pace or taking rest as needed.';
    }

    return OnTrackResult(
      isOnTrack: isOnTrack,
      currentProgress: participation.currentProgress,
      expectedProgress: expectedProgress,
      progressDiff: progressDiff,
      daysRemaining: challenge.daysRemaining,
      message: message,
    );
  }

  /// Get projected completion date
  Future<DateTime?> getProjectedCompletion({
    required ChallengeParticipation participation,
    required Challenge challenge,
  }) async {
    if (participation.currentProgress <= 0) return null;

    final progress = await _participationRepository.getDailyProgress(
      participation.id,
    );

    if (progress.isEmpty) return null;

    // Calculate daily average
    final activeDays = progress.where((p) => !p.isRestDay).toList();
    if (activeDays.isEmpty) return null;

    final totalValue =
        activeDays.fold<double>(0, (sum, p) => sum + p.effectiveValue);
    final dailyAverage = totalValue / activeDays.length;

    if (dailyAverage <= 0) return null;

    final target = participation.tierTarget ?? challenge.goal.targetValue;
    final remaining = target - participation.currentProgress;

    if (remaining <= 0) return DateTime.now();

    final daysNeeded = (remaining / dailyAverage).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  /// Check and unlock milestones
  Future<List<Milestone>> checkMilestones({
    required ChallengeParticipation participation,
    required Challenge challenge,
  }) async {
    final unlockedMilestones = <Milestone>[];

    for (final milestone in challenge.milestones) {
      if (participation.milestonesUnlocked.contains(milestone.id)) {
        continue; // Already unlocked
      }

      if (participation.currentProgress >= milestone.targetValue) {
        // Unlock this milestone
        await _participationRepository.unlockMilestone(
          participation.id,
          milestone.id,
        );
        unlockedMilestones.add(milestone.unlock());
      }
    }

    return unlockedMilestones;
  }

  /// Get leaderboard (for competitive challenges)
  Future<List<LeaderboardEntry>> getLeaderboard({
    required String challengeId,
    int limit = 50,
  }) async {
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null) return [];

    // This would need to be optimized with an index for large challenges
    final participantsStream =
        _participationRepository.getChallengeParticipantsStream(
      challengeId,
      rankingsOnly: true,
    );

    final participants = await participantsStream.first;

    // Sort by progress
    participants.sort((a, b) => b.currentProgress.compareTo(a.currentProgress));

    // Create leaderboard entries
    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < participants.length && i < limit; i++) {
      final p = participants[i];
      entries.add(LeaderboardEntry(
        rank: i + 1,
        participationId: p.id,
        userId: p.userId,
        displayName: p.effectiveDisplayName,
        avatarUrl: p.avatarUrl,
        currentProgress: p.currentProgress,
        percentComplete: p.percentComplete,
        isWhisperMode: p.whisperModeEnabled,
      ));
    }

    return entries;
  }

  /// Record progress from a workout
  Future<void> recordWorkoutProgress({
    required String participationId,
    required double value,
    required DateTime date,
    String? workoutId,
    double? readinessScore,
  }) async {
    final participation =
        await _participationRepository.getParticipation(participationId);
    if (participation == null) return;

    // Get existing progress for today
    final existing = await _participationRepository.getDailyProgressForDate(
      participationId,
      date,
    );

    DailyProgress progress;
    if (existing != null) {
      // Add to existing progress
      progress = existing.copyWith(
        rawValue: existing.rawValue + value,
      );
    } else {
      progress = DailyProgress(
        date: date,
        rawValue: value,
        sourceType: 'workout',
        sourceId: workoutId,
      );
    }

    // Apply readiness adjustment if provided
    if (readinessScore != null) {
      progress = progress.withReadinessAdjustment(readinessScore);
    }

    // Check if target met
    final challenge = await _challengeRepository
        .getChallenge(participation.challengeId);
    if (challenge != null) {
      final dailyTarget = challenge.tiers
              ?.dailyEquivalentForTier(participation.selectedTier) ??
          (challenge.goal.targetValue / challenge.durationDays);

      progress = progress.copyWith(
        dailyTarget: dailyTarget,
        targetMet: progress.effectiveValue >= dailyTarget,
      );
    }

    await _participationRepository.recordDailyProgress(
      participationId,
      progress,
    );

    // Check milestones
    if (challenge != null) {
      final updated =
          await _participationRepository.getParticipation(participationId);
      if (updated != null) {
        await checkMilestones(participation: updated, challenge: challenge);
      }
    }
  }
}

/// Result of accumulation progress calculation
class ProgressResult {
  const ProgressResult({
    required this.currentProgress,
    required this.targetProgress,
    required this.percentComplete,
    required this.daysActive,
    required this.restDaysTaken,
  });

  final double currentProgress;
  final double targetProgress;
  final double percentComplete;
  final int daysActive;
  final int restDaysTaken;
}

/// Result of streak progress calculation
class StreakResult {
  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.targetStreak,
    required this.isComplete,
    required this.percentComplete,
  });

  final int currentStreak;
  final int longestStreak;
  final int targetStreak;
  final bool isComplete;
  final double percentComplete;
}

/// Result of frequency progress calculation
class FrequencyResult {
  const FrequencyResult({
    required this.targetCountPerPeriod,
    required this.period,
    required this.completedPeriods,
    required this.totalPeriods,
    required this.currentPeriodCount,
    required this.currentPeriodTarget,
  });

  final int targetCountPerPeriod;
  final FrequencyPeriod period;
  final int completedPeriods;
  final int totalPeriods;
  final int currentPeriodCount;
  final int currentPeriodTarget;

  double get currentPeriodPercent => currentPeriodTarget > 0
      ? (currentPeriodCount / currentPeriodTarget * 100).clamp(0, 100)
      : 0;
}

/// Result of on-track check
class OnTrackResult {
  const OnTrackResult({
    required this.isOnTrack,
    required this.currentProgress,
    required this.expectedProgress,
    required this.progressDiff,
    required this.daysRemaining,
    required this.message,
  });

  final bool isOnTrack;
  final double currentProgress;
  final double expectedProgress;
  final double progressDiff;
  final int daysRemaining;
  final String message;
}

/// Leaderboard entry
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.participationId,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.currentProgress,
    required this.percentComplete,
    required this.isWhisperMode,
  });

  final int rank;
  final String participationId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double currentProgress;
  final double percentComplete;
  final bool isWhisperMode;
}
