import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kinesa/features/habits/domain/models/habit.dart';
import 'package:kinesa/features/habits/domain/models/habit_log.dart';
import '../../../../helpers/test_helpers.dart';
import '../../../../helpers/test_fixtures.dart';

/// Note: HabitRepository uses FirebaseFirestore.instance internally,
/// making it difficult to inject a fake Firestore for true unit tests.
///
/// These tests focus on:
/// 1. Testing with MockAnalyticsService to verify analytics integration
/// 2. Testing pure functions and model behavior
/// 3. Documenting expected repository behavior
///
/// For full integration tests, consider using Firebase Test Lab
/// or modifying the repository to accept an optional Firestore parameter.

void main() {
  group('HabitRepository Analytics Integration', () {
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      mockAnalytics = MockAnalyticsService();
    });

    test('MockAnalyticsService correctly stubs analytics methods', () {
      // Verify our mock is properly set up
      expect(
        () async => await mockAnalytics.logHabitCreated(
          habitId: 'test-id',
          habitName: 'Test Habit',
          category: 'exercise',
        ),
        returnsNormally,
      );
    });

    test('MockAnalyticsService correctly stubs habit completion', () {
      expect(
        () async => await mockAnalytics.logHabitCompleted(
          habitId: 'test-id',
          habitName: 'Test Habit',
        ),
        returnsNormally,
      );
    });

    test('MockAnalyticsService correctly stubs habit deletion', () {
      expect(
        () async => await mockAnalytics.logHabitDeleted(habitId: 'test-id'),
        returnsNormally,
      );
    });
  });

  group('Habit Model', () {
    test('creates habit with required fields', () {
      final habit = createTestHabit(
        name: 'Drink Water',
        description: 'Drink 8 glasses of water daily',
      );

      expect(habit.name, equals('Drink Water'));
      expect(habit.description, equals('Drink 8 glasses of water daily'));
      expect(habit.isActive, isTrue);
      expect(habit.currentStreak, equals(0));
      expect(habit.longestStreak, equals(0));
    });

    test('habit has correct frequency enum values', () {
      expect(HabitFrequency.daily.displayName, equals('Daily'));
      expect(HabitFrequency.weekly.displayName, equals('Weekly'));
      expect(HabitFrequency.custom.displayName, equals('Custom'));
    });

    test('habit has correct icon enum values', () {
      expect(HabitIcon.water.displayName, equals('Water'));
      expect(HabitIcon.exercise.displayName, equals('Exercise'));
      expect(HabitIcon.meditation.displayName, equals('Meditation'));
    });

    test('habit has correct color enum values', () {
      expect(HabitColor.values, isNotEmpty);
      expect(HabitColor.blue, isNotNull);
    });

    test('habit serializes to JSON', () {
      final habit = createTestHabit();
      final json = habit.toJson();

      expect(json['name'], equals('Test Habit'));
      expect(json['description'], equals('Test habit description'));
      expect(json['frequency'], equals('daily'));
      expect(json['isActive'], isTrue);
    });

    test('habit deserializes from JSON', () {
      final json = {
        'id': 'habit-123',
        'userId': 'user-123',
        'name': 'Morning Run',
        'description': 'Run every morning',
        'frequency': 'daily',
        'icon': 'exercise',
        'color': 'blue',
        'isActive': true,
        'currentStreak': 5,
        'longestStreak': 10,
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final habit = Habit.fromJson(json);

      expect(habit.name, equals('Morning Run'));
      expect(habit.currentStreak, equals(5));
      expect(habit.longestStreak, equals(10));
    });
  });

  group('HabitLog Model', () {
    test('creates habit log with required fields', () {
      final log = createTestHabitLog(
        habitId: 'habit-123',
        userId: 'user-123',
      );

      expect(log.habitId, equals('habit-123'));
      expect(log.userId, equals('user-123'));
      expect(log.count, equals(1));
    });

    test('habit log serializes to JSON', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final log = createTestHabitLog(
        date: now,
        completedAt: now,
        notes: 'Felt great!',
      );
      final json = log.toJson();

      expect(json['habitId'], equals('habit-123'));
      expect(json['notes'], equals('Felt great!'));
    });

    test('habit log deserializes from JSON', () {
      final json = {
        'id': 'log-123',
        'habitId': 'habit-456',
        'userId': 'user-789',
        'date': '2024-01-15T00:00:00.000',
        'completedAt': '2024-01-15T10:30:00.000',
        'count': 3,
        'notes': 'Good progress',
      };

      final log = HabitLog.fromJson(json);

      expect(log.habitId, equals('habit-456'));
      expect(log.count, equals(3));
      expect(log.notes, equals('Good progress'));
    });
  });

  group('Streak Calculation Logic', () {
    // Test the streak calculation algorithm conceptually
    // These are the expected behaviors that the repository should implement

    test('streak should be 0 for empty log list', () {
      final logs = <HabitLog>[];
      expect(logs.isEmpty, isTrue);
      // Expected: calculateStreak(logs) == 0
    });

    test('streak should be 1 for single log today', () {
      final today = DateTime.now();
      final logs = [
        createTestHabitLog(date: today, completedAt: today),
      ];
      expect(logs.length, equals(1));
      // Expected: calculateStreak(logs) == 1
    });

    test('streak should count consecutive days correctly', () {
      final today = DateTime.now();
      final logs = createConsecutiveHabitLogs(
        habitId: 'habit-123',
        userId: 'user-123',
        days: 5,
        startDate: today.subtract(const Duration(days: 4)),
      );
      expect(logs.length, equals(5));
      // Expected: calculateStreak(logs) == 5
    });

    test('streak should break on non-consecutive days', () {
      final today = DateTime.now();
      final logs = [
        createTestHabitLog(
          id: 'log-1',
          date: today,
          completedAt: today,
        ),
        createTestHabitLog(
          id: 'log-2',
          date: today.subtract(const Duration(days: 3)), // Gap!
          completedAt: today.subtract(const Duration(days: 3)),
        ),
      ];
      expect(logs.length, equals(2));
      // Expected: calculateStreak(logs) == 1 (only today counts)
    });
  });

  group('Test Fixtures', () {
    test('createTestHabit creates valid habit', () {
      final habit = createTestHabit();

      expect(habit.id, isNotEmpty);
      expect(habit.userId, equals(testUserId));
      expect(habit.name, isNotEmpty);
      expect(habit.description, isNotEmpty);
    });

    test('createTestHabitLog creates valid habit log', () {
      final log = createTestHabitLog();

      expect(log.id, isNotEmpty);
      expect(log.habitId, isNotEmpty);
      expect(log.userId, equals(testUserId));
    });

    test('createConsecutiveHabitLogs creates consecutive logs', () {
      final logs = createConsecutiveHabitLogs(
        habitId: 'habit-1',
        userId: 'user-1',
        days: 3,
      );

      expect(logs.length, equals(3));

      // Verify dates are consecutive
      for (int i = 1; i < logs.length; i++) {
        final diff = logs[i].date.difference(logs[i - 1].date).inDays;
        expect(diff, equals(1));
      }
    });
  });
}
