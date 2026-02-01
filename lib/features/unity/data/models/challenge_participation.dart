import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a user's participation in a challenge
class ChallengeParticipation {
  const ChallengeParticipation({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.joinedAt,
    this.completedAt,
    this.currentProgress = 0,
    this.percentComplete = 0,
    this.selectedTier = DifficultyTier.steady,
    this.whisperModeEnabled = false,
    this.showInRankings = true,
    this.shareActivityInFeed = true,
    this.displayName,
    this.avatarUrl,
    this.bankedProgress = 0,
    this.restDaysUsed = 0,
    this.restDaysAllowed = 2,
    this.cheersReceived = 0,
    this.cheersSent = 0,
    this.healthDisclaimerAccepted = false,
    this.dataConsentGiven = false,
    this.status = ParticipationStatus.active,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityAt,
    this.totalActiveDays = 0,
    this.milestonesUnlocked = const [],
    this.tierTarget,
    this.invitedBy,
    this.circleId,
  });

  final String id;
  final String challengeId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final double currentProgress;
  final double percentComplete;
  final DifficultyTier selectedTier;
  final bool whisperModeEnabled;
  final bool showInRankings;
  final bool shareActivityInFeed;
  final String? displayName;
  final String? avatarUrl;
  final double bankedProgress;
  final int restDaysUsed;
  final int restDaysAllowed;
  final int cheersReceived;
  final int cheersSent;
  final bool healthDisclaimerAccepted;
  final bool dataConsentGiven;
  final ParticipationStatus status;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityAt;
  final int totalActiveDays;
  final List<String> milestonesUnlocked;
  final double? tierTarget;
  final String? invitedBy;
  final String? circleId;

  /// Whether the user has completed the challenge
  bool get isCompleted => status == ParticipationStatus.completed;

  /// Whether the user is actively participating
  bool get isActive => status == ParticipationStatus.active;

  /// Whether the user can log progress
  bool get canLogProgress => status.canContribute;

  /// Whether the user has rest days remaining
  bool get hasRestDaysRemaining => restDaysUsed < restDaysAllowed;

  /// Rest days remaining this week
  int get restDaysRemaining => restDaysAllowed - restDaysUsed;

  /// Display name to show (anonymous if whisper mode)
  String get effectiveDisplayName {
    if (whisperModeEnabled) return 'Anonymous';
    return displayName ?? 'User';
  }

  factory ChallengeParticipation.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeParticipation(
      id: id,
      challengeId: data['challengeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      joinedAt:
          (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      currentProgress: (data['currentProgress'] as num?)?.toDouble() ?? 0,
      percentComplete: (data['percentComplete'] as num?)?.toDouble() ?? 0,
      selectedTier: DifficultyTier.values.firstWhere(
        (t) => t.name == data['selectedTier'],
        orElse: () => DifficultyTier.steady,
      ),
      whisperModeEnabled: data['whisperModeEnabled'] as bool? ?? false,
      showInRankings: data['showInRankings'] as bool? ?? true,
      shareActivityInFeed: data['shareActivityInFeed'] as bool? ?? true,
      displayName: data['displayName'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      bankedProgress: (data['bankedProgress'] as num?)?.toDouble() ?? 0,
      restDaysUsed: data['restDaysUsed'] as int? ?? 0,
      restDaysAllowed: data['restDaysAllowed'] as int? ?? 2,
      cheersReceived: data['cheersReceived'] as int? ?? 0,
      cheersSent: data['cheersSent'] as int? ?? 0,
      healthDisclaimerAccepted:
          data['healthDisclaimerAccepted'] as bool? ?? false,
      dataConsentGiven: data['dataConsentGiven'] as bool? ?? false,
      status: ParticipationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ParticipationStatus.active,
      ),
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate(),
      totalActiveDays: data['totalActiveDays'] as int? ?? 0,
      milestonesUnlocked:
          (data['milestonesUnlocked'] as List<dynamic>?)?.cast<String>() ?? [],
      tierTarget: (data['tierTarget'] as num?)?.toDouble(),
      invitedBy: data['invitedBy'] as String?,
      circleId: data['circleId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'currentProgress': currentProgress,
      'percentComplete': percentComplete,
      'selectedTier': selectedTier.name,
      'whisperModeEnabled': whisperModeEnabled,
      'showInRankings': showInRankings,
      'shareActivityInFeed': shareActivityInFeed,
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'bankedProgress': bankedProgress,
      'restDaysUsed': restDaysUsed,
      'restDaysAllowed': restDaysAllowed,
      'cheersReceived': cheersReceived,
      'cheersSent': cheersSent,
      'healthDisclaimerAccepted': healthDisclaimerAccepted,
      'dataConsentGiven': dataConsentGiven,
      'status': status.name,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (lastActivityAt != null)
        'lastActivityAt': Timestamp.fromDate(lastActivityAt!),
      'totalActiveDays': totalActiveDays,
      'milestonesUnlocked': milestonesUnlocked,
      if (tierTarget != null) 'tierTarget': tierTarget,
      if (invitedBy != null) 'invitedBy': invitedBy,
      if (circleId != null) 'circleId': circleId,
    };
  }

  ChallengeParticipation copyWith({
    String? id,
    String? challengeId,
    String? userId,
    DateTime? joinedAt,
    DateTime? completedAt,
    double? currentProgress,
    double? percentComplete,
    DifficultyTier? selectedTier,
    bool? whisperModeEnabled,
    bool? showInRankings,
    bool? shareActivityInFeed,
    String? displayName,
    String? avatarUrl,
    double? bankedProgress,
    int? restDaysUsed,
    int? restDaysAllowed,
    int? cheersReceived,
    int? cheersSent,
    bool? healthDisclaimerAccepted,
    bool? dataConsentGiven,
    ParticipationStatus? status,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityAt,
    int? totalActiveDays,
    List<String>? milestonesUnlocked,
    double? tierTarget,
    String? invitedBy,
    String? circleId,
  }) {
    return ChallengeParticipation(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      completedAt: completedAt ?? this.completedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      percentComplete: percentComplete ?? this.percentComplete,
      selectedTier: selectedTier ?? this.selectedTier,
      whisperModeEnabled: whisperModeEnabled ?? this.whisperModeEnabled,
      showInRankings: showInRankings ?? this.showInRankings,
      shareActivityInFeed: shareActivityInFeed ?? this.shareActivityInFeed,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bankedProgress: bankedProgress ?? this.bankedProgress,
      restDaysUsed: restDaysUsed ?? this.restDaysUsed,
      restDaysAllowed: restDaysAllowed ?? this.restDaysAllowed,
      cheersReceived: cheersReceived ?? this.cheersReceived,
      cheersSent: cheersSent ?? this.cheersSent,
      healthDisclaimerAccepted:
          healthDisclaimerAccepted ?? this.healthDisclaimerAccepted,
      dataConsentGiven: dataConsentGiven ?? this.dataConsentGiven,
      status: status ?? this.status,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      milestonesUnlocked: milestonesUnlocked ?? this.milestonesUnlocked,
      tierTarget: tierTarget ?? this.tierTarget,
      invitedBy: invitedBy ?? this.invitedBy,
      circleId: circleId ?? this.circleId,
    );
  }

  /// Add progress and recalculate percentage
  ChallengeParticipation addProgress(double value, double target) {
    final newProgress = currentProgress + value;
    final newPercent = target > 0 ? (newProgress / target * 100).clamp(0, 100) : 0;
    return copyWith(
      currentProgress: newProgress,
      percentComplete: newPercent.toDouble(),
      lastActivityAt: DateTime.now(),
      totalActiveDays: totalActiveDays + 1,
    );
  }

  /// Mark as completed
  ChallengeParticipation complete() {
    return copyWith(
      status: ParticipationStatus.completed,
      completedAt: DateTime.now(),
      percentComplete: 100,
    );
  }

  /// Use a rest day
  ChallengeParticipation useRestDay() {
    if (!hasRestDaysRemaining) return this;
    return copyWith(restDaysUsed: restDaysUsed + 1);
  }

  /// Update streak
  ChallengeParticipation updateStreak(int newStreak) {
    return copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
    );
  }

  /// Increment cheers received
  ChallengeParticipation receiveCheer() {
    return copyWith(cheersReceived: cheersReceived + 1);
  }

  /// Increment cheers sent
  ChallengeParticipation sendCheer() {
    return copyWith(cheersSent: cheersSent + 1);
  }

  /// Unlock a milestone
  ChallengeParticipation unlockMilestone(String milestoneId) {
    if (milestonesUnlocked.contains(milestoneId)) return this;
    return copyWith(
      milestonesUnlocked: [...milestonesUnlocked, milestoneId],
    );
  }
}
