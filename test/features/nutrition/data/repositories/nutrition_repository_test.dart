import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/meal.dart';
import 'package:kinesa/features/nutrition/domain/models/food_item.dart';
import 'package:kinesa/features/nutrition/domain/models/daily_nutrition_summary.dart';
import '../../../../helpers/test_fixtures.dart';

/// Note: NutritionRepository uses FirebaseFirestore.instance internally,
/// making it difficult to inject a fake Firestore for true unit tests.
///
/// These tests focus on:
/// 1. Testing model serialization/deserialization
/// 2. Testing calculation methods (like meal totals)
/// 3. Documenting expected repository behavior

void main() {
  group('NutritionRepository Model Tests', () {
    group('Meal Model', () {
      test('creates meal with required fields', () {
        final meal = createTestMeal(
          mealType: MealType.breakfast,
        );

        expect(meal.mealType, equals(MealType.breakfast));
        expect(meal.entries, isNotEmpty);
      });

      test('calculateTotals computes correct nutritional values', () {
        // Create a food item with known values
        final food = createTestFoodItem(
          calories: 200,
          proteinGrams: 20,
          carbsGrams: 25,
          fatGrams: 8,
        );

        final meal = Meal(
          id: 'meal-1',
          userId: testUserId,
          mealType: MealType.lunch,
          mealDate: DateTime.now(),
          loggedAt: DateTime.now(),
          entries: [
            MealEntry(foodItem: food, servings: 2.0),
          ],
        ).calculateTotals();

        // 2 servings * each value
        expect(meal.totalCalories, equals(400));
        expect(meal.totalProtein, equals(40));
        expect(meal.totalCarbs, equals(50));
        expect(meal.totalFat, equals(16));
      });

      test('calculateTotals handles multiple entries', () {
        final food1 = createTestFoodItem(
          id: 'food-1',
          calories: 100,
          proteinGrams: 10,
          carbsGrams: 15,
          fatGrams: 5,
        );
        final food2 = createTestFoodItem(
          id: 'food-2',
          calories: 150,
          proteinGrams: 8,
          carbsGrams: 20,
          fatGrams: 7,
        );

        final meal = Meal(
          id: 'meal-1',
          userId: testUserId,
          mealType: MealType.dinner,
          mealDate: DateTime.now(),
          loggedAt: DateTime.now(),
          entries: [
            MealEntry(foodItem: food1, servings: 1.0),
            MealEntry(foodItem: food2, servings: 1.0),
          ],
        ).calculateTotals();

        expect(meal.totalCalories, equals(250)); // 100 + 150
        expect(meal.totalProtein, equals(18)); // 10 + 8
        expect(meal.totalCarbs, equals(35)); // 15 + 20
        expect(meal.totalFat, equals(12)); // 5 + 7
      });

      test('calculateTotals handles empty entries', () {
        final meal = Meal(
          id: 'meal-1',
          userId: testUserId,
          mealType: MealType.snack,
          mealDate: DateTime.now(),
          loggedAt: DateTime.now(),
          entries: [],
        ).calculateTotals();

        expect(meal.totalCalories, equals(0));
        expect(meal.totalProtein, equals(0));
        expect(meal.totalCarbs, equals(0));
        expect(meal.totalFat, equals(0));
      });

      test('MealType enum has correct display names', () {
        expect(MealType.breakfast.displayName, equals('Breakfast'));
        expect(MealType.lunch.displayName, equals('Lunch'));
        expect(MealType.dinner.displayName, equals('Dinner'));
        expect(MealType.snack.displayName, equals('Snack'));
      });

      test('meal serializes to JSON', () {
        final meal = createTestMeal();
        final json = meal.toJson();

        expect(json['userId'], equals(testUserId));
        expect(json['mealType'], isNotNull);
        expect(json['entries'], isA<List>());
      });
    });

    group('FoodItem Model', () {
      test('creates food item with required fields', () {
        final food = createTestFoodItem(
          name: 'Chicken Breast',
          calories: 165,
          proteinGrams: 31,
          carbsGrams: 0,
          fatGrams: 3.6,
        );

        expect(food.name, equals('Chicken Breast'));
        expect(food.calories, equals(165));
        expect(food.proteinGrams, equals(31));
      });

      test('FoodCategory enum has correct values', () {
        expect(FoodCategory.protein.displayName, equals('Protein'));
        expect(FoodCategory.grains.displayName, equals('Grains'));
        expect(FoodCategory.vegetables.displayName, equals('Vegetables'));
        expect(FoodCategory.fruits.displayName, equals('Fruits'));
        expect(FoodCategory.dairy.displayName, equals('Dairy'));
      });

      test('food item serializes to JSON', () {
        final food = createTestFoodItem();
        final json = food.toJson();

        expect(json['name'], isNotEmpty);
        expect(json['calories'], isA<num>());
        expect(json['proteinGrams'], isA<num>());
      });

      test('food item deserializes from JSON', () {
        final json = {
          'id': 'food-123',
          'name': 'Brown Rice',
          'userId': 'user-123',
          'calories': 216.0,
          'proteinGrams': 5.0,
          'carbsGrams': 45.0,
          'fatGrams': 1.8,
          'servingSizeGrams': 195.0,
          'category': 'grains',
        };

        final food = FoodItem.fromJson(json);

        expect(food.name, equals('Brown Rice'));
        expect(food.calories, equals(216.0));
        expect(food.category, equals(FoodCategory.grains));
      });
    });

    group('WaterLog Model', () {
      test('creates water log with required fields', () {
        final log = createTestWaterLog(
          glassesConsumed: 6,
          targetGlasses: 8,
        );

        expect(log.glassesConsumed, equals(6));
        expect(log.targetGlasses, equals(8));
      });

      test('water log serializes to JSON', () {
        final log = createTestWaterLog();
        final json = log.toJson();

        expect(json['glassesConsumed'], isA<int>());
        expect(json['targetGlasses'], isA<int>());
      });

      test('water log calculates completion percentage', () {
        final log = createTestWaterLog(
          glassesConsumed: 6,
          targetGlasses: 8,
        );

        final percentage = log.glassesConsumed / log.targetGlasses * 100;
        expect(percentage, equals(75));
      });
    });

    group('NutritionGoal Model', () {
      test('creates nutrition goal with required fields', () {
        final goal = createTestNutritionGoal(
          dailyCalories: 2200,
          dailyProteinGrams: 180,
          dailyCarbsGrams: 220,
          dailyFatGrams: 70,
        );

        expect(goal.dailyCalories, equals(2200));
        expect(goal.dailyProteinGrams, equals(180));
        expect(goal.dailyCarbsGrams, equals(220));
        expect(goal.dailyFatGrams, equals(70));
      });

      test('calculates macro calories correctly', () {
        final goal = createTestNutritionGoal(
          dailyCalories: 2000,
          dailyProteinGrams: 150, // 150 * 4 = 600 cal
          dailyCarbsGrams: 200, // 200 * 4 = 800 cal
          dailyFatGrams: 67, // 67 * 9 = 603 cal
        );

        expect(goal.proteinCalories, equals(600));
        expect(goal.carbsCalories, equals(800));
        expect(goal.fatCalories, equals(603));
      });

      test('calculates macro percentages correctly', () {
        final goal = createTestNutritionGoal(
          dailyCalories: 2000,
          dailyProteinGrams: 125, // 500 cal = 25%
          dailyCarbsGrams: 250, // 1000 cal = 50%
          dailyFatGrams: 56, // ~500 cal = ~25%
        );

        expect(goal.proteinPercentage, equals(25));
        expect(goal.carbsPercentage, equals(50));
        // Fat: 56 * 9 = 504 cal, 504/2000*100 = 25.2%
        expect(goal.fatPercentage, closeTo(25.2, 0.1));
      });

      test('nutrition goal serializes to JSON', () {
        final goal = createTestNutritionGoal();
        final json = goal.toJson();

        expect(json['dailyCalories'], isA<num>());
        expect(json['dailyProteinGrams'], isA<num>());
        expect(json['dailyWaterGlasses'], isA<int>());
      });
    });

    group('DailyNutritionSummary Model', () {
      test('creates daily summary with aggregated data', () {
        final goal = createTestNutritionGoal();
        final summary = DailyNutritionSummary(
          userId: testUserId,
          date: DateTime.now(),
          totalCalories: 1800,
          totalProtein: 120,
          totalCarbs: 200,
          totalFat: 60,
          waterGlasses: 6,
          mealsLogged: 3,
          caloriesByMeal: {
            MealType.breakfast: 400,
            MealType.lunch: 600,
            MealType.dinner: 800,
          },
          goal: goal,
        );

        expect(summary.totalCalories, equals(1800));
        expect(summary.mealsLogged, equals(3));
        expect(summary.caloriesByMeal?[MealType.breakfast], equals(400));
      });

      test('calculates remaining calories correctly', () {
        final goal = createTestNutritionGoal(dailyCalories: 2000);
        final summary = DailyNutritionSummary(
          userId: testUserId,
          date: DateTime.now(),
          totalCalories: 1500,
          totalProtein: 100,
          totalCarbs: 150,
          totalFat: 50,
          waterGlasses: 5,
          mealsLogged: 2,
          caloriesByMeal: {},
          goal: goal,
        );

        expect(summary.remainingCalories, equals(500));
      });

      test('calculates progress percentages correctly', () {
        final goal = createTestNutritionGoal(
          dailyCalories: 2000,
          dailyProteinGrams: 150,
        );
        final summary = DailyNutritionSummary(
          userId: testUserId,
          date: DateTime.now(),
          totalCalories: 1500, // 75%
          totalProtein: 112.5, // 75%
          totalCarbs: 150,
          totalFat: 50,
          waterGlasses: 6,
          mealsLogged: 2,
          caloriesByMeal: {},
          goal: goal,
        );

        expect(summary.caloriesProgress, equals(75));
        expect(summary.proteinProgress, equals(75));
      });
    });
  });

  group('Test Fixtures', () {
    test('createTestMeal creates valid meal', () {
      final meal = createTestMeal();

      expect(meal.id, isNotEmpty);
      expect(meal.userId, equals(testUserId));
      expect(meal.entries, isNotEmpty);
    });

    test('createTestFoodItem creates valid food item', () {
      final food = createTestFoodItem();

      expect(food.id, isNotEmpty);
      expect(food.name, isNotEmpty);
      expect(food.calories, greaterThanOrEqualTo(0));
    });

    test('createTestWaterLog creates valid water log', () {
      final log = createTestWaterLog();

      expect(log.id, isNotEmpty);
      expect(log.glassesConsumed, greaterThanOrEqualTo(0));
    });

    test('createTestNutritionGoal creates valid goal', () {
      final goal = createTestNutritionGoal();

      expect(goal.id, isNotEmpty);
      expect(goal.dailyCalories, greaterThan(0));
      expect(goal.isActive, isTrue);
    });
  });
}
