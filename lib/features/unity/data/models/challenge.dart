import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';
import 'difficulty_tier.dart';
import 'milestone.dart';

/// Defines the goal configuration for a challenge
class GoalDefinition {
  const GoalDefinition({
    required this.type,
    required this.metric,
    required this.targetValue,
    this.unit,
    this.aggregation = AggregationType.sum,
    this.isAdaptive = false,
    this.frequencyCount,
    this.frequencyPeriod,
    this.streakLength,
    this.allowRestDays = true,
    this.maxRestDaysPerWeek = 2,
  });

  final ChallengeType type;
  final MetricType metric;
  final double targetValue;
  final String? unit;
  final AggregationType aggregation;
  final bool isAdaptive;
  final int? frequencyCount;
  final FrequencyPeriod? frequencyPeriod;
  final int? streakLength;
  final bool allowRestDays;
  final int maxRestDaysPerWeek;

  factory GoalDefinition.fromFirestore(Map<String, dynamic> data) {
    return GoalDefinition(
      type: ChallengeType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ChallengeType.accumulation,
      ),
      metric: MetricType.values.firstWhere(
        (m) => m.name == data['metric'],
        orElse: () => MetricType.steps,
      ),
      targetValue: (data['targetValue'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String?,
      aggregation: AggregationType.values.firstWhere(
        (a) => a.name == data['aggregation'],
        orElse: () => AggregationType.sum,
      ),
      isAdaptive: data['isAdaptive'] as bool? ?? false,
      frequencyCount: data['frequencyCount'] as int?,
      frequencyPeriod: data['frequencyPeriod'] != null
          ? FrequencyPeriod.values.firstWhere(
              (f) => f.name == data['frequencyPeriod'],
              orElse: () => FrequencyPeriod.weekly,
            )
          : null,
      streakLength: data['streakLength'] as int?,
      allowRestDays: data['allowRestDays'] as bool? ?? true,
      maxRestDaysPerWeek: data['maxRestDaysPerWeek'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'metric': metric.name,
      'targetValue': targetValue,
      if (unit != null) 'unit': unit,
      'aggregation': aggregation.name,
      'isAdaptive': isAdaptive,
      if (frequencyCount != null) 'frequencyCount': frequencyCount,
      if (frequencyPeriod != null) 'frequencyPeriod': frequencyPeriod!.name,
      if (streakLength != null) 'streakLength': streakLength,
      'allowRestDays': allowRestDays,
      'maxRestDaysPerWeek': maxRestDaysPerWeek,
    };
  }

  String get effectiveUnit => unit ?? metric.defaultUnit;
}

/// Main Challenge model for Unity
class Challenge {
  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.participationType,
    required this.competitionStyle,
    required this.startDate,
    required this.endDate,
    required this.goal,
    this.imageUrl,
    this.theme,
    this.gracePeriod = const Duration(hours: 24),
    this.milestones = const [],
    this.tiers,
    this.maxParticipants,
    this.hasActivityFeed = true,
    this.hasLeaderboard = false,
    this.allowsWhisperMode = true,
    this.allowsRestDays = true,
    this.completionBadgeUrl,
    this.xpReward = 100,
    this.privacyLevel = PrivacyLevel.public,
    this.requiresHealthDisclaimer = true,
    required this.createdBy,
    this.status = ChallengeStatus.draft,
    this.circleId,
    this.participantCount = 0,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.category,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final ParticipationType participationType;
  final CompetitionStyle competitionStyle;
  final DateTime startDate;
  final DateTime endDate;
  final GoalDefinition goal;
  final String? imageUrl;
  final String? theme;
  final Duration gracePeriod;
  final List<Milestone> milestones;
  final DifficultyTiers? tiers;
  final int? maxParticipants;
  final bool hasActivityFeed;
  final bool hasLeaderboard;
  final bool allowsWhisperMode;
  final bool allowsRestDays;
  final String? completionBadgeUrl;
  final int xpReward;
  final PrivacyLevel privacyLevel;
  final bool requiresHealthDisclaimer;
  final String createdBy;
  final ChallengeStatus status;
  final String? circleId;
  final int participantCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final String? category;
  final bool isFeatured;

  /// Duration of the challenge in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Whether the challenge is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == ChallengeStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  /// Whether the challenge is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return status == ChallengeStatus.upcoming && now.isBefore(startDate);
  }

  /// Whether the challenge has ended
  bool get hasEnded {
    final now = DateTime.now();
    return now.isAfter(endDate) || status == ChallengeStatus.completed;
  }

  /// Whether the challenge can be joined
  bool get isJoinable {
    if (!status.isJoinable) return false;
    if (maxParticipants != null && participantCount >= maxParticipants!) {
      return false;
    }
    return true;
  }

  /// Days remaining in the challenge
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Progress through the challenge as a percentage
  double get timeProgressPercent {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 1;
    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = now.difference(startDate).inMilliseconds;
    return elapsed / total;
  }

  factory Challenge.fromFirestore(Map<String, dynamic> data, String id) {
    return Challenge(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: ChallengeType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ChallengeType.accumulation,
      ),
      participationType: ParticipationType.values.firstWhere(
        (p) => p.name == data['participationType'],
        orElse: () => ParticipationType.community,
      ),
      competitionStyle: CompetitionStyle.values.firstWhere(
        (c) => c.name == data['competitionStyle'],
        orElse: () => CompetitionStyle.collaborative,
      ),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      goal: GoalDefinition.fromFirestore(
        data['goal'] as Map<String, dynamic>? ?? {},
      ),
      imageUrl: data['imageUrl'] as String?,
      theme: data['theme'] as String?,
      gracePeriod: Duration(
        hours: data['gracePeriodHours'] as int? ?? 24,
      ),
      milestones: (data['milestones'] as List<dynamic>?)
              ?.asMap()
              .entries
              .map((e) => Milestone.fromFirestore(
                    e.value as Map<String, dynamic>,
                    e.key.toString(),
                  ))
              .toList() ??
          [],
      tiers: data['tiers'] != null
          ? DifficultyTiers.fromFirestore(data['tiers'] as Map<String, dynamic>)
          : null,
      maxParticipants: data['maxParticipants'] as int?,
      hasActivityFeed: data['hasActivityFeed'] as bool? ?? true,
      hasLeaderboard: data['hasLeaderboard'] as bool? ?? false,
      allowsWhisperMode: data['allowsWhisperMode'] as bool? ?? true,
      allowsRestDays: data['allowsRestDays'] as bool? ?? true,
      completionBadgeUrl: data['completionBadgeUrl'] as String?,
      xpReward: data['xpReward'] as int? ?? 100,
      privacyLevel: PrivacyLevel.values.firstWhere(
        (p) => p.name == data['privacyLevel'],
        orElse: () => PrivacyLevel.public,
      ),
      requiresHealthDisclaimer:
          data['requiresHealthDisclaimer'] as bool? ?? true,
      createdBy: data['createdBy'] as String? ?? '',
      status: ChallengeStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ChallengeStatus.draft,
      ),
      circleId: data['circleId'] as String?,
      participantCount: data['participantCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: data['category'] as String?,
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'participationType': participationType.name,
      'competitionStyle': competitionStyle.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'goal': goal.toFirestore(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (theme != null) 'theme': theme,
      'gracePeriodHours': gracePeriod.inHours,
      'milestones': milestones.map((m) => m.toFirestore()).toList(),
      if (tiers != null) 'tiers': tiers!.toFirestore(),
      if (maxParticipants != null) 'maxParticipants': maxParticipants,
      'hasActivityFeed': hasActivityFeed,
      'hasLeaderboard': hasLeaderboard,
      'allowsWhisperMode': allowsWhisperMode,
      'allowsRestDays': allowsRestDays,
      if (completionBadgeUrl != null) 'completionBadgeUrl': completionBadgeUrl,
      'xpReward': xpReward,
      'privacyLevel': privacyLevel.name,
      'requiresHealthDisclaimer': requiresHealthDisclaimer,
      'createdBy': createdBy,
      'status': status.name,
      if (circleId != null) 'circleId': circleId,
      'participantCount': participantCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tags': tags,
      if (category != null) 'category': category,
      'isFeatured': isFeatured,
    };
  }

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    ChallengeType? type,
    ParticipationType? participationType,
    CompetitionStyle? competitionStyle,
    DateTime? startDate,
    DateTime? endDate,
    GoalDefinition? goal,
    String? imageUrl,
    String? theme,
    Duration? gracePeriod,
    List<Milestone>? milestones,
    DifficultyTiers? tiers,
    int? maxParticipants,
    bool? hasActivityFeed,
    bool? hasLeaderboard,
    bool? allowsWhisperMode,
    bool? allowsRestDays,
    String? completionBadgeUrl,
    int? xpReward,
    PrivacyLevel? privacyLevel,
    bool? requiresHealthDisclaimer,
    String? createdBy,
    ChallengeStatus? status,
    String? circleId,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
    bool? isFeatured,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      participationType: participationType ?? this.participationType,
      competitionStyle: competitionStyle ?? this.competitionStyle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      imageUrl: imageUrl ?? this.imageUrl,
      theme: theme ?? this.theme,
      gracePeriod: gracePeriod ?? this.gracePeriod,
      milestones: milestones ?? this.milestones,
      tiers: tiers ?? this.tiers,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      hasActivityFeed: hasActivityFeed ?? this.hasActivityFeed,
      hasLeaderboard: hasLeaderboard ?? this.hasLeaderboard,
      allowsWhisperMode: allowsWhisperMode ?? this.allowsWhisperMode,
      allowsRestDays: allowsRestDays ?? this.allowsRestDays,
      completionBadgeUrl: completionBadgeUrl ?? this.completionBadgeUrl,
      xpReward: xpReward ?? this.xpReward,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      requiresHealthDisclaimer:
          requiresHealthDisclaimer ?? this.requiresHealthDisclaimer,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      circleId: circleId ?? this.circleId,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
