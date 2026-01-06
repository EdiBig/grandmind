import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Exercise model
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required String description,
    String? videoUrl,
    String? imageUrl,
    required ExerciseType type,
    List<String>? muscleGroups,
    String? equipment,
    ExerciseMetrics? metrics,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// Exercise type
enum ExerciseType {
  reps,
  duration,
  distance;

  String get displayName {
    switch (this) {
      case ExerciseType.reps:
        return 'Reps';
      case ExerciseType.duration:
        return 'Duration';
      case ExerciseType.distance:
        return 'Distance';
    }
  }
}

/// Exercise metrics for tracking
@freezed
class ExerciseMetrics with _$ExerciseMetrics {
  const factory ExerciseMetrics({
    int? sets,
    int? reps,
    int? duration, // in seconds
    double? distance, // in km
    double? weight, // in kg
    int? restTime, // in seconds
  }) = _ExerciseMetrics;

  factory ExerciseMetrics.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMetricsFromJson(json);
}
