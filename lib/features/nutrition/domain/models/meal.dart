import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';
import 'food_item.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

/// Meal model representing a logged meal (breakfast, lunch, dinner, or snack)
/// Contains multiple food items (MealEntry) with their serving sizes
@freezed
class Meal with _$Meal {
  @JsonSerializable(explicitToJson: true)
  const factory Meal({
    required String id,
    required String userId,
    required MealType mealType,
    @TimestampConverter() required DateTime mealDate, // Normalized to start of day for querying
    @TimestampConverter() required DateTime loggedAt, // Actual timestamp when logged
    required List<MealEntry> entries, // Food items in this meal
    String? notes,
    String? photoUrl, // Firebase Storage URL for meal photo
    @Default(0.0) double totalCalories,
    @Default(0.0) double totalProtein,
    @Default(0.0) double totalCarbs,
    @Default(0.0) double totalFat,
  }) = _Meal;

  const Meal._();

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  /// Calculate nutritional totals from all meal entries
  Meal calculateTotals() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (var entry in entries) {
      final multiplier = entry.servings;
      calories += entry.foodItem.calories * multiplier;
      protein += entry.foodItem.proteinGrams * multiplier;
      carbs += entry.foodItem.carbsGrams * multiplier;
      fat += entry.foodItem.fatGrams * multiplier;
    }

    return copyWith(
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
    );
  }
}

/// A single food item within a meal, with serving size
@freezed
class MealEntry with _$MealEntry {
  @JsonSerializable(explicitToJson: true)
  const factory MealEntry({
    required FoodItem foodItem,
    @Default(1.0) double servings, // Number of servings consumed
    String? customServingSize, // Optional: e.g., "1 medium apple", "2 slices"
  }) = _MealEntry;

  factory MealEntry.fromJson(Map<String, dynamic> json) =>
      _$MealEntryFromJson(json);
}

/// Type of meal
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  /// Get icon for each meal type
  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}
