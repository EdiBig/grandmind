import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

/// Workout template model
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    required String description,
    required WorkoutDifficulty difficulty,
    required int estimatedDuration, // in minutes
    required List<Exercise> exercises,
    required WorkoutCategory category,
    String? imageUrl,
    List<String>? tags,
    int? caloriesBurned,
    String? equipment,
    DateTime? createdAt,
    String? createdBy, // userId if user-created, null for templates
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}

/// Workout difficulty levels
enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return 'Beginner';
      case WorkoutDifficulty.intermediate:
        return 'Intermediate';
      case WorkoutDifficulty.advanced:
        return 'Advanced';
    }
  }
}

/// Workout categories
enum WorkoutCategory {
  strength,
  cardio,
  flexibility,
  hiit,
  yoga,
  sports,
  other;

  String get displayName {
    switch (this) {
      case WorkoutCategory.strength:
        return 'Strength';
      case WorkoutCategory.cardio:
        return 'Cardio';
      case WorkoutCategory.flexibility:
        return 'Flexibility';
      case WorkoutCategory.hiit:
        return 'HIIT';
      case WorkoutCategory.yoga:
        return 'Yoga';
      case WorkoutCategory.sports:
        return 'Sports';
      case WorkoutCategory.other:
        return 'Other';
    }
  }
}
