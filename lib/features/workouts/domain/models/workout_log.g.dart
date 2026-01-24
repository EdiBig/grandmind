// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutLogImpl _$$WorkoutLogImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      startedAt: const TimestampConverter().fromJson(json['startedAt']),
      completedAt:
          const NullableTimestampConverter().fromJson(json['completedAt']),
      duration: (json['duration'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      difficulty:
          $enumDecodeNullable(_$WorkoutDifficultyEnumMap, json['difficulty']),
      category: $enumDecodeNullable(_$WorkoutCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$$WorkoutLogImplToJson(_$WorkoutLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'startedAt': const TimestampConverter().toJson(instance.startedAt),
      'completedAt':
          const NullableTimestampConverter().toJson(instance.completedAt),
      'duration': instance.duration,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'caloriesBurned': instance.caloriesBurned,
      'notes': instance.notes,
      'difficulty': _$WorkoutDifficultyEnumMap[instance.difficulty],
      'category': _$WorkoutCategoryEnumMap[instance.category],
    };

const _$WorkoutDifficultyEnumMap = {
  WorkoutDifficulty.beginner: 'beginner',
  WorkoutDifficulty.intermediate: 'intermediate',
  WorkoutDifficulty.advanced: 'advanced',
};

const _$WorkoutCategoryEnumMap = {
  WorkoutCategory.strength: 'strength',
  WorkoutCategory.cardio: 'cardio',
  WorkoutCategory.flexibility: 'flexibility',
  WorkoutCategory.hiit: 'hiit',
  WorkoutCategory.yoga: 'yoga',
  WorkoutCategory.sports: 'sports',
  WorkoutCategory.other: 'other',
};

_$ExerciseLogImpl _$$ExerciseLogImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseLogImpl(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ExerciseLogImplToJson(_$ExerciseLogImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'type': _$ExerciseTypeEnumMap[instance.type]!,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
    };

const _$ExerciseTypeEnumMap = {
  ExerciseType.reps: 'reps',
  ExerciseType.duration: 'duration',
  ExerciseType.distance: 'distance',
};

_$SetLogImpl _$$SetLogImplFromJson(Map<String, dynamic> json) => _$SetLogImpl(
      setNumber: (json['setNumber'] as num).toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      completed: json['completed'] as bool?,
    );

Map<String, dynamic> _$$SetLogImplToJson(_$SetLogImpl instance) =>
    <String, dynamic>{
      'setNumber': instance.setNumber,
      'reps': instance.reps,
      'duration': instance.duration,
      'distance': instance.distance,
      'weight': instance.weight,
      'completed': instance.completed,
    };
