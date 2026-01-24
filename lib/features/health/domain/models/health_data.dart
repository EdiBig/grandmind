import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'health_data.freezed.dart';
part 'health_data.g.dart';

/// Enum for health data source
enum HealthDataSource {
  appleHealth,
  googleFit,
  manual,
  unknown,
}

/// Details about the source device/app
@freezed
class HealthSourceDetails with _$HealthSourceDetails {
  const factory HealthSourceDetails({
    String? deviceName,
    String? deviceModel,
    String? appName,
    @TimestampConverter() DateTime? originalTimestamp,
  }) = _HealthSourceDetails;

  factory HealthSourceDetails.fromJson(Map<String, dynamic> json) =>
      _$HealthSourceDetailsFromJson(json);
}

/// Model for daily health data
@freezed
class HealthData with _$HealthData {
  const factory HealthData({
    required String id,
    required String userId,
    @TimestampConverter() required DateTime date,
    required int steps,
    required double distanceMeters,
    required double caloriesBurned,
    double? averageHeartRate,
    required double sleepHours,
    double? weight,
    @Default(HealthDataSource.unknown) HealthDataSource source,
    HealthSourceDetails? sourceDetails,
    @TimestampConverter() required DateTime syncedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _HealthData;

  const HealthData._();

  factory HealthData.fromJson(Map<String, dynamic> json) =>
      _$HealthDataFromJson(json);

  /// Convert distance from meters to kilometers
  double get distanceKm => distanceMeters / 1000.0;

  /// Check if this health data has meaningful information
  bool get hasMeaningfulData =>
      steps > 0 ||
      distanceMeters > 0 ||
      caloriesBurned > 0 ||
      sleepHours > 0 ||
      averageHeartRate != null;

  /// Get a formatted date string (e.g., "2026-01-06")
  String get dateString {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Create a HealthData from HealthSummary (from service)
  factory HealthData.fromHealthSummary({
    required String id,
    required String userId,
    required DateTime date,
    required int steps,
    required double distanceMeters,
    required double caloriesBurned,
    double? averageHeartRate,
    required double sleepHours,
    double? weight,
  }) {
    return HealthData(
      id: id,
      userId: userId,
      date: date,
      steps: steps,
      distanceMeters: distanceMeters,
      caloriesBurned: caloriesBurned,
      averageHeartRate: averageHeartRate,
      sleepHours: sleepHours,
      weight: weight,
      syncedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
