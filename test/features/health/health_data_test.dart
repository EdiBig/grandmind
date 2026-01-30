import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/health/domain/models/health_data.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);
  final testSyncTime = DateTime(2024, 1, 15, 10, 30);

  group('HealthData', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          syncedAt: testSyncTime,
        );

        expect(data.id, 'health-1');
        expect(data.userId, 'user-1');
        expect(data.date, testDate);
        expect(data.steps, 10000);
        expect(data.distanceMeters, 8000.0);
        expect(data.caloriesBurned, 500.0);
        expect(data.sleepHours, 7.5);
        expect(data.syncedAt, testSyncTime);
      });

      test('creates instance with optional fields', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          averageHeartRate: 72.0,
          weight: 75.5,
          syncedAt: testSyncTime,
        );

        expect(data.averageHeartRate, 72.0);
        expect(data.weight, 75.5);
      });
    });

    group('distanceKm', () {
      test('converts meters to kilometers correctly', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          syncedAt: testSyncTime,
        );

        expect(data.distanceKm, 8.0);
      });

      test('handles zero distance', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 0.0,
          caloriesBurned: 0.0,
          sleepHours: 0.0,
          syncedAt: testSyncTime,
        );

        expect(data.distanceKm, 0.0);
      });

      test('handles fractional kilometers', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 5000,
          distanceMeters: 3500.0,
          caloriesBurned: 200.0,
          sleepHours: 6.0,
          syncedAt: testSyncTime,
        );

        expect(data.distanceKm, 3.5);
      });
    });

    group('hasMeaningfulData', () {
      test('returns true when steps > 0', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 100,
          distanceMeters: 0.0,
          caloriesBurned: 0.0,
          sleepHours: 0.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isTrue);
      });

      test('returns true when distance > 0', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 100.0,
          caloriesBurned: 0.0,
          sleepHours: 0.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isTrue);
      });

      test('returns true when calories > 0', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 0.0,
          caloriesBurned: 100.0,
          sleepHours: 0.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isTrue);
      });

      test('returns true when sleepHours > 0', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 0.0,
          caloriesBurned: 0.0,
          sleepHours: 7.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isTrue);
      });

      test('returns true when averageHeartRate is not null', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 0.0,
          caloriesBurned: 0.0,
          sleepHours: 0.0,
          averageHeartRate: 72.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isTrue);
      });

      test('returns false when all values are zero or null', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 0,
          distanceMeters: 0.0,
          caloriesBurned: 0.0,
          sleepHours: 0.0,
          syncedAt: testSyncTime,
        );

        expect(data.hasMeaningfulData, isFalse);
      });
    });

    group('dateString', () {
      test('formats date correctly', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: DateTime(2024, 1, 15),
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          syncedAt: testSyncTime,
        );

        expect(data.dateString, '2024-01-15');
      });

      test('pads single digit month and day', () {
        final data = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: DateTime(2024, 3, 5),
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          syncedAt: testSyncTime,
        );

        expect(data.dateString, '2024-03-05');
      });
    });

    group('fromHealthSummary', () {
      test('creates instance from summary data', () {
        final data = HealthData.fromHealthSummary(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          averageHeartRate: 72.0,
          sleepHours: 7.5,
          weight: 75.0,
        );

        expect(data.id, 'health-1');
        expect(data.userId, 'user-1');
        expect(data.steps, 10000);
        expect(data.distanceMeters, 8000.0);
        expect(data.caloriesBurned, 500.0);
        expect(data.averageHeartRate, 72.0);
        expect(data.sleepHours, 7.5);
        expect(data.weight, 75.0);
        expect(data.syncedAt, isNotNull);
        expect(data.createdAt, isNotNull);
        expect(data.updatedAt, isNotNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = HealthData(
          id: 'health-1',
          userId: 'user-1',
          date: testDate,
          steps: 10000,
          distanceMeters: 8000.0,
          caloriesBurned: 500.0,
          sleepHours: 7.5,
          syncedAt: testSyncTime,
        );

        final copy = original.copyWith(
          steps: 15000,
          caloriesBurned: 750.0,
        );

        expect(copy.id, 'health-1'); // Unchanged
        expect(copy.steps, 15000); // Changed
        expect(copy.caloriesBurned, 750.0); // Changed
        expect(copy.distanceMeters, 8000.0); // Unchanged
      });
    });
  });
}
