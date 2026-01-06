// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      workoutsThisWeek: (json['workoutsThisWeek'] as num?)?.toInt() ?? 0,
      workoutsThisMonth: (json['workoutsThisMonth'] as num?)?.toInt() ?? 0,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      habitsCompleted: (json['habitsCompleted'] as num?)?.toInt() ?? 0,
      totalHabits: (json['totalHabits'] as num?)?.toInt() ?? 0,
      habitCompletionRate:
          (json['habitCompletionRate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      stepsToday: (json['stepsToday'] as num?)?.toInt() ?? 0,
      hoursSlept: (json['hoursSlept'] as num?)?.toDouble() ?? 0.0,
      lastWorkoutDate: json['lastWorkoutDate'] == null
          ? null
          : DateTime.parse(json['lastWorkoutDate'] as String),
      lastActivityDate: json['lastActivityDate'] == null
          ? null
          : DateTime.parse(json['lastActivityDate'] as String),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'workoutsThisWeek': instance.workoutsThisWeek,
      'workoutsThisMonth': instance.workoutsThisMonth,
      'totalWorkouts': instance.totalWorkouts,
      'habitsCompleted': instance.habitsCompleted,
      'totalHabits': instance.totalHabits,
      'habitCompletionRate': instance.habitCompletionRate,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'stepsToday': instance.stepsToday,
      'hoursSlept': instance.hoursSlept,
      'lastWorkoutDate': instance.lastWorkoutDate?.toIso8601String(),
      'lastActivityDate': instance.lastActivityDate?.toIso8601String(),
    };

_$ActivityItemImpl _$$ActivityItemImplFromJson(Map<String, dynamic> json) =>
    _$ActivityItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      value: json['value'] as String?,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$ActivityItemImplToJson(_$ActivityItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.workout: 'workout',
  ActivityType.habit: 'habit',
  ActivityType.sleep: 'sleep',
  ActivityType.steps: 'steps',
  ActivityType.weight: 'weight',
  ActivityType.mood: 'mood',
  ActivityType.nutrition: 'nutrition',
  ActivityType.other: 'other',
};

_$TodayPlanItemImpl _$$TodayPlanItemImplFromJson(Map<String, dynamic> json) =>
    _$TodayPlanItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      type: $enumDecode(_$PlanItemTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$TodayPlanItemImplToJson(_$TodayPlanItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'type': _$PlanItemTypeEnumMap[instance.type]!,
    };

const _$PlanItemTypeEnumMap = {
  PlanItemType.workout: 'workout',
  PlanItemType.habit: 'habit',
  PlanItemType.meditation: 'meditation',
  PlanItemType.walk: 'walk',
  PlanItemType.meal: 'meal',
  PlanItemType.other: 'other',
};
