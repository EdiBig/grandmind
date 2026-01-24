import 'package:cloud_firestore/cloud_firestore.dart';

/// Detailed progress tracking for challenge participants
class ChallengeProgressEntry {
  const ChallengeProgressEntry({
    required this.id,
    required this.participantId,
    required this.challengeId,
    required this.userId,
    required this.progressValue,
    required this.progressType,
    required this.sourceType,
    required this.sourceId,
    required this.recordedAt,
    this.metadata,
  });

  final String id;
  final String participantId;
  final String challengeId;
  final String userId;
  final int progressValue;
  final ProgressType progressType;
  final ProgressSourceType sourceType;
  final String? sourceId; // Reference to workout log, health data, habit log
  final DateTime recordedAt;
  final Map<String, dynamic>? metadata;

  factory ChallengeProgressEntry.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeProgressEntry(
      id: id,
      participantId: data['participantId'] as String? ?? '',
      challengeId: data['challengeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      progressValue: (data['progressValue'] as num?)?.toInt() ?? 0,
      progressType: ProgressType.values.firstWhere(
        (e) => e.name == (data['progressType'] as String?),
        orElse: () => ProgressType.workouts,
      ),
      sourceType: ProgressSourceType.values.firstWhere(
        (e) => e.name == (data['sourceType'] as String?),
        orElse: () => ProgressSourceType.manual,
      ),
      sourceId: data['sourceId'] as String?,
      recordedAt: _parseTimestamp(data['recordedAt']),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantId': participantId,
      'challengeId': challengeId,
      'userId': userId,
      'progressValue': progressValue,
      'progressType': progressType.name,
      'sourceType': sourceType.name,
      'sourceId': sourceId,
      'recordedAt': Timestamp.fromDate(recordedAt),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Types of progress that can be tracked
enum ProgressType {
  steps,
  workouts,
  habit,
  distance,
  calories,
  activeMinutes,
}

/// Source of progress data
enum ProgressSourceType {
  workoutLog,
  healthSync,
  habitCompletion,
  manual,
}

/// Milestone thresholds for achievements
class ChallengeMilestone {
  const ChallengeMilestone({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.milestoneType,
    required this.threshold,
    required this.achievedAt,
    this.celebrationShown = false,
  });

  final String id;
  final String challengeId;
  final String userId;
  final MilestoneType milestoneType;
  final int threshold;
  final DateTime achievedAt;
  final bool celebrationShown;

  factory ChallengeMilestone.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeMilestone(
      id: id,
      challengeId: data['challengeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      milestoneType: MilestoneType.values.firstWhere(
        (e) => e.name == (data['milestoneType'] as String?),
        orElse: () => MilestoneType.progressPercentage,
      ),
      threshold: (data['threshold'] as num?)?.toInt() ?? 0,
      achievedAt: _parseTimestamp(data['achievedAt']),
      celebrationShown: data['celebrationShown'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'milestoneType': milestoneType.name,
      'threshold': threshold,
      'achievedAt': Timestamp.fromDate(achievedAt),
      'celebrationShown': celebrationShown,
    };
  }
}

enum MilestoneType {
  progressPercentage, // 25%, 50%, 75%, 100% of goal
  streak, // 3, 7, 14, 30 day streaks
  rankImprovement, // Moved up in rankings
  firstActivity, // First progress logged
  goalCompleted, // Reached the challenge goal
}

/// Daily progress summary for a participant
class DailyProgressSummary {
  const DailyProgressSummary({
    required this.date,
    required this.totalProgress,
    required this.entries,
    required this.milestoneAchieved,
  });

  final DateTime date;
  final int totalProgress;
  final List<ChallengeProgressEntry> entries;
  final List<ChallengeMilestone> milestoneAchieved;

  bool get hasActivity => entries.isNotEmpty;
}

/// Challenge leaderboard entry with rank
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.participantId,
    required this.challengeId,
    required this.userId,
    required this.displayName,
    required this.currentProgress,
    required this.progressPercentage,
    required this.lastActivityAt,
    required this.isCurrentUser,
    this.avatarUrl,
    this.streakDays = 0,
  });

  final int rank;
  final String participantId;
  final String challengeId;
  final String userId;
  final String displayName;
  final int currentProgress;
  final double progressPercentage;
  final DateTime? lastActivityAt;
  final bool isCurrentUser;
  final String? avatarUrl;
  final int streakDays;

  /// Get rank badge color
  String get rankBadge {
    switch (rank) {
      case 1:
        return 'gold';
      case 2:
        return 'silver';
      case 3:
        return 'bronze';
      default:
        return 'default';
    }
  }
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}
