import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/habits/domain/models/habit_log.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);
  final testCompletedAt = DateTime(2024, 1, 15, 14, 30);

  group('HabitLog', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
        );

        expect(log.id, 'log-1');
        expect(log.habitId, 'habit-1');
        expect(log.userId, 'user-1');
        expect(log.date, testDate);
        expect(log.completedAt, testCompletedAt);
      });

      test('has correct default count of 1', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
        );

        expect(log.count, 1);
      });

      test('has null notes by default', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
        );

        expect(log.notes, isNull);
      });
    });

    group('with custom count', () {
      test('creates log with multiple completions', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          count: 8, // e.g., 8 glasses of water
        );

        expect(log.count, 8);
      });

      test('creates log with partial completion', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          count: 5, // e.g., 5 out of 8 glasses
        );

        expect(log.count, 5);
      });
    });

    group('with notes', () {
      test('creates log with notes', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          notes: 'Felt great today!',
        );

        expect(log.notes, 'Felt great today!');
      });
    });

    group('date handling', () {
      test('date is normalized to start of day', () {
        final normalizedDate = DateTime(2024, 1, 15); // No time component
        final actualCompletedAt = DateTime(2024, 1, 15, 14, 30, 45);

        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: normalizedDate,
          completedAt: actualCompletedAt,
        );

        expect(log.date.hour, 0);
        expect(log.date.minute, 0);
        expect(log.date.second, 0);
        expect(log.completedAt.hour, 14);
        expect(log.completedAt.minute, 30);
      });
    });

    group('copyWith', () {
      test('creates copy with updated count', () {
        final original = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          count: 3,
        );

        final copy = original.copyWith(count: 5);

        expect(copy.id, 'log-1'); // Unchanged
        expect(copy.habitId, 'habit-1'); // Unchanged
        expect(copy.count, 5); // Changed
      });

      test('creates copy with updated notes', () {
        final original = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
        );

        final copy = original.copyWith(notes: 'Added some notes');

        expect(copy.notes, 'Added some notes');
      });

      test('creates copy with updated completedAt', () {
        final newCompletedAt = DateTime(2024, 1, 15, 18, 0);

        final original = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
        );

        final copy = original.copyWith(completedAt: newCompletedAt);

        expect(copy.completedAt, newCompletedAt);
        expect(copy.date, testDate); // Unchanged
      });
    });

    group('edge cases', () {
      test('handles zero count', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          count: 0,
        );

        expect(log.count, 0);
      });

      test('handles large count', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          count: 100,
        );

        expect(log.count, 100);
      });

      test('handles empty notes string', () {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          userId: 'user-1',
          date: testDate,
          completedAt: testCompletedAt,
          notes: '',
        );

        expect(log.notes, '');
      });
    });
  });
}
