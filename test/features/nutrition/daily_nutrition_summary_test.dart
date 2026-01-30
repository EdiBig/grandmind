import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/daily_nutrition_summary.dart';
import 'package:kinesa/features/nutrition/domain/models/nutrition_goal.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);
  final testGoal = NutritionGoal(
    id: 'goal-1',
    userId: 'user-1',
    dailyCalories: 2000.0,
    dailyProteinGrams: 150.0,
    dailyCarbsGrams: 250.0,
    dailyFatGrams: 65.0,
    dailyWaterGlasses: 8,
    createdAt: testDate,
  );

  group('DailyNutritionSummary', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
        );

        expect(summary.userId, 'user-1');
        expect(summary.date, testDate);
      });

      test('has correct default values', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
        );

        expect(summary.totalCalories, 0.0);
        expect(summary.totalProtein, 0.0);
        expect(summary.totalCarbs, 0.0);
        expect(summary.totalFat, 0.0);
        expect(summary.waterGlasses, 0);
        expect(summary.mealsLogged, 0);
      });
    });

    group('progress calculations', () {
      test('calculates calories progress correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1000.0,
          goal: testGoal, // 2000 cal target
        );

        expect(summary.caloriesProgress, 50.0); // (1000/2000) * 100
      });

      test('calculates protein progress correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalProtein: 75.0,
          goal: testGoal, // 150g target
        );

        expect(summary.proteinProgress, 50.0); // (75/150) * 100
      });

      test('calculates carbs progress correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCarbs: 125.0,
          goal: testGoal, // 250g target
        );

        expect(summary.carbsProgress, 50.0); // (125/250) * 100
      });

      test('calculates fat progress correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalFat: 32.5,
          goal: testGoal, // 65g target
        );

        expect(summary.fatProgress, 50.0); // (32.5/65) * 100
      });

      test('calculates water progress correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 4,
          goal: testGoal, // 8 glasses target
        );

        expect(summary.waterProgress, 50.0); // (4/8) * 100
      });

      test('clamps calories progress to 150%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 4000.0, // 200% of goal
          goal: testGoal,
        );

        expect(summary.caloriesProgress, 150.0); // Clamped
      });

      test('clamps water progress to 100%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 12, // 150% of goal
          goal: testGoal,
        );

        expect(summary.waterProgress, 100.0); // Clamped
      });

      test('returns 0 for all progress when no goal set', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1000.0,
          totalProtein: 75.0,
          totalCarbs: 125.0,
          totalFat: 32.5,
          waterGlasses: 4,
        );

        expect(summary.caloriesProgress, 0.0);
        expect(summary.proteinProgress, 0.0);
        expect(summary.carbsProgress, 0.0);
        expect(summary.fatProgress, 0.0);
        expect(summary.waterProgress, 0.0);
      });
    });

    group('goal achievement checks', () {
      test('caloriesOnTrack returns true when within 90-110%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0, // 100%
          goal: testGoal,
        );

        expect(summary.caloriesOnTrack, isTrue);
      });

      test('caloriesOnTrack returns true at 90%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1800.0, // 90%
          goal: testGoal,
        );

        expect(summary.caloriesOnTrack, isTrue);
      });

      test('caloriesOnTrack returns true at 110%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2199.0, // ~109.95% - just under 110%
          goal: testGoal,
        );

        expect(summary.caloriesOnTrack, isTrue);
      });

      test('caloriesOnTrack returns false below 90%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1500.0, // 75%
          goal: testGoal,
        );

        expect(summary.caloriesOnTrack, isFalse);
      });

      test('caloriesOnTrack returns false above 110%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2500.0, // 125%
          goal: testGoal,
        );

        expect(summary.caloriesOnTrack, isFalse);
      });

      test('macrosBalanced returns true when all macros >= 80%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalProtein: 120.0, // 80%
          totalCarbs: 200.0, // 80%
          totalFat: 52.0, // 80%
          goal: testGoal,
        );

        expect(summary.macrosBalanced, isTrue);
      });

      test('macrosBalanced returns false when any macro < 80%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalProtein: 100.0, // 66%
          totalCarbs: 200.0, // 80%
          totalFat: 52.0, // 80%
          goal: testGoal,
        );

        expect(summary.macrosBalanced, isFalse);
      });

      test('waterGoalAchieved returns true when water >= target', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 8,
          goal: testGoal,
        );

        expect(summary.waterGoalAchieved, isTrue);
      });

      test('waterGoalAchieved returns true when water > target', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 10,
          goal: testGoal,
        );

        expect(summary.waterGoalAchieved, isTrue);
      });

      test('waterGoalAchieved returns false when water < target', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 5,
          goal: testGoal,
        );

        expect(summary.waterGoalAchieved, isFalse);
      });

      test('allGoalsAchieved returns true when all goals met', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0, // 100% - on track
          totalProtein: 150.0, // 100% >= 80%
          totalCarbs: 250.0, // 100% >= 80%
          totalFat: 65.0, // 100% >= 80%
          waterGlasses: 8, // 100% - achieved
          goal: testGoal,
        );

        expect(summary.allGoalsAchieved, isTrue);
      });

      test('allGoalsAchieved returns false when any goal not met', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0, // on track
          totalProtein: 150.0, // balanced
          totalCarbs: 250.0, // balanced
          totalFat: 65.0, // balanced
          waterGlasses: 5, // NOT achieved
          goal: testGoal,
        );

        expect(summary.allGoalsAchieved, isFalse);
      });
    });

    group('remaining calculations', () {
      test('calculates remaining calories correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1500.0,
          goal: testGoal, // 2000 target
        );

        expect(summary.remainingCalories, 500.0);
      });

      test('clamps remaining calories to 0 when exceeded', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2500.0,
          goal: testGoal,
        );

        expect(summary.remainingCalories, 0.0);
      });

      test('calculates remaining water correctly', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          waterGlasses: 5,
          goal: testGoal, // 8 target
        );

        expect(summary.remainingWater, 3);
      });

      test('returns 0 remaining when no goal set', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1500.0,
        );

        expect(summary.remainingCalories, 0.0);
        expect(summary.remainingProtein, 0.0);
        expect(summary.remainingWater, 0);
      });
    });

    group('status messages', () {
      test('caloriesStatus returns "No goal set" when no goal', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
        );

        expect(summary.caloriesStatus, 'No goal set');
      });

      test('caloriesStatus returns "On track!" when within range', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0,
          goal: testGoal,
        );

        expect(summary.caloriesStatus, 'On track!');
      });

      test('caloriesStatus returns "Below target" when under 90%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1500.0, // 75%
          goal: testGoal,
        );

        expect(summary.caloriesStatus, 'Below target');
      });

      test('caloriesStatus returns "Above target" when over 110%', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2500.0, // 125%
          goal: testGoal,
        );

        expect(summary.caloriesStatus, 'Above target');
      });

      test('progressSummary returns goal setup message when no goal', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
        );

        expect(
          summary.progressSummary,
          'Set your nutrition goals to track progress',
        );
      });

      test('progressSummary returns celebration when all goals achieved', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0,
          totalProtein: 150.0,
          totalCarbs: 250.0,
          totalFat: 65.0,
          waterGlasses: 8,
          mealsLogged: 3,
          goal: testGoal,
        );

        expect(summary.progressSummary, 'All goals achieved! 🎉');
      });

      test('progressSummary returns no meals message when none logged', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          mealsLogged: 0,
          goal: testGoal,
        );

        expect(summary.progressSummary, 'No meals logged today');
      });

      test('progressSummary shows count of achieved goals', () {
        final summary = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 2000.0, // on track (1)
          totalProtein: 50.0, // not balanced
          totalCarbs: 50.0, // not balanced
          totalFat: 20.0, // not balanced (0)
          waterGlasses: 8, // achieved (1)
          mealsLogged: 3,
          goal: testGoal,
        );

        expect(summary.progressSummary, '2/3 goals achieved');
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = DailyNutritionSummary(
          userId: 'user-1',
          date: testDate,
          totalCalories: 1000.0,
        );

        final copy = original.copyWith(
          totalCalories: 1500.0,
          waterGlasses: 4,
        );

        expect(copy.userId, 'user-1'); // Unchanged
        expect(copy.totalCalories, 1500.0); // Changed
        expect(copy.waterGlasses, 4); // Changed
      });
    });
  });
}
