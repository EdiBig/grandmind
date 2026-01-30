import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/meal.dart';
import 'package:kinesa/features/nutrition/domain/models/food_item.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);
  final testTime = DateTime(2024, 1, 15, 12, 30);

  group('MealType', () {
    group('displayName', () {
      test('returns correct display name for breakfast', () {
        expect(MealType.breakfast.displayName, 'Breakfast');
      });

      test('returns correct display name for lunch', () {
        expect(MealType.lunch.displayName, 'Lunch');
      });

      test('returns correct display name for dinner', () {
        expect(MealType.dinner.displayName, 'Dinner');
      });

      test('returns correct display name for snack', () {
        expect(MealType.snack.displayName, 'Snack');
      });
    });

    group('emoji', () {
      test('returns correct emoji for breakfast', () {
        expect(MealType.breakfast.emoji, '🌅');
      });

      test('returns correct emoji for lunch', () {
        expect(MealType.lunch.emoji, '☀️');
      });

      test('returns correct emoji for dinner', () {
        expect(MealType.dinner.emoji, '🌙');
      });

      test('returns correct emoji for snack', () {
        expect(MealType.snack.emoji, '🍎');
      });
    });
  });

  group('MealEntry', () {
    test('creates instance with required food item', () {
      const foodItem = FoodItem(
        id: 'food-1',
        name: 'Chicken Breast',
        userId: 'user-1',
        calories: 165.0,
        proteinGrams: 31.0,
      );

      const entry = MealEntry(foodItem: foodItem);

      expect(entry.foodItem, foodItem);
      expect(entry.servings, 1.0); // Default
    });

    test('creates instance with custom servings', () {
      const foodItem = FoodItem(
        id: 'food-1',
        name: 'Chicken Breast',
        userId: 'user-1',
      );

      const entry = MealEntry(
        foodItem: foodItem,
        servings: 2.5,
        customServingSize: '250g',
      );

      expect(entry.servings, 2.5);
      expect(entry.customServingSize, '250g');
    });
  });

  group('Meal', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final meal = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.lunch,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [],
        );

        expect(meal.id, 'meal-1');
        expect(meal.userId, 'user-1');
        expect(meal.mealType, MealType.lunch);
        expect(meal.mealDate, testDate);
        expect(meal.loggedAt, testTime);
        expect(meal.entries, isEmpty);
      });

      test('has correct default values', () {
        final meal = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.lunch,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [],
        );

        expect(meal.totalCalories, 0.0);
        expect(meal.totalProtein, 0.0);
        expect(meal.totalCarbs, 0.0);
        expect(meal.totalFat, 0.0);
        expect(meal.notes, isNull);
        expect(meal.photoUrl, isNull);
      });
    });

    group('calculateTotals', () {
      test('calculates totals from food entries', () {
        const chicken = FoodItem(
          id: 'food-1',
          name: 'Chicken Breast',
          userId: 'user-1',
          calories: 165.0,
          proteinGrams: 31.0,
          carbsGrams: 0.0,
          fatGrams: 3.6,
        );

        const rice = FoodItem(
          id: 'food-2',
          name: 'White Rice',
          userId: 'user-1',
          calories: 130.0,
          proteinGrams: 2.7,
          carbsGrams: 28.0,
          fatGrams: 0.3,
        );

        final meal = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.lunch,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [
            MealEntry(foodItem: chicken, servings: 1.0),
            MealEntry(foodItem: rice, servings: 2.0),
          ],
        );

        final calculatedMeal = meal.calculateTotals();

        // Chicken: 165 cal, 31g protein, 0g carbs, 3.6g fat
        // Rice * 2: 260 cal, 5.4g protein, 56g carbs, 0.6g fat
        // Total: 425 cal, 36.4g protein, 56g carbs, 4.2g fat
        expect(calculatedMeal.totalCalories, closeTo(425.0, 0.1));
        expect(calculatedMeal.totalProtein, closeTo(36.4, 0.1));
        expect(calculatedMeal.totalCarbs, closeTo(56.0, 0.1));
        expect(calculatedMeal.totalFat, closeTo(4.2, 0.1));
      });

      test('returns zero totals for empty entries', () {
        final meal = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.lunch,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [],
        );

        final calculatedMeal = meal.calculateTotals();

        expect(calculatedMeal.totalCalories, 0.0);
        expect(calculatedMeal.totalProtein, 0.0);
        expect(calculatedMeal.totalCarbs, 0.0);
        expect(calculatedMeal.totalFat, 0.0);
      });

      test('handles fractional servings', () {
        const food = FoodItem(
          id: 'food-1',
          name: 'Banana',
          userId: 'user-1',
          calories: 100.0,
          proteinGrams: 1.0,
          carbsGrams: 25.0,
          fatGrams: 0.5,
        );

        final meal = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.snack,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [
            MealEntry(foodItem: food, servings: 0.5),
          ],
        );

        final calculatedMeal = meal.calculateTotals();

        expect(calculatedMeal.totalCalories, 50.0); // 100 * 0.5
        expect(calculatedMeal.totalProtein, 0.5); // 1 * 0.5
        expect(calculatedMeal.totalCarbs, 12.5); // 25 * 0.5
        expect(calculatedMeal.totalFat, 0.25); // 0.5 * 0.5
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Meal(
          id: 'meal-1',
          userId: 'user-1',
          mealType: MealType.lunch,
          mealDate: testDate,
          loggedAt: testTime,
          entries: const [],
        );

        final copy = original.copyWith(
          notes: 'Delicious meal!',
          totalCalories: 500.0,
        );

        expect(copy.id, 'meal-1'); // Unchanged
        expect(copy.mealType, MealType.lunch); // Unchanged
        expect(copy.notes, 'Delicious meal!'); // Changed
        expect(copy.totalCalories, 500.0); // Changed
      });
    });
  });
}
