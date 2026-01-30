import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/food_item.dart';

void main() {
  group('FoodCategory', () {
    group('displayName', () {
      test('returns correct display name for protein', () {
        expect(FoodCategory.protein.displayName, 'Protein');
      });

      test('returns correct display name for grains', () {
        expect(FoodCategory.grains.displayName, 'Grains');
      });

      test('returns correct display name for vegetables', () {
        expect(FoodCategory.vegetables.displayName, 'Vegetables');
      });

      test('returns correct display name for fruits', () {
        expect(FoodCategory.fruits.displayName, 'Fruits');
      });

      test('returns correct display name for dairy', () {
        expect(FoodCategory.dairy.displayName, 'Dairy');
      });

      test('returns correct display name for fats', () {
        expect(FoodCategory.fats.displayName, 'Fats & Oils');
      });

      test('returns correct display name for snacks', () {
        expect(FoodCategory.snacks.displayName, 'Snacks');
      });

      test('returns correct display name for beverages', () {
        expect(FoodCategory.beverages.displayName, 'Beverages');
      });

      test('returns correct display name for other', () {
        expect(FoodCategory.other.displayName, 'Other');
      });

      test('all categories have unique display names', () {
        final displayNames = FoodCategory.values.map((c) => c.displayName).toList();
        expect(displayNames.toSet().length, displayNames.length);
      });
    });
  });

  group('FoodItem', () {
    test('creates instance with required fields', () {
      const item = FoodItem(
        id: 'food-1',
        name: 'Chicken Breast',
        userId: 'user-1',
      );

      expect(item.id, 'food-1');
      expect(item.name, 'Chicken Breast');
      expect(item.userId, 'user-1');
    });

    test('has correct default values', () {
      const item = FoodItem(
        id: 'food-1',
        name: 'Chicken Breast',
        userId: 'user-1',
      );

      expect(item.calories, 0.0);
      expect(item.proteinGrams, 0.0);
      expect(item.carbsGrams, 0.0);
      expect(item.fatGrams, 0.0);
      expect(item.fiberGrams, 0.0);
      expect(item.sugarGrams, 0.0);
      expect(item.servingSizeGrams, 100.0);
      expect(item.isCustom, isFalse);
      expect(item.isVerified, isFalse);
    });

    test('creates instance with all fields', () {
      const item = FoodItem(
        id: 'food-1',
        name: 'Chicken Breast',
        userId: 'user-1',
        calories: 165.0,
        proteinGrams: 31.0,
        carbsGrams: 0.0,
        fatGrams: 3.6,
        fiberGrams: 0.0,
        sugarGrams: 0.0,
        servingSizeGrams: 100.0,
        servingSizeUnit: 'piece',
        brand: 'Generic',
        barcode: '123456789',
        isCustom: true,
        isVerified: true,
        category: FoodCategory.protein,
      );

      expect(item.calories, 165.0);
      expect(item.proteinGrams, 31.0);
      expect(item.fatGrams, 3.6);
      expect(item.servingSizeUnit, 'piece');
      expect(item.brand, 'Generic');
      expect(item.barcode, '123456789');
      expect(item.isCustom, isTrue);
      expect(item.isVerified, isTrue);
      expect(item.category, FoodCategory.protein);
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = FoodItem(
          id: 'food-1',
          name: 'Chicken Breast',
          userId: 'user-1',
          calories: 165.0,
        );

        final copy = original.copyWith(
          name: 'Grilled Chicken',
          calories: 180.0,
        );

        expect(copy.id, 'food-1');
        expect(copy.name, 'Grilled Chicken');
        expect(copy.calories, 180.0);
      });
    });
  });
}
