import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'personal_best.freezed.dart';
part 'personal_best.g.dart';

/// Categories for personal bests
enum PersonalBestCategory {
  weight,      // Lowest/highest weight
  workout,     // Workout records
  strength,    // Exercise PRs
  cardio,      // Cardio achievements
  streak,      // Consistency records
  habit,       // Habit completions
}

extension PersonalBestCategoryX on PersonalBestCategory {
  String get displayName {
    switch (this) {
      case PersonalBestCategory.weight:
        return 'Weight';
      case PersonalBestCategory.workout:
        return 'Workouts';
      case PersonalBestCategory.strength:
        return 'Strength';
      case PersonalBestCategory.cardio:
        return 'Cardio';
      case PersonalBestCategory.streak:
        return 'Streaks';
      case PersonalBestCategory.habit:
        return 'Habits';
    }
  }

  String get icon {
    switch (this) {
      case PersonalBestCategory.weight:
        return 'monitor_weight';
      case PersonalBestCategory.workout:
        return 'fitness_center';
      case PersonalBestCategory.strength:
        return 'sports_gymnastics';
      case PersonalBestCategory.cardio:
        return 'directions_run';
      case PersonalBestCategory.streak:
        return 'local_fire_department';
      case PersonalBestCategory.habit:
        return 'check_circle';
    }
  }
}

/// Represents a personal best/record achievement
@freezed
class PersonalBest with _$PersonalBest {
  const PersonalBest._();

  const factory PersonalBest({
    required String id,
    required String userId,
    required PersonalBestCategory category,
    required String title,        // e.g., "Heaviest Bench Press"
    required String metric,       // e.g., "Bench Press", "5K Run"
    required double value,        // The record value
    required String unit,         // e.g., "kg", "lbs", "min", "days"
    @TimestampConverter() required DateTime achievedAt,
    @TimestampConverter() required DateTime createdAt,
    double? previousValue,        // Previous best for comparison
    @TimestampConverter() DateTime? previousDate,
    String? notes,
    String? workoutLogId,         // Reference to the workout where PR was set
  }) = _PersonalBest;

  factory PersonalBest.fromJson(Map<String, dynamic> json) =>
      _$PersonalBestFromJson(json);

  /// Whether this is a new record (has improvement)
  bool get isNewRecord => previousValue == null || value > previousValue!;

  /// Improvement percentage from previous record
  double get improvementPercentage {
    if (previousValue == null || previousValue == 0) return 0;
    return ((value - previousValue!) / previousValue! * 100);
  }

  /// Improvement amount from previous record
  double get improvementAmount {
    if (previousValue == null) return 0;
    return value - previousValue!;
  }
}

/// Summary of all personal bests for a user
@freezed
class PersonalBestsSummary with _$PersonalBestsSummary {
  const factory PersonalBestsSummary({
    required List<PersonalBest> recentPRs,     // Last 5 PRs
    required List<PersonalBest> allTimeBests,  // All-time records by category
    required int totalPRCount,
    required int monthlyPRCount,
    @Default({}) Map<PersonalBestCategory, int> prsByCategory,
  }) = _PersonalBestsSummary;

  factory PersonalBestsSummary.fromJson(Map<String, dynamic> json) =>
      _$PersonalBestsSummaryFromJson(json);

  factory PersonalBestsSummary.empty() => const PersonalBestsSummary(
        recentPRs: [],
        allTimeBests: [],
        totalPRCount: 0,
        monthlyPRCount: 0,
        prsByCategory: {},
      );
}

/// Represents a strength exercise PR
@freezed
class ExercisePR with _$ExercisePR {
  const factory ExercisePR({
    required String exerciseName,
    required double weight,        // in kg
    required int reps,
    @TimestampConverter() required DateTime achievedAt,
    double? previousWeight,
    int? previousReps,
    @TimestampConverter() DateTime? previousDate,
  }) = _ExercisePR;

  factory ExercisePR.fromJson(Map<String, dynamic> json) =>
      _$ExercisePRFromJson(json);
}
