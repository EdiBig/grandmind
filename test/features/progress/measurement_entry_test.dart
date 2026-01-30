import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/progress/domain/models/measurement_entry.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);

  group('MeasurementType', () {
    group('displayName', () {
      test('returns correct display name for waist', () {
        expect(MeasurementType.waist.displayName, 'Waist');
      });

      test('returns correct display name for chest', () {
        expect(MeasurementType.chest.displayName, 'Chest');
      });

      test('returns correct display name for hips', () {
        expect(MeasurementType.hips.displayName, 'Hips');
      });

      test('returns correct display name for leftArm', () {
        expect(MeasurementType.leftArm.displayName, 'Left Arm');
      });

      test('returns correct display name for rightArm', () {
        expect(MeasurementType.rightArm.displayName, 'Right Arm');
      });

      test('returns correct display name for leftThigh', () {
        expect(MeasurementType.leftThigh.displayName, 'Left Thigh');
      });

      test('returns correct display name for rightThigh', () {
        expect(MeasurementType.rightThigh.displayName, 'Right Thigh');
      });

      test('returns correct display name for neck', () {
        expect(MeasurementType.neck.displayName, 'Neck');
      });

      test('returns correct display name for shoulders', () {
        expect(MeasurementType.shoulders.displayName, 'Shoulders');
      });

      test('returns correct display name for calves', () {
        expect(MeasurementType.calves.displayName, 'Calves');
      });

      test('all measurement types have unique display names', () {
        final displayNames =
            MeasurementType.values.map((t) => t.displayName).toList();
        expect(displayNames.toSet().length, displayNames.length);
      });
    });

    group('icon', () {
      test('returns Icons.fitbit for waist', () {
        expect(MeasurementType.waist.icon, Icons.fitbit);
      });

      test('returns Icons.favorite for chest', () {
        expect(MeasurementType.chest.icon, Icons.favorite);
      });

      test('returns Icons.accessibility_new for hips', () {
        expect(MeasurementType.hips.icon, Icons.accessibility_new);
      });

      test('returns Icons.front_hand for arms', () {
        expect(MeasurementType.leftArm.icon, Icons.front_hand);
        expect(MeasurementType.rightArm.icon, Icons.front_hand);
      });

      test('returns Icons.directions_walk for thighs', () {
        expect(MeasurementType.leftThigh.icon, Icons.directions_walk);
        expect(MeasurementType.rightThigh.icon, Icons.directions_walk);
      });

      test('returns Icons.face for neck', () {
        expect(MeasurementType.neck.icon, Icons.face);
      });

      test('returns Icons.airline_seat_recline_normal for shoulders', () {
        expect(
          MeasurementType.shoulders.icon,
          Icons.airline_seat_recline_normal,
        );
      });

      test('returns Icons.directions_run for calves', () {
        expect(MeasurementType.calves.icon, Icons.directions_run);
      });

      test('all measurement types return valid icons', () {
        for (final type in MeasurementType.values) {
          expect(type.icon, isA<IconData>());
        }
      });
    });
  });

  group('MeasurementEntry', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
        );

        expect(entry.id, 'entry-1');
        expect(entry.userId, 'user-1');
        expect(entry.date, testDate);
        expect(entry.createdAt, testDate);
      });

      test('has empty measurements by default', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
        );

        expect(entry.measurements, isEmpty);
      });

      test('creates instance with measurements', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
            MeasurementType.chest.name: 100.0,
          },
        );

        expect(entry.measurements.length, 2);
        expect(entry.measurements[MeasurementType.waist.name], 85.0);
        expect(entry.measurements[MeasurementType.chest.name], 100.0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
          },
        );

        final copy = original.copyWith(
          measurements: {
            MeasurementType.waist.name: 83.0,
            MeasurementType.chest.name: 100.0,
          },
        );

        expect(copy.id, 'entry-1'); // Unchanged
        expect(copy.measurements[MeasurementType.waist.name], 83.0); // Changed
        expect(copy.measurements[MeasurementType.chest.name], 100.0); // Added
      });
    });
  });

  group('MeasurementEntryX extension', () {
    group('getMeasurement', () {
      test('returns measurement value for existing type', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
          },
        );

        expect(entry.getMeasurement(MeasurementType.waist), 85.0);
      });

      test('returns null for non-existing type', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
          },
        );

        expect(entry.getMeasurement(MeasurementType.chest), isNull);
      });
    });

    group('hasMeasurement', () {
      test('returns true for existing measurement', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
          },
        );

        expect(entry.hasMeasurement(MeasurementType.waist), isTrue);
      });

      test('returns false for non-existing measurement', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
          },
        );

        expect(entry.hasMeasurement(MeasurementType.chest), isFalse);
      });

      test('returns false for empty measurements', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
        );

        expect(entry.hasMeasurement(MeasurementType.waist), isFalse);
      });
    });

    group('recordedTypes', () {
      test('returns list of recorded measurement types', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
            MeasurementType.chest.name: 100.0,
            MeasurementType.hips.name: 95.0,
          },
        );

        final recordedTypes = entry.recordedTypes;

        expect(recordedTypes.length, 3);
        expect(recordedTypes, contains(MeasurementType.waist));
        expect(recordedTypes, contains(MeasurementType.chest));
        expect(recordedTypes, contains(MeasurementType.hips));
      });

      test('returns empty list when no measurements', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
        );

        expect(entry.recordedTypes, isEmpty);
      });

      test('ignores invalid measurement type keys', () {
        final entry = MeasurementEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: testDate,
          createdAt: testDate,
          measurements: {
            MeasurementType.waist.name: 85.0,
            'invalidType': 100.0, // Invalid key
          },
        );

        final recordedTypes = entry.recordedTypes;

        expect(recordedTypes.length, 1);
        expect(recordedTypes, contains(MeasurementType.waist));
      });
    });
  });
}
