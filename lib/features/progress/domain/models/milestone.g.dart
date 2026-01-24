// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      badge: json['badge'] as String,
      achievedAt: const TimestampConverter().fromJson(json['achievedAt']),
      isNew: json['isNew'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$MilestoneTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'badge': instance.badge,
      'achievedAt': const TimestampConverter().toJson(instance.achievedAt),
      'isNew': instance.isNew,
      'metadata': instance.metadata,
    };

const _$MilestoneTypeEnumMap = {
  MilestoneType.weight: 'weight',
  MilestoneType.streak: 'streak',
  MilestoneType.workout: 'workout',
  MilestoneType.habit: 'habit',
  MilestoneType.strength: 'strength',
  MilestoneType.firstTime: 'firstTime',
};

_$MilestoneSummaryImpl _$$MilestoneSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$MilestoneSummaryImpl(
      recentMilestones: (json['recentMilestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      allMilestones: (json['allMilestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      newCount: (json['newCount'] as num).toInt(),
      countByType: (json['countByType'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                $enumDecode(_$MilestoneTypeEnumMap, k), (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$MilestoneSummaryImplToJson(
        _$MilestoneSummaryImpl instance) =>
    <String, dynamic>{
      'recentMilestones':
          instance.recentMilestones.map((e) => e.toJson()).toList(),
      'allMilestones': instance.allMilestones.map((e) => e.toJson()).toList(),
      'totalCount': instance.totalCount,
      'newCount': instance.newCount,
      'countByType': instance.countByType
          .map((k, e) => MapEntry(_$MilestoneTypeEnumMap[k]!, e)),
    };
