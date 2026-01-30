import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/progress/domain/models/progress_goal.dart';
import 'package:kinesa/features/progress/domain/models/measurement_entry.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);

  group('GoalType', () {
    test('displayName returns correct value for weight', () {
      expect(GoalType.weight.displayName, 'Weight Goal');
    });

    test('displayName returns correct value for measurement', () {
      expect(GoalType.measurement.displayName, 'Measurement Goal');
    });

    test('displayName returns correct value for custom', () {
      expect(GoalType.custom.displayName, 'Custom Goal');
    });
  });

  group('GoalStatus', () {
    test('displayName returns correct value for active', () {
      expect(GoalStatus.active.displayName, 'Active');
    });

    test('displayName returns correct value for completed', () {
      expect(GoalStatus.completed.displayName, 'Completed');
    });

    test('displayName returns correct value for abandoned', () {
      expect(GoalStatus.abandoned.displayName, 'Abandoned');
    });
  });

  group('ProgressGoal', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.id, 'goal-1');
        expect(goal.userId, 'user-1');
        expect(goal.title, 'Lose 10kg');
        expect(goal.type, GoalType.weight);
        expect(goal.startValue, 80.0);
        expect(goal.targetValue, 70.0);
        expect(goal.currentValue, 75.0);
      });

      test('has correct default status', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.status, GoalStatus.active);
      });
    });

    group('progressPercentage', () {
      test('calculates progress correctly for weight loss (decreasing goal)', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0, // losing weight
          currentValue: 75.0, // lost 5kg
          startDate: testDate,
          createdAt: testDate,
        );

        // Progress = (75 - 80) / (70 - 80) * 100 = -5 / -10 * 100 = 50%
        expect(goal.progressPercentage, 50.0);
      });

      test('calculates progress correctly for weight gain (increasing goal)', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Gain 10kg muscle',
          type: GoalType.weight,
          startValue: 70.0,
          targetValue: 80.0, // gaining weight
          currentValue: 75.0, // gained 5kg
          startDate: testDate,
          createdAt: testDate,
        );

        // Progress = (75 - 70) / (80 - 70) * 100 = 5 / 10 * 100 = 50%
        expect(goal.progressPercentage, 50.0);
      });

      test('returns 100 when target equals start', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Maintain weight',
          type: GoalType.weight,
          startValue: 70.0,
          targetValue: 70.0,
          currentValue: 70.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.progressPercentage, 100.0);
      });

      test('clamps to 0 when no progress made', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose weight',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 85.0, // weight went up instead
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.progressPercentage, 0.0);
      });

      test('clamps to 100 when goal exceeded', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 65.0, // lost more than goal
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.progressPercentage, 100.0);
      });
    });

    group('remainingValue', () {
      test('calculates remaining value correctly', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.remainingValue, 5.0); // 70 - 75 = -5, abs = 5
      });

      test('returns 0 when target reached', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 70.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.remainingValue, 0.0);
      });
    });

    group('isCompleted', () {
      test('returns true when progress is 100%', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 70.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.isCompleted, isTrue);
      });

      test('returns false when progress < 100%', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.isCompleted, isFalse);
      });
    });

    group('isOverdue', () {
      test('returns true when past target date and not completed', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 10));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          targetDate: pastDate,
          createdAt: testDate,
        );

        expect(goal.isOverdue, isTrue);
      });

      test('returns false when target date is in future', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          targetDate: futureDate,
          createdAt: testDate,
        );

        expect(goal.isOverdue, isFalse);
      });

      test('returns false when no target date set', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.isOverdue, isFalse);
      });

      test('returns false when goal is completed', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 10));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 70.0, // completed
          startDate: testDate,
          targetDate: pastDate,
          status: GoalStatus.completed,
          createdAt: testDate,
        );

        expect(goal.isOverdue, isFalse);
      });
    });

    group('daysRemaining', () {
      test('returns null when no target date', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.daysRemaining, isNull);
      });

      test('returns 0 when past target date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 10));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          targetDate: pastDate,
          createdAt: testDate,
        );

        expect(goal.daysRemaining, 0);
      });

      test('calculates days remaining correctly', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          targetDate: futureDate,
          createdAt: testDate,
        );

        // Should be approximately 30 days (can be 29 or 30 depending on time of day)
        expect(goal.daysRemaining, greaterThanOrEqualTo(29));
        expect(goal.daysRemaining, lessThanOrEqualTo(30));
      });
    });

    group('daysSinceStart', () {
      test('calculates days since start correctly', () {
        final startDate = DateTime.now().subtract(const Duration(days: 15));
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: startDate,
          createdAt: startDate,
        );

        expect(goal.daysSinceStart, 15);
      });
    });

    group('getProgressDisplay', () {
      test('returns formatted progress with unit', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          unit: 'kg',
          createdAt: testDate,
        );

        expect(goal.getProgressDisplay(), '75.0 kg / 70.0 kg');
      });

      test('returns formatted progress without unit when specified', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          unit: 'kg',
          createdAt: testDate,
        );

        expect(goal.getProgressDisplay(includeUnit: false), '75.0 / 70.0');
      });

      test('handles null unit gracefully', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Custom Goal',
          type: GoalType.custom,
          startValue: 0.0,
          targetValue: 100.0,
          currentValue: 50.0,
          startDate: testDate,
          createdAt: testDate,
        );

        expect(goal.getProgressDisplay(), '50.0 / 100.0');
      });
    });

    group('with measurement goal', () {
      test('creates measurement goal correctly', () {
        final goal = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Reduce waist',
          type: GoalType.measurement,
          startValue: 90.0,
          targetValue: 80.0,
          currentValue: 85.0,
          startDate: testDate,
          measurementType: MeasurementType.waist,
          unit: 'cm',
          createdAt: testDate,
        );

        expect(goal.measurementType, MeasurementType.waist);
        expect(goal.unit, 'cm');
        expect(goal.progressPercentage, 50.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = ProgressGoal(
          id: 'goal-1',
          userId: 'user-1',
          title: 'Lose 10kg',
          type: GoalType.weight,
          startValue: 80.0,
          targetValue: 70.0,
          currentValue: 75.0,
          startDate: testDate,
          createdAt: testDate,
        );

        final copy = original.copyWith(
          currentValue: 72.0,
          status: GoalStatus.completed,
        );

        expect(copy.id, 'goal-1'); // Unchanged
        expect(copy.currentValue, 72.0); // Changed
        expect(copy.status, GoalStatus.completed); // Changed
        expect(copy.startValue, 80.0); // Unchanged
      });
    });
  });
}
