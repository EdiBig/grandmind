// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutImpl _$$WorkoutImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      difficulty: $enumDecode(_$WorkoutDifficultyEnumMap, json['difficulty']),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: $enumDecode(_$WorkoutCategoryEnumMap, json['category']),
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      equipment: json['equipment'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$$WorkoutImplToJson(_$WorkoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'difficulty': _$WorkoutDifficultyEnumMap[instance.difficulty]!,
      'estimatedDuration': instance.estimatedDuration,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'category': _$WorkoutCategoryEnumMap[instance.category]!,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
      'caloriesBurned': instance.caloriesBurned,
      'equipment': instance.equipment,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
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
