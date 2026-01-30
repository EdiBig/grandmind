import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/nutrition/domain/models/water_log.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);
  final testLogTime = DateTime(2024, 1, 15, 14, 30);

  group('WaterLog', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
        );

        expect(log.id, 'water-1');
        expect(log.userId, 'user-1');
        expect(log.date, testDate);
        expect(log.loggedAt, testLogTime);
      });

      test('has correct default values', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
        );

        expect(log.glassesConsumed, 0);
        expect(log.targetGlasses, 8);
      });

      test('creates instance with custom values', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 5,
          targetGlasses: 10,
        );

        expect(log.glassesConsumed, 5);
        expect(log.targetGlasses, 10);
      });
    });

    group('totalLiters', () {
      test('calculates total liters correctly (250ml per glass)', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 4,
        );

        expect(log.totalLiters, 1.0); // 4 * 0.25 = 1 liter
      });

      test('returns 0 when no glasses consumed', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 0,
        );

        expect(log.totalLiters, 0.0);
      });

      test('calculates total liters for 8 glasses', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 8,
        );

        expect(log.totalLiters, 2.0); // 8 * 0.25 = 2 liters
      });
    });

    group('progressPercentage', () {
      test('calculates progress percentage correctly', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 4,
          targetGlasses: 8,
        );

        expect(log.progressPercentage, 50.0); // (4/8) * 100
      });

      test('returns 0 when no glasses consumed', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 0,
          targetGlasses: 8,
        );

        expect(log.progressPercentage, 0.0);
      });

      test('returns 100 when goal achieved', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 8,
          targetGlasses: 8,
        );

        expect(log.progressPercentage, 100.0);
      });

      test('clamps to 100 when exceeding goal', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 10,
          targetGlasses: 8,
        );

        expect(log.progressPercentage, 100.0); // Clamped to 100
      });

      test('returns 0 when target is 0', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 5,
          targetGlasses: 0,
        );

        expect(log.progressPercentage, 0.0);
      });
    });

    group('goalAchieved', () {
      test('returns true when glasses consumed >= target', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 8,
          targetGlasses: 8,
        );

        expect(log.goalAchieved, isTrue);
      });

      test('returns true when glasses consumed > target', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 10,
          targetGlasses: 8,
        );

        expect(log.goalAchieved, isTrue);
      });

      test('returns false when glasses consumed < target', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 5,
          targetGlasses: 8,
        );

        expect(log.goalAchieved, isFalse);
      });
    });

    group('remainingGlasses', () {
      test('calculates remaining glasses correctly', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 3,
          targetGlasses: 8,
        );

        expect(log.remainingGlasses, 5); // 8 - 3
      });

      test('returns 0 when goal achieved', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 8,
          targetGlasses: 8,
        );

        expect(log.remainingGlasses, 0);
      });

      test('returns 0 when exceeding goal', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 10,
          targetGlasses: 8,
        );

        expect(log.remainingGlasses, 0);
      });

      test('returns target when no glasses consumed', () {
        final log = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 0,
          targetGlasses: 8,
        );

        expect(log.remainingGlasses, 8);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = WaterLog(
          id: 'water-1',
          userId: 'user-1',
          date: testDate,
          loggedAt: testLogTime,
          glassesConsumed: 3,
        );

        final copy = original.copyWith(glassesConsumed: 5);

        expect(copy.id, 'water-1'); // Unchanged
        expect(copy.glassesConsumed, 5); // Changed
        expect(copy.targetGlasses, 8); // Unchanged (default)
      });
    });
  });
}
