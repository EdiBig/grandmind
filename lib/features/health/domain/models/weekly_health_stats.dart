import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'weekly_health_stats.freezed.dart';
part 'weekly_health_stats.g.dart';

/// Model for weekly health statistics
@freezed
class WeeklyHealthStats with _$WeeklyHealthStats {
  const factory WeeklyHealthStats({
    required int totalSteps,
    required double totalDistanceKm,
    required double totalCalories,
    required double averageHeartRate,
    required double averageSleepHours,
    required int daysWithData,
    @TimestampConverter() required DateTime weekStartDate,
    @TimestampConverter() required DateTime weekEndDate,
  }) = _WeeklyHealthStats;

  const WeeklyHealthStats._();

  factory WeeklyHealthStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyHealthStatsFromJson(json);

  /// Average steps per day
  double get averageStepsPerDay =>
      daysWithData > 0 ? totalSteps / daysWithData : 0;

  /// Average distance per day
  double get averageDistancePerDay =>
      daysWithData > 0 ? totalDistanceKm / daysWithData : 0;

  /// Average calories per day
  double get averageCaloriesPerDay =>
      daysWithData > 0 ? totalCalories / daysWithData : 0;
}

/// Model for daily health data point (for charts)
@freezed
class DailyHealthPoint with _$DailyHealthPoint {
  const factory DailyHealthPoint({
    @TimestampConverter() required DateTime date,
    required int steps,
    required double distanceKm,
    required double calories,
    double? heartRate,
    required double sleepHours,
  }) = _DailyHealthPoint;

  factory DailyHealthPoint.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthPointFromJson(json);
}
