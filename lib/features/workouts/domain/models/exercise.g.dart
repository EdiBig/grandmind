// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      equipment: json['equipment'] as String?,
      metrics: json['metrics'] == null
          ? null
          : ExerciseMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'imageUrl': instance.imageUrl,
      'type': _$ExerciseTypeEnumMap[instance.type]!,
      'muscleGroups': instance.muscleGroups,
      'equipment': instance.equipment,
      'metrics': instance.metrics,
    };

const _$ExerciseTypeEnumMap = {
  ExerciseType.reps: 'reps',
  ExerciseType.duration: 'duration',
  ExerciseType.distance: 'distance',
};

_$ExerciseMetricsImpl _$$ExerciseMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$ExerciseMetricsImpl(
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      restTime: (json['restTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ExerciseMetricsImplToJson(
        _$ExerciseMetricsImpl instance) =>
    <String, dynamic>{
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'distance': instance.distance,
      'weight': instance.weight,
      'restTime': instance.restTime,
    };
