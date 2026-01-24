// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_best.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonalBestImpl _$$PersonalBestImplFromJson(Map<String, dynamic> json) =>
    _$PersonalBestImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: $enumDecode(_$PersonalBestCategoryEnumMap, json['category']),
      title: json['title'] as String,
      metric: json['metric'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      achievedAt: const TimestampConverter().fromJson(json['achievedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      previousValue: (json['previousValue'] as num?)?.toDouble(),
      previousDate: const TimestampConverter().fromJson(json['previousDate']),
      notes: json['notes'] as String?,
      workoutLogId: json['workoutLogId'] as String?,
    );

Map<String, dynamic> _$$PersonalBestImplToJson(_$PersonalBestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': _$PersonalBestCategoryEnumMap[instance.category]!,
      'title': instance.title,
      'metric': instance.metric,
      'value': instance.value,
      'unit': instance.unit,
      'achievedAt': const TimestampConverter().toJson(instance.achievedAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'previousValue': instance.previousValue,
      'previousDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.previousDate, const TimestampConverter().toJson),
      'notes': instance.notes,
      'workoutLogId': instance.workoutLogId,
    };

const _$PersonalBestCategoryEnumMap = {
  PersonalBestCategory.weight: 'weight',
  PersonalBestCategory.workout: 'workout',
  PersonalBestCategory.strength: 'strength',
  PersonalBestCategory.cardio: 'cardio',
  PersonalBestCategory.streak: 'streak',
  PersonalBestCategory.habit: 'habit',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$PersonalBestsSummaryImpl _$$PersonalBestsSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$PersonalBestsSummaryImpl(
      recentPRs: (json['recentPRs'] as List<dynamic>)
          .map((e) => PersonalBest.fromJson(e as Map<String, dynamic>))
          .toList(),
      allTimeBests: (json['allTimeBests'] as List<dynamic>)
          .map((e) => PersonalBest.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPRCount: (json['totalPRCount'] as num).toInt(),
      monthlyPRCount: (json['monthlyPRCount'] as num).toInt(),
      prsByCategory: (json['prsByCategory'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry($enumDecode(_$PersonalBestCategoryEnumMap, k),
                (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$PersonalBestsSummaryImplToJson(
        _$PersonalBestsSummaryImpl instance) =>
    <String, dynamic>{
      'recentPRs': instance.recentPRs.map((e) => e.toJson()).toList(),
      'allTimeBests': instance.allTimeBests.map((e) => e.toJson()).toList(),
      'totalPRCount': instance.totalPRCount,
      'monthlyPRCount': instance.monthlyPRCount,
      'prsByCategory': instance.prsByCategory
          .map((k, e) => MapEntry(_$PersonalBestCategoryEnumMap[k]!, e)),
    };

_$ExercisePRImpl _$$ExercisePRImplFromJson(Map<String, dynamic> json) =>
    _$ExercisePRImpl(
      exerciseName: json['exerciseName'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      achievedAt: const TimestampConverter().fromJson(json['achievedAt']),
      previousWeight: (json['previousWeight'] as num?)?.toDouble(),
      previousReps: (json['previousReps'] as num?)?.toInt(),
      previousDate: const TimestampConverter().fromJson(json['previousDate']),
    );

Map<String, dynamic> _$$ExercisePRImplToJson(_$ExercisePRImpl instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'weight': instance.weight,
      'reps': instance.reps,
      'achievedAt': const TimestampConverter().toJson(instance.achievedAt),
      'previousWeight': instance.previousWeight,
      'previousReps': instance.previousReps,
      'previousDate': _$JsonConverterToJson<dynamic, DateTime>(
          instance.previousDate, const TimestampConverter().toJson),
    };
