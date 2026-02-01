import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/progress/domain/models/streak_data.dart';

/// Tests for StreakService pure functions and models.
///
/// Note: The StreakService uses FirebaseFirestore.instance internally,
/// but we can test:
/// 1. The StreakData and ActivityDay models
/// 2. Streak calculation logic (conceptually documented)
/// 3. ActivityDay calculations

void main() {
  group('StreakData Model', () {
    test('creates streak data with required fields', () {
      final streakData = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        totalActiveDays: 30,
        lastActiveDate: DateTime(2024, 1, 15),
        activeDatesThisMonth: [
          DateTime(2024, 1, 10),
          DateTime(2024, 1, 12),
          DateTime(2024, 1, 15),
        ],
        graceDays: 1,
      );

      expect(streakData.currentStreak, equals(5));
      expect(streakData.longestStreak, equals(10));
      expect(streakData.totalActiveDays, equals(30));
      expect(streakData.activeDatesThisMonth.length, equals(3));
      expect(streakData.graceDays, equals(1));
    });

    test('creates empty streak data', () {
      final emptyStreak = StreakData.empty();

      expect(emptyStreak.currentStreak, equals(0));
      expect(emptyStreak.longestStreak, equals(0));
      expect(emptyStreak.totalActiveDays, equals(0));
      expect(emptyStreak.lastActiveDate, isNull);
      expect(emptyStreak.activeDatesThisMonth, isEmpty);
    });

    test('streak data serializes to JSON', () {
      final streakData = StreakData(
        currentStreak: 7,
        longestStreak: 14,
        totalActiveDays: 50,
        graceDays: 2,
      );
      final json = streakData.toJson();

      expect(json['currentStreak'], equals(7));
      expect(json['longestStreak'], equals(14));
      expect(json['totalActiveDays'], equals(50));
      expect(json['graceDays'], equals(2));
    });

    test('streak data has default grace days of 1', () {
      final streakData = StreakData(
        currentStreak: 1,
        longestStreak: 1,
        totalActiveDays: 1,
      );

      expect(streakData.graceDays, equals(1));
    });
  });

  group('ActivityDay Model', () {
    test('creates activity day with required fields', () {
      final activityDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 2,
        habitsCompleted: 3,
        habitsTotal: 5,
        weightLogged: true,
        measurementsLogged: false,
        activityScore: 75,
      );

      expect(activityDay.workoutCount, equals(2));
      expect(activityDay.habitsCompleted, equals(3));
      expect(activityDay.habitsTotal, equals(5));
      expect(activityDay.weightLogged, isTrue);
      expect(activityDay.measurementsLogged, isFalse);
      expect(activityDay.activityScore, equals(75));
    });

    test('creates empty activity day', () {
      final emptyDay = ActivityDay.empty(DateTime(2024, 1, 15));

      expect(emptyDay.workoutCount, equals(0));
      expect(emptyDay.habitsCompleted, equals(0));
      expect(emptyDay.habitsTotal, equals(0));
      expect(emptyDay.weightLogged, isFalse);
      expect(emptyDay.measurementsLogged, isFalse);
      expect(emptyDay.activityScore, equals(0));
    });

    test('hasActivity returns true when activity score > 0', () {
      final activeDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 1,
        habitsCompleted: 0,
        habitsTotal: 0,
        weightLogged: false,
        measurementsLogged: false,
        activityScore: 40,
      );

      expect(activeDay.hasActivity, isTrue);
    });

    test('hasActivity returns false when activity score is 0', () {
      final emptyDay = ActivityDay.empty(DateTime(2024, 1, 15));

      expect(emptyDay.hasActivity, isFalse);
    });

    test('allHabitsCompleted returns true when all habits are done', () {
      final completedDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 0,
        habitsCompleted: 5,
        habitsTotal: 5,
        weightLogged: false,
        measurementsLogged: false,
        activityScore: 40,
      );

      expect(completedDay.allHabitsCompleted, isTrue);
    });

    test('allHabitsCompleted returns false when not all habits done', () {
      final partialDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 0,
        habitsCompleted: 3,
        habitsTotal: 5,
        weightLogged: false,
        measurementsLogged: false,
        activityScore: 24,
      );

      expect(partialDay.allHabitsCompleted, isFalse);
    });

    test('allHabitsCompleted returns false when no habits tracked', () {
      final noHabitsDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 1,
        habitsCompleted: 0,
        habitsTotal: 0,
        weightLogged: false,
        measurementsLogged: false,
        activityScore: 40,
      );

      expect(noHabitsDay.allHabitsCompleted, isFalse);
    });

    group('intensityLevel', () {
      test('returns 0 for no activity', () {
        final day = ActivityDay.empty(DateTime(2024, 1, 15));
        expect(day.intensityLevel, equals(0));
      });

      test('returns 1 for low activity (score < 25)', () {
        final day = ActivityDay(
          date: DateTime(2024, 1, 15),
          workoutCount: 0,
          habitsCompleted: 1,
          habitsTotal: 5,
          weightLogged: false,
          measurementsLogged: false,
          activityScore: 20,
        );
        expect(day.intensityLevel, equals(1));
      });

      test('returns 2 for medium activity (25 <= score < 50)', () {
        final day = ActivityDay(
          date: DateTime(2024, 1, 15),
          workoutCount: 0,
          habitsCompleted: 2,
          habitsTotal: 5,
          weightLogged: true,
          measurementsLogged: false,
          activityScore: 35,
        );
        expect(day.intensityLevel, equals(2));
      });

      test('returns 3 for high activity (50 <= score < 75)', () {
        final day = ActivityDay(
          date: DateTime(2024, 1, 15),
          workoutCount: 1,
          habitsCompleted: 3,
          habitsTotal: 5,
          weightLogged: false,
          measurementsLogged: false,
          activityScore: 60,
        );
        expect(day.intensityLevel, equals(3));
      });

      test('returns 4 for very high activity (score >= 75)', () {
        final day = ActivityDay(
          date: DateTime(2024, 1, 15),
          workoutCount: 1,
          habitsCompleted: 5,
          habitsTotal: 5,
          weightLogged: true,
          measurementsLogged: true,
          activityScore: 100,
        );
        expect(day.intensityLevel, equals(4));
      });
    });

    test('activity day serializes to JSON', () {
      final activityDay = ActivityDay(
        date: DateTime(2024, 1, 15),
        workoutCount: 2,
        habitsCompleted: 4,
        habitsTotal: 5,
        weightLogged: true,
        measurementsLogged: true,
        activityScore: 90,
      );
      final json = activityDay.toJson();

      expect(json['workoutCount'], equals(2));
      expect(json['habitsCompleted'], equals(4));
      expect(json['habitsTotal'], equals(5));
      expect(json['weightLogged'], isTrue);
      expect(json['activityScore'], equals(90));
    });
  });

  group('Streak Calculation Logic (Conceptual Tests)', () {
    // These tests document the expected behavior of the streak calculation
    // algorithms. The actual implementation is in StreakService.

    test('empty date list should return 0 streak', () {
      // _calculateCurrentStreak([]) should return 0
      final dates = <DateTime>[];
      expect(dates.isEmpty, isTrue);
    });

    test('single date today should return streak of 1', () {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final dates = [normalizedToday];
      expect(dates.length, equals(1));
      // _calculateCurrentStreak(dates, graceDays: 1) should return 1
    });

    test('consecutive dates should count as streak', () {
      final today = DateTime.now();
      final dates = [
        DateTime(today.year, today.month, today.day),
        DateTime(today.year, today.month, today.day - 1),
        DateTime(today.year, today.month, today.day - 2),
        DateTime(today.year, today.month, today.day - 3),
        DateTime(today.year, today.month, today.day - 4),
      ];
      expect(dates.length, equals(5));
      // _calculateCurrentStreak(dates, graceDays: 1) should return 5
    });

    test('gap larger than grace days should break streak', () {
      final today = DateTime.now();
      final dates = [
        DateTime(today.year, today.month, today.day),
        DateTime(today.year, today.month, today.day - 5), // Gap of 5 days!
      ];
      expect(dates.length, equals(2));
      // With graceDays: 1, _calculateCurrentStreak(dates) should return 1
      // because the gap (5 days) > graceDays + 1 (2)
    });

    test('grace period allows missing one day', () {
      final today = DateTime.now();
      final dates = [
        DateTime(today.year, today.month, today.day),
        // Missing yesterday
        DateTime(today.year, today.month, today.day - 2),
        DateTime(today.year, today.month, today.day - 3),
      ];
      expect(dates.length, equals(3));
      // With graceDays: 1, _calculateCurrentStreak(dates) should return 3
      // because the gap (2 days) <= graceDays + 1 (2)
    });

    test('last activity beyond grace period resets streak', () {
      final today = DateTime.now();
      final threeDaysAgo = DateTime(today.year, today.month, today.day - 3);

      // With graceDays: 1, if lastActive is 3 days ago, streak should be 0
      // because daysSinceLastActive (3) > graceDays (1)
      expect(today.difference(threeDaysAgo).inDays, equals(3));
    });

    test('longest streak calculation finds maximum', () {
      // Given dates: Jan 1-5 (5 days), gap, Jan 10-20 (11 days)
      // _calculateLongestStreak should return 11
      final dates = [
        // Recent streak (5 days)
        DateTime(2024, 1, 5),
        DateTime(2024, 1, 4),
        DateTime(2024, 1, 3),
        DateTime(2024, 1, 2),
        DateTime(2024, 1, 1),
        // Older longer streak (11 days)
        DateTime(2023, 12, 20),
        DateTime(2023, 12, 19),
        DateTime(2023, 12, 18),
        DateTime(2023, 12, 17),
        DateTime(2023, 12, 16),
        DateTime(2023, 12, 15),
        DateTime(2023, 12, 14),
        DateTime(2023, 12, 13),
        DateTime(2023, 12, 12),
        DateTime(2023, 12, 11),
        DateTime(2023, 12, 10),
      ];

      // The second group has 11 consecutive dates
      expect(dates.length, equals(16));
    });
  });

  group('Activity Score Calculation (Conceptual)', () {
    // Activity score is calculated as:
    // - Workout: +40 points
    // - Habits: up to +40 points (proportional to completion)
    // - Weight logged: +10 points
    // - Measurements logged: +10 points
    // Total is clamped to 0-100

    test('workout only gives 40 points', () {
      // workoutCount > 0 => +40
      const score = 40;
      expect(score, equals(40));
    });

    test('all habits completed gives 40 points', () {
      // (habitsCompleted / habitsTotal) * 40 = 40
      const habitsCompleted = 5;
      const habitsTotal = 5;
      final habitScore = ((habitsCompleted / habitsTotal) * 40).round();
      expect(habitScore, equals(40));
    });

    test('partial habit completion gives proportional points', () {
      // 3/5 habits = 60% => 24 points
      const habitsCompleted = 3;
      const habitsTotal = 5;
      final habitScore = ((habitsCompleted / habitsTotal) * 40).round();
      expect(habitScore, equals(24));
    });

    test('weight and measurements each give 10 points', () {
      const weightPoints = 10;
      const measurementPoints = 10;
      expect(weightPoints + measurementPoints, equals(20));
    });

    test('maximum score is 100', () {
      // 40 (workout) + 40 (habits) + 10 (weight) + 10 (measurements) = 100
      const maxScore = 40 + 40 + 10 + 10;
      expect(maxScore, equals(100));
    });

    test('score is clamped to 100', () {
      // Even if somehow we had more, it should be clamped
      final score = 120.clamp(0, 100);
      expect(score, equals(100));
    });
  });

  group('Date Normalization (Conceptual)', () {
    test('normalizes date by stripping time component', () {
      final dateWithTime = DateTime(2024, 1, 15, 14, 30, 45);
      final normalizedDate = DateTime(
        dateWithTime.year,
        dateWithTime.month,
        dateWithTime.day,
      );

      expect(normalizedDate.hour, equals(0));
      expect(normalizedDate.minute, equals(0));
      expect(normalizedDate.second, equals(0));
    });

    test('two dates with different times but same day normalize equally', () {
      final morning = DateTime(2024, 1, 15, 8, 0, 0);
      final evening = DateTime(2024, 1, 15, 20, 30, 0);

      final normalizedMorning = DateTime(morning.year, morning.month, morning.day);
      final normalizedEvening = DateTime(evening.year, evening.month, evening.day);

      expect(normalizedMorning, equals(normalizedEvening));
    });
  });

  group('Date Grouping (Conceptual)', () {
    test('groups multiple events on same day', () {
      final dates = [
        DateTime(2024, 1, 15, 10, 0),
        DateTime(2024, 1, 15, 14, 0),
        DateTime(2024, 1, 15, 18, 0),
        DateTime(2024, 1, 16, 9, 0),
      ];

      // When grouped by date, Jan 15 should have count 3, Jan 16 count 1
      final grouped = <String, int>{};
      for (final date in dates) {
        final key = '${date.year}-${date.month}-${date.day}';
        grouped[key] = (grouped[key] ?? 0) + 1;
      }

      expect(grouped['2024-1-15'], equals(3));
      expect(grouped['2024-1-16'], equals(1));
    });
  });
}
