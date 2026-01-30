import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/habits/domain/models/habit.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);

  group('HabitFrequency', () {
    test('displayName returns correct value for daily', () {
      expect(HabitFrequency.daily.displayName, 'Daily');
    });

    test('displayName returns correct value for weekly', () {
      expect(HabitFrequency.weekly.displayName, 'Weekly');
    });

    test('displayName returns correct value for custom', () {
      expect(HabitFrequency.custom.displayName, 'Custom');
    });
  });

  group('HabitIcon', () {
    test('displayName returns correct values', () {
      expect(HabitIcon.water.displayName, 'Water');
      expect(HabitIcon.sleep.displayName, 'Sleep');
      expect(HabitIcon.meditation.displayName, 'Meditation');
      expect(HabitIcon.walk.displayName, 'Walk');
      expect(HabitIcon.read.displayName, 'Read');
      expect(HabitIcon.exercise.displayName, 'Exercise');
      expect(HabitIcon.food.displayName, 'Food');
      expect(HabitIcon.pill.displayName, 'Medicine');
      expect(HabitIcon.study.displayName, 'Study');
      expect(HabitIcon.clean.displayName, 'Clean');
      expect(HabitIcon.other.displayName, 'Other');
    });

    test('all icons have unique display names', () {
      final displayNames = HabitIcon.values.map((i) => i.displayName).toList();
      expect(displayNames.toSet().length, displayNames.length);
    });
  });

  group('HabitColor', () {
    test('displayName returns correct values', () {
      expect(HabitColor.blue.displayName, 'Blue');
      expect(HabitColor.purple.displayName, 'Purple');
      expect(HabitColor.pink.displayName, 'Pink');
      expect(HabitColor.red.displayName, 'Red');
      expect(HabitColor.orange.displayName, 'Orange');
      expect(HabitColor.yellow.displayName, 'Yellow');
      expect(HabitColor.green.displayName, 'Green');
      expect(HabitColor.teal.displayName, 'Teal');
    });

    test('all colors have unique display names', () {
      final displayNames = HabitColor.values.map((c) => c.displayName).toList();
      expect(displayNames.toSet().length, displayNames.length);
    });
  });

  group('Habit', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Drink Water',
          description: 'Drink 8 glasses of water daily',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.water,
          color: HabitColor.blue,
          createdAt: testDate,
        );

        expect(habit.id, 'habit-1');
        expect(habit.userId, 'user-1');
        expect(habit.name, 'Drink Water');
        expect(habit.description, 'Drink 8 glasses of water daily');
        expect(habit.frequency, HabitFrequency.daily);
        expect(habit.icon, HabitIcon.water);
        expect(habit.color, HabitColor.blue);
        expect(habit.createdAt, testDate);
      });

      test('has correct default values', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Drink Water',
          description: 'Drink 8 glasses of water daily',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.water,
          color: HabitColor.blue,
          createdAt: testDate,
        );

        expect(habit.isActive, isTrue);
        expect(habit.targetCount, 0);
        expect(habit.unit, isNull);
        expect(habit.daysOfWeek, isEmpty);
        expect(habit.lastCompletedAt, isNull);
        expect(habit.currentStreak, 0);
        expect(habit.longestStreak, 0);
      });

      test('creates instance with all optional fields', () {
        final lastCompleted = DateTime(2024, 1, 14);
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Drink Water',
          description: 'Drink 8 glasses of water daily',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.water,
          color: HabitColor.blue,
          createdAt: testDate,
          isActive: false,
          targetCount: 8,
          unit: 'glasses',
          daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
          lastCompletedAt: lastCompleted,
          currentStreak: 7,
          longestStreak: 30,
        );

        expect(habit.isActive, isFalse);
        expect(habit.targetCount, 8);
        expect(habit.unit, 'glasses');
        expect(habit.daysOfWeek, [1, 2, 3, 4, 5]);
        expect(habit.lastCompletedAt, lastCompleted);
        expect(habit.currentStreak, 7);
        expect(habit.longestStreak, 30);
      });
    });

    group('daily habit', () {
      test('creates daily habit correctly', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Morning Exercise',
          description: '30 minutes of exercise',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.exercise,
          color: HabitColor.green,
          createdAt: testDate,
        );

        expect(habit.frequency, HabitFrequency.daily);
      });
    });

    group('weekly habit', () {
      test('creates weekly habit with specific days', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Gym Workout',
          description: 'Go to the gym',
          frequency: HabitFrequency.weekly,
          icon: HabitIcon.exercise,
          color: HabitColor.orange,
          createdAt: testDate,
          daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
        );

        expect(habit.frequency, HabitFrequency.weekly);
        expect(habit.daysOfWeek, [1, 3, 5]);
      });
    });

    group('quantifiable habit', () {
      test('creates habit with target count and unit', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Drink Water',
          description: 'Stay hydrated',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.water,
          color: HabitColor.blue,
          createdAt: testDate,
          targetCount: 8,
          unit: 'glasses',
        );

        expect(habit.targetCount, 8);
        expect(habit.unit, 'glasses');
      });
    });

    group('streak tracking', () {
      test('tracks current streak', () {
        final habit = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Read',
          description: 'Read for 30 minutes',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.read,
          color: HabitColor.purple,
          createdAt: testDate,
          currentStreak: 10,
          longestStreak: 15,
        );

        expect(habit.currentStreak, 10);
        expect(habit.longestStreak, 15);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Drink Water',
          description: 'Stay hydrated',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.water,
          color: HabitColor.blue,
          createdAt: testDate,
          currentStreak: 5,
        );

        final copy = original.copyWith(
          name: 'Drink More Water',
          currentStreak: 6,
          lastCompletedAt: DateTime.now(),
        );

        expect(copy.id, 'habit-1'); // Unchanged
        expect(copy.name, 'Drink More Water'); // Changed
        expect(copy.currentStreak, 6); // Changed
        expect(copy.lastCompletedAt, isNotNull); // Changed
        expect(copy.icon, HabitIcon.water); // Unchanged
      });

      test('creates copy with updated streak values', () {
        final original = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Exercise',
          description: 'Daily workout',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.exercise,
          color: HabitColor.green,
          createdAt: testDate,
          currentStreak: 10,
          longestStreak: 10,
        );

        final copy = original.copyWith(
          currentStreak: 11,
          longestStreak: 11,
        );

        expect(copy.currentStreak, 11);
        expect(copy.longestStreak, 11);
      });

      test('creates copy with updated active status', () {
        final original = Habit(
          id: 'habit-1',
          userId: 'user-1',
          name: 'Meditate',
          description: 'Daily meditation',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.meditation,
          color: HabitColor.teal,
          createdAt: testDate,
          isActive: true,
        );

        final copy = original.copyWith(isActive: false);

        expect(copy.isActive, isFalse);
      });
    });
  });
}
