import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'food_item.freezed.dart';
part 'food_item.g.dart';

/// Food item model for nutrition tracking
/// Represents a food/ingredient that can be added to meals
@freezed
class FoodItem with _$FoodItem {
  const factory FoodItem({
    required String id,
    required String name,
    required String userId,
    @Default(0.0) double calories,
    @Default(0.0) double proteinGrams,
    @Default(0.0) double carbsGrams,
    @Default(0.0) double fatGrams,
    @Default(0.0) double fiberGrams,
    @Default(0.0) double sugarGrams,
    @Default(100.0) double servingSizeGrams,
    String? servingSizeUnit, // e.g., "cup", "tbsp", "piece", "ml"
    String? brand,
    String? barcode, // For future barcode scanning feature
    @Default(false) bool isCustom, // User-created custom food
    @Default(false) bool isVerified, // Admin-verified food from database
    FoodCategory? category,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
}

/// Food categories for organization and filtering
enum FoodCategory {
  protein,
  grains,
  vegetables,
  fruits,
  dairy,
  fats,
  snacks,
  beverages,
  other;

  String get displayName {
    switch (this) {
      case FoodCategory.protein:
        return 'Protein';
      case FoodCategory.grains:
        return 'Grains';
      case FoodCategory.vegetables:
        return 'Vegetables';
      case FoodCategory.fruits:
        return 'Fruits';
      case FoodCategory.dairy:
        return 'Dairy';
      case FoodCategory.fats:
        return 'Fats & Oils';
      case FoodCategory.snacks:
        return 'Snacks';
      case FoodCategory.beverages:
        return 'Beverages';
      case FoodCategory.other:
        return 'Other';
    }
  }
}
