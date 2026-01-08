import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';
import 'meal.dart';
import 'nutrition_goal.dart';

part 'daily_nutrition_summary.freezed.dart';
part 'daily_nutrition_summary.g.dart';

/// Daily nutrition summary aggregating all meals and water intake for a specific day
/// Used for dashboard display and progress tracking
@freezed
class DailyNutritionSummary with _$DailyNutritionSummary {
  const factory DailyNutritionSummary({
    required String userId,
    @TimestampConverter() required DateTime date, // Day being summarized
    @Default(0.0) double totalCalories,
    @Default(0.0) double totalProtein,
    @Default(0.0) double totalCarbs,
    @Default(0.0) double totalFat,
    @Default(0) int waterGlasses,
    @Default(0) int mealsLogged, // Number of meals logged this day
    Map<MealType, double>? caloriesByMeal, // Calories breakdown by meal type
    NutritionGoal? goal, // User's nutrition goal for comparison
  }) = _DailyNutritionSummary;

  const DailyNutritionSummary._();

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyNutritionSummaryFromJson(json);

  // ========== Progress Calculations ==========

  /// Calculate calories progress percentage (0-150%, clamped)
  double get caloriesProgress => goal != null
      ? (totalCalories / goal!.dailyCalories * 100).clamp(0, 150)
      : 0;

  /// Calculate protein progress percentage
  double get proteinProgress => goal != null
      ? (totalProtein / goal!.dailyProteinGrams * 100).clamp(0, 150)
      : 0;

  /// Calculate carbs progress percentage
  double get carbsProgress => goal != null
      ? (totalCarbs / goal!.dailyCarbsGrams * 100).clamp(0, 150)
      : 0;

  /// Calculate fat progress percentage
  double get fatProgress => goal != null
      ? (totalFat / goal!.dailyFatGrams * 100).clamp(0, 150)
      : 0;

  /// Calculate water progress percentage
  double get waterProgress => goal != null
      ? (waterGlasses / goal!.dailyWaterGlasses * 100).clamp(0, 100)
      : 0;

  // ========== Goal Achievement Checks ==========

  /// Check if calories are on track (within 90-110% of goal)
  bool get caloriesOnTrack =>
      caloriesProgress >= 90 && caloriesProgress <= 110;

  /// Check if all macros are at least 80% achieved
  bool get macrosBalanced =>
      proteinProgress >= 80 && carbsProgress >= 80 && fatProgress >= 80;

  /// Check if water goal is achieved
  bool get waterGoalAchieved => goal != null && waterGlasses >= goal!.dailyWaterGlasses;

  /// Check if all goals are achieved (calories on track, macros balanced, water achieved)
  bool get allGoalsAchieved =>
      caloriesOnTrack && macrosBalanced && waterGoalAchieved;

  // ========== Remaining Calculations ==========

  /// Calculate remaining calories to reach goal
  double get remainingCalories =>
      goal != null ? (goal!.dailyCalories - totalCalories).clamp(0, goal!.dailyCalories) : 0;

  /// Calculate remaining protein to reach goal
  double get remainingProtein => goal != null
      ? (goal!.dailyProteinGrams - totalProtein).clamp(0, goal!.dailyProteinGrams)
      : 0;

  /// Calculate remaining carbs to reach goal
  double get remainingCarbs => goal != null
      ? (goal!.dailyCarbsGrams - totalCarbs).clamp(0, goal!.dailyCarbsGrams)
      : 0;

  /// Calculate remaining fat to reach goal
  double get remainingFat => goal != null
      ? (goal!.dailyFatGrams - totalFat).clamp(0, goal!.dailyFatGrams)
      : 0;

  /// Calculate remaining water glasses to reach goal
  int get remainingWater => goal != null
      ? (goal!.dailyWaterGlasses - waterGlasses).clamp(0, goal!.dailyWaterGlasses)
      : 0;

  // ========== Status Messages ==========

  /// Get a user-friendly status message for calories
  String get caloriesStatus {
    if (goal == null) return 'No goal set';
    if (caloriesOnTrack) return 'On track!';
    if (caloriesProgress < 90) return 'Below target';
    if (caloriesProgress > 110) return 'Above target';
    return 'On track!';
  }

  /// Get overall progress summary text
  String get progressSummary {
    if (goal == null) return 'Set your nutrition goals to track progress';
    if (allGoalsAchieved) return 'All goals achieved! 🎉';
    if (mealsLogged == 0) return 'No meals logged today';

    final achievedCount = [
      caloriesOnTrack,
      macrosBalanced,
      waterGoalAchieved,
    ].where((achieved) => achieved).length;

    return '$achievedCount/3 goals achieved';
  }
}
