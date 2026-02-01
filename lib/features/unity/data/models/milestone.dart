import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a milestone within a challenge
class Milestone {
  const Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.targetValue,
    required this.order,
    this.iconUrl,
    this.badgeUrl,
    this.xpReward = 0,
    this.unlockedAt,
    this.celebrationMessage,
  });

  final String id;
  final String name;
  final String description;
  final double targetValue;
  final int order;
  final String? iconUrl;
  final String? badgeUrl;
  final int xpReward;
  final DateTime? unlockedAt;
  final String? celebrationMessage;

  bool get isUnlocked => unlockedAt != null;

  factory Milestone.fromFirestore(Map<String, dynamic> data, String id) {
    return Milestone(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      targetValue: (data['targetValue'] as num?)?.toDouble() ?? 0,
      order: data['order'] as int? ?? 0,
      iconUrl: data['iconUrl'] as String?,
      badgeUrl: data['badgeUrl'] as String?,
      xpReward: data['xpReward'] as int? ?? 0,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      celebrationMessage: data['celebrationMessage'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'targetValue': targetValue,
      'order': order,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (badgeUrl != null) 'badgeUrl': badgeUrl,
      'xpReward': xpReward,
      if (unlockedAt != null) 'unlockedAt': Timestamp.fromDate(unlockedAt!),
      if (celebrationMessage != null) 'celebrationMessage': celebrationMessage,
    };
  }

  Milestone copyWith({
    String? id,
    String? name,
    String? description,
    double? targetValue,
    int? order,
    String? iconUrl,
    String? badgeUrl,
    int? xpReward,
    DateTime? unlockedAt,
    String? celebrationMessage,
  }) {
    return Milestone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      order: order ?? this.order,
      iconUrl: iconUrl ?? this.iconUrl,
      badgeUrl: badgeUrl ?? this.badgeUrl,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      celebrationMessage: celebrationMessage ?? this.celebrationMessage,
    );
  }

  /// Mark this milestone as unlocked
  Milestone unlock() {
    return copyWith(unlockedAt: DateTime.now());
  }

  /// Calculate progress percentage toward this milestone
  double progressPercent(double currentProgress) {
    if (targetValue <= 0) return 0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }
}

/// A user's progress toward unlocking milestones
class MilestoneProgress {
  const MilestoneProgress({
    required this.milestoneId,
    required this.userId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    this.celebrationSeen = false,
  });

  final String milestoneId;
  final String userId;
  final double currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool celebrationSeen;

  factory MilestoneProgress.fromFirestore(Map<String, dynamic> data) {
    return MilestoneProgress(
      milestoneId: data['milestoneId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      currentProgress: (data['currentProgress'] as num?)?.toDouble() ?? 0,
      isUnlocked: data['isUnlocked'] as bool? ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
      celebrationSeen: data['celebrationSeen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'milestoneId': milestoneId,
      'userId': userId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      if (unlockedAt != null) 'unlockedAt': Timestamp.fromDate(unlockedAt!),
      'celebrationSeen': celebrationSeen,
    };
  }
}
