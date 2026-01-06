import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout.dart';
import 'exercise.dart';

part 'workout_log.freezed.dart';
part 'workout_log.g.dart';

/// Workout log model for completed workouts
@freezed
class WorkoutLog with _$WorkoutLog {
  const factory WorkoutLog({
    required String id,
    required String userId,
    required String workoutId,
    required String workoutName,
    required DateTime startedAt,
    DateTime? completedAt,
    required int duration, // actual duration in minutes
    required List<ExerciseLog> exercises,
    int? caloriesBurned,
    String? notes,
    WorkoutDifficulty? difficulty,
    WorkoutCategory? category,
  }) = _WorkoutLog;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogFromJson(json);
}

/// Exercise log for individual exercises in a workout
@freezed
class ExerciseLog with _$ExerciseLog {
  const factory ExerciseLog({
    required String exerciseId,
    required String exerciseName,
    required ExerciseType type,
    required List<SetLog> sets,
    String? notes,
  }) = _ExerciseLog;

  factory ExerciseLog.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogFromJson(json);
}

/// Set log for tracking individual sets
@freezed
class SetLog with _$SetLog {
  const factory SetLog({
    required int setNumber,
    int? reps,
    int? duration, // in seconds
    double? distance, // in km
    double? weight, // in kg
    bool? completed,
  }) = _SetLog;

  factory SetLog.fromJson(Map<String, dynamic> json) =>
      _$SetLogFromJson(json);
}
