import 'package:cloud_firestore/cloud_firestore.dart';

/// User's Unity privacy and notification settings
class UnitySettings {
  const UnitySettings({
    required this.userId,
    this.profileVisibleToCircles = true,
    this.shareWorkoutsInFeed = true,
    this.shareProgressInRankings = true,
    this.allowCheersFromNonFriends = false,
    this.receiveChallengeNotifications = true,
    this.receiveCheerNotifications = true,
    this.receiveMilestoneNotifications = true,
    this.receiveCircleActivityNotifications = true,
    this.allowCircleInvites = true,
    this.allowChallengeInvites = true,
    this.defaultWhisperMode = false,
    this.defaultShowInRankings = true,
    this.defaultShareInFeed = true,
    this.defaultTier,
    this.mutedCircles = const [],
    this.mutedChallenges = const [],
    this.blockedUsers = const [],
    this.quietHoursStart,
    this.quietHoursEnd,
    this.quietHoursEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;

  // Privacy settings
  final bool profileVisibleToCircles;
  final bool shareWorkoutsInFeed;
  final bool shareProgressInRankings;
  final bool allowCheersFromNonFriends;

  // Notification settings
  final bool receiveChallengeNotifications;
  final bool receiveCheerNotifications;
  final bool receiveMilestoneNotifications;
  final bool receiveCircleActivityNotifications;
  final bool allowCircleInvites;
  final bool allowChallengeInvites;

  // Default participation settings
  final bool defaultWhisperMode;
  final bool defaultShowInRankings;
  final bool defaultShareInFeed;
  final String? defaultTier;

  // Muted/blocked
  final List<String> mutedCircles;
  final List<String> mutedChallenges;
  final List<String> blockedUsers;

  // Quiet hours
  final String? quietHoursStart; // "HH:mm" format
  final String? quietHoursEnd;   // "HH:mm" format
  final bool quietHoursEnabled;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Check if a circle is muted
  bool isCircleMuted(String circleId) => mutedCircles.contains(circleId);

  /// Check if a challenge is muted
  bool isChallengeMuted(String challengeId) =>
      mutedChallenges.contains(challengeId);

  /// Check if a user is blocked
  bool isUserBlocked(String userId) => blockedUsers.contains(userId);

  /// Check if currently in quiet hours
  bool get isInQuietHours {
    if (!quietHoursEnabled ||
        quietHoursStart == null ||
        quietHoursEnd == null) {
      return false;
    }

    final now = DateTime.now();
    final startParts = quietHoursStart!.split(':');
    final endParts = quietHoursEnd!.split(':');

    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    // Handle overnight quiet hours
    if (endTime.isBefore(startTime)) {
      return now.isAfter(startTime) || now.isBefore(endTime);
    }

    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  factory UnitySettings.fromFirestore(Map<String, dynamic> data, String userId) {
    return UnitySettings(
      userId: userId,
      profileVisibleToCircles: data['profileVisibleToCircles'] as bool? ?? true,
      shareWorkoutsInFeed: data['shareWorkoutsInFeed'] as bool? ?? true,
      shareProgressInRankings: data['shareProgressInRankings'] as bool? ?? true,
      allowCheersFromNonFriends:
          data['allowCheersFromNonFriends'] as bool? ?? false,
      receiveChallengeNotifications:
          data['receiveChallengeNotifications'] as bool? ?? true,
      receiveCheerNotifications:
          data['receiveCheerNotifications'] as bool? ?? true,
      receiveMilestoneNotifications:
          data['receiveMilestoneNotifications'] as bool? ?? true,
      receiveCircleActivityNotifications:
          data['receiveCircleActivityNotifications'] as bool? ?? true,
      allowCircleInvites: data['allowCircleInvites'] as bool? ?? true,
      allowChallengeInvites: data['allowChallengeInvites'] as bool? ?? true,
      defaultWhisperMode: data['defaultWhisperMode'] as bool? ?? false,
      defaultShowInRankings: data['defaultShowInRankings'] as bool? ?? true,
      defaultShareInFeed: data['defaultShareInFeed'] as bool? ?? true,
      defaultTier: data['defaultTier'] as String?,
      mutedCircles:
          (data['mutedCircles'] as List<dynamic>?)?.cast<String>() ?? [],
      mutedChallenges:
          (data['mutedChallenges'] as List<dynamic>?)?.cast<String>() ?? [],
      blockedUsers:
          (data['blockedUsers'] as List<dynamic>?)?.cast<String>() ?? [],
      quietHoursStart: data['quietHoursStart'] as String?,
      quietHoursEnd: data['quietHoursEnd'] as String?,
      quietHoursEnabled: data['quietHoursEnabled'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profileVisibleToCircles': profileVisibleToCircles,
      'shareWorkoutsInFeed': shareWorkoutsInFeed,
      'shareProgressInRankings': shareProgressInRankings,
      'allowCheersFromNonFriends': allowCheersFromNonFriends,
      'receiveChallengeNotifications': receiveChallengeNotifications,
      'receiveCheerNotifications': receiveCheerNotifications,
      'receiveMilestoneNotifications': receiveMilestoneNotifications,
      'receiveCircleActivityNotifications': receiveCircleActivityNotifications,
      'allowCircleInvites': allowCircleInvites,
      'allowChallengeInvites': allowChallengeInvites,
      'defaultWhisperMode': defaultWhisperMode,
      'defaultShowInRankings': defaultShowInRankings,
      'defaultShareInFeed': defaultShareInFeed,
      if (defaultTier != null) 'defaultTier': defaultTier,
      'mutedCircles': mutedCircles,
      'mutedChallenges': mutedChallenges,
      'blockedUsers': blockedUsers,
      if (quietHoursStart != null) 'quietHoursStart': quietHoursStart,
      if (quietHoursEnd != null) 'quietHoursEnd': quietHoursEnd,
      'quietHoursEnabled': quietHoursEnabled,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UnitySettings copyWith({
    String? userId,
    bool? profileVisibleToCircles,
    bool? shareWorkoutsInFeed,
    bool? shareProgressInRankings,
    bool? allowCheersFromNonFriends,
    bool? receiveChallengeNotifications,
    bool? receiveCheerNotifications,
    bool? receiveMilestoneNotifications,
    bool? receiveCircleActivityNotifications,
    bool? allowCircleInvites,
    bool? allowChallengeInvites,
    bool? defaultWhisperMode,
    bool? defaultShowInRankings,
    bool? defaultShareInFeed,
    String? defaultTier,
    List<String>? mutedCircles,
    List<String>? mutedChallenges,
    List<String>? blockedUsers,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? quietHoursEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitySettings(
      userId: userId ?? this.userId,
      profileVisibleToCircles:
          profileVisibleToCircles ?? this.profileVisibleToCircles,
      shareWorkoutsInFeed: shareWorkoutsInFeed ?? this.shareWorkoutsInFeed,
      shareProgressInRankings:
          shareProgressInRankings ?? this.shareProgressInRankings,
      allowCheersFromNonFriends:
          allowCheersFromNonFriends ?? this.allowCheersFromNonFriends,
      receiveChallengeNotifications:
          receiveChallengeNotifications ?? this.receiveChallengeNotifications,
      receiveCheerNotifications:
          receiveCheerNotifications ?? this.receiveCheerNotifications,
      receiveMilestoneNotifications:
          receiveMilestoneNotifications ?? this.receiveMilestoneNotifications,
      receiveCircleActivityNotifications: receiveCircleActivityNotifications ??
          this.receiveCircleActivityNotifications,
      allowCircleInvites: allowCircleInvites ?? this.allowCircleInvites,
      allowChallengeInvites:
          allowChallengeInvites ?? this.allowChallengeInvites,
      defaultWhisperMode: defaultWhisperMode ?? this.defaultWhisperMode,
      defaultShowInRankings:
          defaultShowInRankings ?? this.defaultShowInRankings,
      defaultShareInFeed: defaultShareInFeed ?? this.defaultShareInFeed,
      defaultTier: defaultTier ?? this.defaultTier,
      mutedCircles: mutedCircles ?? this.mutedCircles,
      mutedChallenges: mutedChallenges ?? this.mutedChallenges,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mute a circle
  UnitySettings muteCircle(String circleId) {
    if (mutedCircles.contains(circleId)) return this;
    return copyWith(mutedCircles: [...mutedCircles, circleId]);
  }

  /// Unmute a circle
  UnitySettings unmuteCircle(String circleId) {
    return copyWith(
      mutedCircles: mutedCircles.where((id) => id != circleId).toList(),
    );
  }

  /// Mute a challenge
  UnitySettings muteChallenge(String challengeId) {
    if (mutedChallenges.contains(challengeId)) return this;
    return copyWith(mutedChallenges: [...mutedChallenges, challengeId]);
  }

  /// Unmute a challenge
  UnitySettings unmuteChallenge(String challengeId) {
    return copyWith(
      mutedChallenges:
          mutedChallenges.where((id) => id != challengeId).toList(),
    );
  }

  /// Block a user
  UnitySettings blockUser(String userId) {
    if (blockedUsers.contains(userId)) return this;
    return copyWith(blockedUsers: [...blockedUsers, userId]);
  }

  /// Unblock a user
  UnitySettings unblockUser(String userId) {
    return copyWith(
      blockedUsers: blockedUsers.where((id) => id != userId).toList(),
    );
  }

  /// Create default settings for a new user
  factory UnitySettings.defaults(String userId) {
    return UnitySettings(
      userId: userId,
      createdAt: DateTime.now(),
    );
  }
}
