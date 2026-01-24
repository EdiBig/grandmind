// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakDataImpl _$$StreakDataImplFromJson(Map<String, dynamic> json) =>
    _$StreakDataImpl(
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      totalActiveDays: (json['totalActiveDays'] as num).toInt(),
      lastActiveDate:
          const NullableTimestampConverter().fromJson(json['lastActiveDate']),
      activeDatesThisMonth: (json['activeDatesThisMonth'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          const [],
      graceDays: (json['graceDays'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$StreakDataImplToJson(_$StreakDataImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalActiveDays': instance.totalActiveDays,
      'lastActiveDate':
          const NullableTimestampConverter().toJson(instance.lastActiveDate),
      'activeDatesThisMonth': instance.activeDatesThisMonth
          .map((e) => e.toIso8601String())
          .toList(),
      'graceDays': instance.graceDays,
    };

_$ActivityDayImpl _$$ActivityDayImplFromJson(Map<String, dynamic> json) =>
    _$ActivityDayImpl(
      date: const TimestampConverter().fromJson(json['date']),
      workoutCount: (json['workoutCount'] as num).toInt(),
      habitsCompleted: (json['habitsCompleted'] as num).toInt(),
      habitsTotal: (json['habitsTotal'] as num).toInt(),
      weightLogged: json['weightLogged'] as bool,
      measurementsLogged: json['measurementsLogged'] as bool,
      activityScore: (json['activityScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ActivityDayImplToJson(_$ActivityDayImpl instance) =>
    <String, dynamic>{
      'date': const TimestampConverter().toJson(instance.date),
      'workoutCount': instance.workoutCount,
      'habitsCompleted': instance.habitsCompleted,
      'habitsTotal': instance.habitsTotal,
      'weightLogged': instance.weightLogged,
      'measurementsLogged': instance.measurementsLogged,
      'activityScore': instance.activityScore,
    };
