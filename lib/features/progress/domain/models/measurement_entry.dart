import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'measurement_entry.freezed.dart';
part 'measurement_entry.g.dart';

/// Enum for different body measurement types
enum MeasurementType {
  waist,
  chest,
  hips,
  leftArm,
  rightArm,
  leftThigh,
  rightThigh,
  neck,
  shoulders,
  calves;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MeasurementType.waist:
        return 'Waist';
      case MeasurementType.chest:
        return 'Chest';
      case MeasurementType.hips:
        return 'Hips';
      case MeasurementType.leftArm:
        return 'Left Arm';
      case MeasurementType.rightArm:
        return 'Right Arm';
      case MeasurementType.leftThigh:
        return 'Left Thigh';
      case MeasurementType.rightThigh:
        return 'Right Thigh';
      case MeasurementType.neck:
        return 'Neck';
      case MeasurementType.shoulders:
        return 'Shoulders';
      case MeasurementType.calves:
        return 'Calves';
    }
  }

  /// Icon for each measurement type
  IconData get icon {
    switch (this) {
      case MeasurementType.waist:
        return Icons.fitbit;
      case MeasurementType.chest:
        return Icons.favorite;
      case MeasurementType.hips:
        return Icons.accessibility_new;
      case MeasurementType.leftArm:
      case MeasurementType.rightArm:
        return Icons.front_hand;
      case MeasurementType.leftThigh:
      case MeasurementType.rightThigh:
        return Icons.directions_walk;
      case MeasurementType.neck:
        return Icons.face;
      case MeasurementType.shoulders:
        return Icons.airline_seat_recline_normal;
      case MeasurementType.calves:
        return Icons.directions_run;
    }
  }
}

/// Model for body measurement entry
/// All measurements stored in centimeters (cm) internally
/// UI can convert to inches based on user preferences
/// Stores all measurements in a single Map to reduce Firestore reads
@freezed
class MeasurementEntry with _$MeasurementEntry {
  const factory MeasurementEntry({
    required String id,
    required String userId,
    @Default({}) Map<String, double> measurements, // Key: MeasurementType.name, Value: cm
    @TimestampConverter() required DateTime date, // Allows backdating
    @TimestampConverter() required DateTime createdAt,
    String? notes,
  }) = _MeasurementEntry;

  factory MeasurementEntry.fromJson(Map<String, dynamic> json) =>
      _$MeasurementEntryFromJson(json);
}

/// Extension to work with typed measurements
extension MeasurementEntryX on MeasurementEntry {
  /// Get measurement value for a specific type
  double? getMeasurement(MeasurementType type) {
    return measurements[type.name];
  }

  /// Check if a measurement type has been recorded
  bool hasMeasurement(MeasurementType type) {
    return measurements.containsKey(type.name) &&
        measurements[type.name] != null;
  }

  /// Get all recorded measurement types
  List<MeasurementType> get recordedTypes {
    return measurements.keys
        .map((key) {
          try {
            return MeasurementType.values.firstWhere((e) => e.name == key);
          } catch (_) {
            return null;
          }
        })
        .whereType<MeasurementType>()
        .toList();
  }
}
