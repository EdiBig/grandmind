// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeActivityImpl _$$ChallengeActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeActivityImpl(
      id: json['id'] as String,
      odataType: json['odataType'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      activityType:
          $enumDecode(_$ChallengeActivityTypeEnumMap, json['activityType']),
      visibility: $enumDecode(_$ActivityVisibilityEnumMap, json['visibility']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      isRedacted: json['isRedacted'] as bool? ?? false,
      encouragementCount: (json['encouragementCount'] as num?)?.toInt() ?? 0,
      encouragedBy: (json['encouragedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ChallengeActivityImplToJson(
        _$ChallengeActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odataType': instance.odataType,
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'activityType': _$ChallengeActivityTypeEnumMap[instance.activityType]!,
      'visibility': _$ActivityVisibilityEnumMap[instance.visibility]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'data': instance.data,
      'description': instance.description,
      'isRedacted': instance.isRedacted,
      'encouragementCount': instance.encouragementCount,
      'encouragedBy': instance.encouragedBy,
    };

const _$ChallengeActivityTypeEnumMap = {
  ChallengeActivityType.joined: 'joined',
  ChallengeActivityType.progressLogged: 'progressLogged',
  ChallengeActivityType.milestoneReached: 'milestoneReached',
  ChallengeActivityType.personalBest: 'personalBest',
  ChallengeActivityType.goalCompleted: 'goalCompleted',
  ChallengeActivityType.encouragement: 'encouragement',
  ChallengeActivityType.challengeStarted: 'challengeStarted',
  ChallengeActivityType.challengeEnded: 'challengeEnded',
  ChallengeActivityType.badgeEarned: 'badgeEarned',
  ChallengeActivityType.streakUpdate: 'streakUpdate',
};

const _$ActivityVisibilityEnumMap = {
  ActivityVisibility.private: 'private',
  ActivityVisibility.participants: 'participants',
  ActivityVisibility.public: 'public',
};

_$ChallengeActivityStatsImpl _$$ChallengeActivityStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeActivityStatsImpl(
      challengeId: json['challengeId'] as String,
      totalActivities: (json['totalActivities'] as num?)?.toInt() ?? 0,
      totalEncouragements: (json['totalEncouragements'] as num?)?.toInt() ?? 0,
      participantsActive: (json['participantsActive'] as num?)?.toInt() ?? 0,
      activityTypeBreakdown:
          (json['activityTypeBreakdown'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$ChallengeActivityStatsImplToJson(
        _$ChallengeActivityStatsImpl instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'totalActivities': instance.totalActivities,
      'totalEncouragements': instance.totalEncouragements,
      'participantsActive': instance.participantsActive,
      'activityTypeBreakdown': instance.activityTypeBreakdown,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
    };
