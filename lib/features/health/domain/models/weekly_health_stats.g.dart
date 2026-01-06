// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_health_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyHealthStatsImpl _$$WeeklyHealthStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyHealthStatsImpl(
      totalSteps: (json['totalSteps'] as num).toInt(),
      totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num).toDouble(),
      averageSleepHours: (json['averageSleepHours'] as num).toDouble(),
      daysWithData: (json['daysWithData'] as num).toInt(),
      weekStartDate: const TimestampConverter().fromJson(json['weekStartDate']),
      weekEndDate: const TimestampConverter().fromJson(json['weekEndDate']),
    );

Map<String, dynamic> _$$WeeklyHealthStatsImplToJson(
        _$WeeklyHealthStatsImpl instance) =>
    <String, dynamic>{
      'totalSteps': instance.totalSteps,
      'totalDistanceKm': instance.totalDistanceKm,
      'totalCalories': instance.totalCalories,
      'averageHeartRate': instance.averageHeartRate,
      'averageSleepHours': instance.averageSleepHours,
      'daysWithData': instance.daysWithData,
      'weekStartDate':
          const TimestampConverter().toJson(instance.weekStartDate),
      'weekEndDate': const TimestampConverter().toJson(instance.weekEndDate),
    };

_$DailyHealthPointImpl _$$DailyHealthPointImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyHealthPointImpl(
      date: const TimestampConverter().fromJson(json['date']),
      steps: (json['steps'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      sleepHours: (json['sleepHours'] as num).toDouble(),
    );

Map<String, dynamic> _$$DailyHealthPointImplToJson(
        _$DailyHealthPointImpl instance) =>
    <String, dynamic>{
      'date': const TimestampConverter().toJson(instance.date),
      'steps': instance.steps,
      'distanceKm': instance.distanceKm,
      'calories': instance.calories,
      'heartRate': instance.heartRate,
      'sleepHours': instance.sleepHours,
    };
