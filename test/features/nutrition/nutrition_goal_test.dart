import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/nutrition_goal.dart';

void main() {
  final testDate = DateTime(2024, 1, 15, 10, 30);

  group('NutritionGoal', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          createdAt: testDate,
        );

        expect(goal.id, 'goal-1');
        expect(goal.userId, 'user-1');
        expect(goal.createdAt, testDate);
      });

      test('has correct default values', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          createdAt: testDate,
        );

        expect(goal.dailyCalories, 2000.0);
        expect(goal.dailyProteinGrams, 150.0);
        expect(goal.dailyCarbsGrams, 250.0);
        expect(goal.dailyFatGrams, 65.0);
        expect(goal.dailyWaterGlasses, 8);
        expect(goal.isActive, isTrue);
      });

      test('creates instance with custom values', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2500.0,
          dailyProteinGrams: 200.0,
          dailyCarbsGrams: 300.0,
          dailyFatGrams: 80.0,
          dailyWaterGlasses: 10,
          isActive: false,
          createdAt: testDate,
        );

        expect(goal.dailyCalories, 2500.0);
        expect(goal.dailyProteinGrams, 200.0);
        expect(goal.dailyCarbsGrams, 300.0);
        expect(goal.dailyFatGrams, 80.0);
        expect(goal.dailyWaterGlasses, 10);
        expect(goal.isActive, isFalse);
      });
    });

    group('macro calories calculations', () {
      test('calculates protein calories correctly (4 cal/g)', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyProteinGrams: 150.0,
          createdAt: testDate,
        );

        expect(goal.proteinCalories, 600.0); // 150 * 4
      });

      test('calculates carbs calories correctly (4 cal/g)', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCarbsGrams: 250.0,
          createdAt: testDate,
        );

        expect(goal.carbsCalories, 1000.0); // 250 * 4
      });

      test('calculates fat calories correctly (9 cal/g)', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyFatGrams: 65.0,
          createdAt: testDate,
        );

        expect(goal.fatCalories, 585.0); // 65 * 9
      });

      test('calculates total macro calories correctly', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyProteinGrams: 150.0, // 600 cal
          dailyCarbsGrams: 250.0, // 1000 cal
          dailyFatGrams: 65.0, // 585 cal
          createdAt: testDate,
        );

        expect(goal.totalMacroCalories, 2185.0); // 600 + 1000 + 585
      });
    });

    group('macro percentage calculations', () {
      test('calculates protein percentage correctly', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          dailyProteinGrams: 150.0, // 600 cal
          createdAt: testDate,
        );

        expect(goal.proteinPercentage, 30.0); // (600 / 2000) * 100
      });

      test('calculates carbs percentage correctly', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          dailyCarbsGrams: 250.0, // 1000 cal
          createdAt: testDate,
        );

        expect(goal.carbsPercentage, 50.0); // (1000 / 2000) * 100
      });

      test('calculates fat percentage correctly', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          dailyFatGrams: 65.0, // 585 cal
          createdAt: testDate,
        );

        expect(goal.fatPercentage, closeTo(29.25, 0.01)); // (585 / 2000) * 100
      });

      test('clamps percentage to 100 when exceeding', () {
        final goal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 500.0,
          dailyProteinGrams: 200.0, // 800 cal - exceeds total
          createdAt: testDate,
        );

        expect(goal.proteinPercentage, 100.0); // Clamped to 100
      });
    });

    group('isBalanced', () {
      test('returns true when macros match daily calories within 10%', () {
        // Total macro calories = 150*4 + 250*4 + 67*9 = 600 + 1000 + 603 = 2203
        // Difference = |2203 - 2000| = 203
        // 203/2000 = 10.15% - just over 10%

        // Let's calculate balanced values:
        // For 2000 cal: protein=150 (600), carbs=250 (1000), fat=44.4 (400)
        final balancedGoal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          dailyProteinGrams: 150.0, // 600 cal
          dailyCarbsGrams: 250.0, // 1000 cal
          dailyFatGrams: 44.4, // ~400 cal
          createdAt: testDate,
        );

        // Total = 600 + 1000 + 399.6 = 1999.6
        // Difference = 0.4, 0.4/2000 = 0.02% - well within 10%
        expect(balancedGoal.isBalanced, isTrue);
      });

      test('returns false when macros differ from daily calories by more than 10%', () {
        final unbalancedGoal = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          dailyProteinGrams: 200.0, // 800 cal
          dailyCarbsGrams: 300.0, // 1200 cal
          dailyFatGrams: 100.0, // 900 cal
          createdAt: testDate,
        );

        // Total = 800 + 1200 + 900 = 2900 cal
        // Difference = |2900 - 2000| = 900
        // 900/2000 = 45% - way over 10%
        expect(unbalancedGoal.isBalanced, isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = NutritionGoal(
          id: 'goal-1',
          userId: 'user-1',
          dailyCalories: 2000.0,
          createdAt: testDate,
        );

        final copy = original.copyWith(
          dailyCalories: 2500.0,
          dailyProteinGrams: 180.0,
        );

        expect(copy.id, 'goal-1'); // Unchanged
        expect(copy.dailyCalories, 2500.0); // Changed
        expect(copy.dailyProteinGrams, 180.0); // Changed
        expect(copy.dailyCarbsGrams, 250.0); // Unchanged (default)
      });
    });
  });
}
