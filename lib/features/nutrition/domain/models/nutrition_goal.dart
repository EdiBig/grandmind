import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'nutrition_goal.freezed.dart';
part 'nutrition_goal.g.dart';

/// User's daily nutrition goals/targets
/// Used to track progress and provide insights
@freezed
class NutritionGoal with _$NutritionGoal {
  const factory NutritionGoal({
    required String id,
    required String userId,
    @Default(2000.0) double dailyCalories,
    @Default(150.0) double dailyProteinGrams,
    @Default(250.0) double dailyCarbsGrams,
    @Default(65.0) double dailyFatGrams,
    @Default(8) int dailyWaterGlasses,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    @Default(true) bool isActive,
  }) = _NutritionGoal;

  const NutritionGoal._();

  factory NutritionGoal.fromJson(Map<String, dynamic> json) =>
      _$NutritionGoalFromJson(json);

  /// Calculate total daily macros in calories
  /// Protein = 4 cal/g, Carbs = 4 cal/g, Fat = 9 cal/g
  double get proteinCalories => dailyProteinGrams * 4;
  double get carbsCalories => dailyCarbsGrams * 4;
  double get fatCalories => dailyFatGrams * 9;
  double get totalMacroCalories => proteinCalories + carbsCalories + fatCalories;

  /// Calculate macro distribution percentages
  double get proteinPercentage => (proteinCalories / dailyCalories * 100).clamp(0, 100);
  double get carbsPercentage => (carbsCalories / dailyCalories * 100).clamp(0, 100);
  double get fatPercentage => (fatCalories / dailyCalories * 100).clamp(0, 100);

  /// Check if macro goals are balanced (totals match daily calories within 10%)
  bool get isBalanced {
    final difference = (totalMacroCalories - dailyCalories).abs();
    return difference / dailyCalories <= 0.1; // Within 10%
  }
}
