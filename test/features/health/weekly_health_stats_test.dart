import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/health/domain/models/weekly_health_stats.dart';

void main() {
  final weekStart = DateTime(2024, 1, 15);
  final weekEnd = DateTime(2024, 1, 21);

  group('WeeklyHealthStats', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 7,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.totalSteps, 70000);
        expect(stats.totalDistanceKm, 50.0);
        expect(stats.totalCalories, 3500.0);
        expect(stats.averageHeartRate, 72.0);
        expect(stats.averageSleepHours, 7.5);
        expect(stats.daysWithData, 7);
        expect(stats.weekStartDate, weekStart);
        expect(stats.weekEndDate, weekEnd);
      });
    });

    group('averageStepsPerDay', () {
      test('calculates average steps correctly', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 7,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageStepsPerDay, 10000.0);
      });

      test('returns 0 when no days with data', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 0,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageStepsPerDay, 0.0);
      });

      test('handles partial week data', () {
        final stats = WeeklyHealthStats(
          totalSteps: 30000,
          totalDistanceKm: 21.0,
          totalCalories: 1500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 3,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageStepsPerDay, 10000.0);
      });
    });

    group('averageDistancePerDay', () {
      test('calculates average distance correctly', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 56.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 7,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageDistancePerDay, 8.0);
      });

      test('returns 0 when no days with data', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 0,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageDistancePerDay, 0.0);
      });
    });

    group('averageCaloriesPerDay', () {
      test('calculates average calories correctly', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 7,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageCaloriesPerDay, 500.0);
      });

      test('returns 0 when no days with data', () {
        final stats = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 0,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        expect(stats.averageCaloriesPerDay, 0.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = WeeklyHealthStats(
          totalSteps: 70000,
          totalDistanceKm: 50.0,
          totalCalories: 3500.0,
          averageHeartRate: 72.0,
          averageSleepHours: 7.5,
          daysWithData: 7,
          weekStartDate: weekStart,
          weekEndDate: weekEnd,
        );

        final copy = original.copyWith(
          totalSteps: 80000,
          daysWithData: 6,
        );

        expect(copy.totalSteps, 80000); // Changed
        expect(copy.daysWithData, 6); // Changed
        expect(copy.totalDistanceKm, 50.0); // Unchanged
      });
    });
  });

  group('DailyHealthPoint', () {
    test('creates instance with required fields', () {
      final point = DailyHealthPoint(
        date: weekStart,
        steps: 10000,
        distanceKm: 8.0,
        calories: 500.0,
        sleepHours: 7.5,
      );

      expect(point.date, weekStart);
      expect(point.steps, 10000);
      expect(point.distanceKm, 8.0);
      expect(point.calories, 500.0);
      expect(point.sleepHours, 7.5);
      expect(point.heartRate, isNull);
    });

    test('creates instance with optional heart rate', () {
      final point = DailyHealthPoint(
        date: weekStart,
        steps: 10000,
        distanceKm: 8.0,
        calories: 500.0,
        heartRate: 72.0,
        sleepHours: 7.5,
      );

      expect(point.heartRate, 72.0);
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = DailyHealthPoint(
          date: weekStart,
          steps: 10000,
          distanceKm: 8.0,
          calories: 500.0,
          sleepHours: 7.5,
        );

        final copy = original.copyWith(
          steps: 15000,
          heartRate: 75.0,
        );

        expect(copy.steps, 15000); // Changed
        expect(copy.heartRate, 75.0); // Changed
        expect(copy.distanceKm, 8.0); // Unchanged
      });
    });
  });
}
