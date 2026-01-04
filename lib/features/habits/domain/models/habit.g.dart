// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      frequency: $enumDecode(_$HabitFrequencyEnumMap, json['frequency']),
      icon: $enumDecode(_$HabitIconEnumMap, json['icon']),
      color: $enumDecode(_$HabitColorEnumMap, json['color']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      lastCompletedAt:
          const NullableTimestampConverter().fromJson(json['lastCompletedAt']),
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'frequency': _$HabitFrequencyEnumMap[instance.frequency]!,
      'icon': _$HabitIconEnumMap[instance.icon]!,
      'color': _$HabitColorEnumMap[instance.color]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
      'targetCount': instance.targetCount,
      'unit': instance.unit,
      'daysOfWeek': instance.daysOfWeek,
      'lastCompletedAt':
          const NullableTimestampConverter().toJson(instance.lastCompletedAt),
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
    };

const _$HabitFrequencyEnumMap = {
  HabitFrequency.daily: 'daily',
  HabitFrequency.weekly: 'weekly',
  HabitFrequency.custom: 'custom',
};

const _$HabitIconEnumMap = {
  HabitIcon.water: 'water',
  HabitIcon.sleep: 'sleep',
  HabitIcon.meditation: 'meditation',
  HabitIcon.walk: 'walk',
  HabitIcon.read: 'read',
  HabitIcon.exercise: 'exercise',
  HabitIcon.food: 'food',
  HabitIcon.pill: 'pill',
  HabitIcon.study: 'study',
  HabitIcon.clean: 'clean',
  HabitIcon.other: 'other',
};

const _$HabitColorEnumMap = {
  HabitColor.blue: 'blue',
  HabitColor.purple: 'purple',
  HabitColor.pink: 'pink',
  HabitColor.red: 'red',
  HabitColor.orange: 'orange',
  HabitColor.yellow: 'yellow',
  HabitColor.green: 'green',
  HabitColor.teal: 'teal',
};
