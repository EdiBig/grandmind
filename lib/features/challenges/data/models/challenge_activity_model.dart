import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'challenge_activity_model.freezed.dart';
part 'challenge_activity_model.g.dart';

/// Types of activities that can appear in a challenge feed
enum ChallengeActivityType {
  /// User joined the challenge
  joined,

  /// User logged progress (workout, steps, etc.)
  progressLogged,

  /// User reached a milestone
  milestoneReached,

  /// User achieved a personal best
  personalBest,

  /// User completed a challenge goal
  goalCompleted,

  /// User sent encouragement to another participant
  encouragement,

  /// Challenge started
  challengeStarted,

  /// Challenge ended
  challengeEnded,

  /// User was awarded a badge/achievement
  badgeEarned,

  /// User's streak update
  streakUpdate,
}

/// Visibility levels for activity items
enum ActivityVisibility {
  /// Visible only to the user who performed the activity
  private,

  /// Visible to challenge participants only
  participants,

  /// Visible to anyone who can see the challenge
  public,
}

/// Model for activity feed items in challenges
@freezed
class ChallengeActivity with _$ChallengeActivity {
  const ChallengeActivity._();

  const factory ChallengeActivity({
    required String id,
    required String odataType,
    required String challengeId,
    required String userId,
    required ChallengeActivityType activityType,
    required ActivityVisibility visibility,
    required DateTime createdAt,

    /// Display name (only populated if user consented to activity sharing)
    String? displayName,

    /// Avatar URL (only populated if user consented to activity sharing)
    String? avatarUrl,

    /// Activity-specific data
    Map<String, dynamic>? data,

    /// Human-readable description of the activity
    String? description,

    /// Whether this activity has been redacted due to privacy
    @Default(false) bool isRedacted,

    /// Encouragement/reaction counts
    @Default(0) int encouragementCount,

    /// Users who sent encouragement (anonymized if privacy enabled)
    @Default([]) List<String> encouragedBy,
  }) = _ChallengeActivity;

  factory ChallengeActivity.fromJson(Map<String, dynamic> json) =>
      _$ChallengeActivityFromJson(json);

  factory ChallengeActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChallengeActivity(
      id: doc.id,
      odataType: 'challenge_activity',
      challengeId: data['challengeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      activityType: ChallengeActivityType.values.firstWhere(
        (e) => e.name == (data['activityType'] as String?),
        orElse: () => ChallengeActivityType.progressLogged,
      ),
      visibility: ActivityVisibility.values.firstWhere(
        (e) => e.name == (data['visibility'] as String?),
        orElse: () => ActivityVisibility.participants,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayName: data['displayName'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      data: data['data'] as Map<String, dynamic>?,
      description: data['description'] as String?,
      isRedacted: data['isRedacted'] as bool? ?? false,
      encouragementCount: data['encouragementCount'] as int? ?? 0,
      encouragedBy: (data['encouragedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'activityType': activityType.name,
      'visibility': visibility.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (data != null) 'data': data,
      if (description != null) 'description': description,
      'isRedacted': isRedacted,
      'encouragementCount': encouragementCount,
      'encouragedBy': encouragedBy,
    };
  }

  /// Create a redacted version for users who haven't consented to activity sharing
  ChallengeActivity redacted() {
    return copyWith(
      displayName: null,
      avatarUrl: null,
      isRedacted: true,
      description: _getRedactedDescription(),
    );
  }

  String _getRedactedDescription() {
    switch (activityType) {
      case ChallengeActivityType.joined:
        return 'A participant joined the challenge';
      case ChallengeActivityType.progressLogged:
        return 'A participant logged progress';
      case ChallengeActivityType.milestoneReached:
        return 'A participant reached a milestone';
      case ChallengeActivityType.personalBest:
        return 'A participant achieved a personal best';
      case ChallengeActivityType.goalCompleted:
        return 'A participant completed their goal';
      case ChallengeActivityType.encouragement:
        return 'Someone sent encouragement';
      case ChallengeActivityType.challengeStarted:
        return 'The challenge has started';
      case ChallengeActivityType.challengeEnded:
        return 'The challenge has ended';
      case ChallengeActivityType.badgeEarned:
        return 'A participant earned a badge';
      case ChallengeActivityType.streakUpdate:
        return 'A participant updated their streak';
    }
  }

  /// Get icon for activity type
  String get activityIcon {
    switch (activityType) {
      case ChallengeActivityType.joined:
        return 'person_add';
      case ChallengeActivityType.progressLogged:
        return 'fitness_center';
      case ChallengeActivityType.milestoneReached:
        return 'flag';
      case ChallengeActivityType.personalBest:
        return 'emoji_events';
      case ChallengeActivityType.goalCompleted:
        return 'check_circle';
      case ChallengeActivityType.encouragement:
        return 'favorite';
      case ChallengeActivityType.challengeStarted:
        return 'play_arrow';
      case ChallengeActivityType.challengeEnded:
        return 'stop';
      case ChallengeActivityType.badgeEarned:
        return 'military_tech';
      case ChallengeActivityType.streakUpdate:
        return 'local_fire_department';
    }
  }
}

/// Builder for creating activity items with proper privacy handling
class ChallengeActivityBuilder {
  String? _challengeId;
  String? _userId;
  ChallengeActivityType? _activityType;
  ActivityVisibility _visibility = ActivityVisibility.participants;
  String? _displayName;
  String? _avatarUrl;
  Map<String, dynamic>? _data;
  String? _description;
  bool _userConsentedToSharing = false;

  ChallengeActivityBuilder();

  ChallengeActivityBuilder challengeId(String id) {
    _challengeId = id;
    return this;
  }

  ChallengeActivityBuilder userId(String id) {
    _userId = id;
    return this;
  }

  ChallengeActivityBuilder activityType(ChallengeActivityType type) {
    _activityType = type;
    return this;
  }

  ChallengeActivityBuilder visibility(ActivityVisibility vis) {
    _visibility = vis;
    return this;
  }

  ChallengeActivityBuilder userInfo({
    required String displayName,
    String? avatarUrl,
    required bool consentedToSharing,
  }) {
    _displayName = displayName;
    _avatarUrl = avatarUrl;
    _userConsentedToSharing = consentedToSharing;
    return this;
  }

  ChallengeActivityBuilder data(Map<String, dynamic> data) {
    _data = data;
    return this;
  }

  ChallengeActivityBuilder description(String desc) {
    _description = desc;
    return this;
  }

  ChallengeActivity build() {
    if (_challengeId == null || _userId == null || _activityType == null) {
      throw ArgumentError('challengeId, userId, and activityType are required');
    }

    return ChallengeActivity(
      id: '', // Will be set by Firestore
      odataType: 'challenge_activity',
      challengeId: _challengeId!,
      userId: _userId!,
      activityType: _activityType!,
      visibility: _visibility,
      createdAt: DateTime.now(),
      // Only include user info if they consented
      displayName: _userConsentedToSharing ? _displayName : null,
      avatarUrl: _userConsentedToSharing ? _avatarUrl : null,
      data: _data,
      description: _description,
      isRedacted: !_userConsentedToSharing,
    );
  }
}

/// Aggregate stats for activity feed
@freezed
class ChallengeActivityStats with _$ChallengeActivityStats {
  const factory ChallengeActivityStats({
    required String challengeId,
    @Default(0) int totalActivities,
    @Default(0) int totalEncouragements,
    @Default(0) int participantsActive,
    @Default({}) Map<String, int> activityTypeBreakdown,
    DateTime? lastActivityAt,
  }) = _ChallengeActivityStats;

  factory ChallengeActivityStats.fromJson(Map<String, dynamic> json) =>
      _$ChallengeActivityStatsFromJson(json);
}
