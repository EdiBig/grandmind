import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_insights.freezed.dart';
part 'health_insights.g.dart';

/// Main container for health insights
@freezed
class HealthInsights with _$HealthInsights {
  const factory HealthInsights({
    required String summary,
    required List<String> keyInsights,
    required List<String> suggestions,
    required HealthInsightsStatistics statistics,
    required List<HealthCorrelation> correlations,
    required HealthTrends trends,
    required WeeklyComparison weeklyComparison,
    required DateTime generatedAt,
  }) = _HealthInsights;

  factory HealthInsights.fromJson(Map<String, dynamic> json) =>
      _$HealthInsightsFromJson(json);
}

/// Aggregated statistics for health data
@freezed
class HealthInsightsStatistics with _$HealthInsightsStatistics {
  const factory HealthInsightsStatistics({
    required double avgSteps,
    required double avgSleepHours,
    required double avgCalories,
    required double avgDistanceKm,
    double? avgHeartRate,
    double? avgMoodRating,
    double? avgEnergyLevel,
    required int daysWithData,
    required int totalWorkouts,
  }) = _HealthInsightsStatistics;

  factory HealthInsightsStatistics.fromJson(Map<String, dynamic> json) =>
      _$HealthInsightsStatisticsFromJson(json);
}

/// Correlation between two health metrics
@freezed
class HealthCorrelation with _$HealthCorrelation {
  const factory HealthCorrelation({
    required String metric1,
    required String metric2,
    required double coefficient,
    required CorrelationStrength strength,
    required String interpretation,
  }) = _HealthCorrelation;

  factory HealthCorrelation.fromJson(Map<String, dynamic> json) =>
      _$HealthCorrelationFromJson(json);
}

/// Correlation strength categories
enum CorrelationStrength {
  strong,      // |r| >= 0.7
  moderate,    // 0.4 <= |r| < 0.7
  weak,        // 0.2 <= |r| < 0.4
  negligible,  // |r| < 0.2
}

/// Trend direction for health metrics
enum TrendDirection {
  improving,
  stable,
  declining,
  insufficient,  // Not enough data
}

/// Trends for various health metrics
@freezed
class HealthTrends with _$HealthTrends {
  const factory HealthTrends({
    required TrendDirection steps,
    required TrendDirection sleep,
    required TrendDirection calories,
    required TrendDirection activity,
    TrendDirection? mood,
    TrendDirection? energy,
    TrendDirection? weight,
  }) = _HealthTrends;

  factory HealthTrends.fromJson(Map<String, dynamic> json) =>
      _$HealthTrendsFromJson(json);
}

/// Weekly comparison (this week vs last week)
@freezed
class WeeklyComparison with _$WeeklyComparison {
  const factory WeeklyComparison({
    required double stepsChange,       // Percentage change
    required double sleepChange,
    required double caloriesChange,
    required double distanceChange,
    required int workoutsThisWeek,
    required int workoutsLastWeek,
    double? moodChange,
    double? energyChange,
  }) = _WeeklyComparison;

  factory WeeklyComparison.fromJson(Map<String, dynamic> json) =>
      _$WeeklyComparisonFromJson(json);
}

/// Extension for correlation strength helpers
extension CorrelationStrengthExtension on CorrelationStrength {
  String get displayName {
    switch (this) {
      case CorrelationStrength.strong:
        return 'Strong';
      case CorrelationStrength.moderate:
        return 'Moderate';
      case CorrelationStrength.weak:
        return 'Weak';
      case CorrelationStrength.negligible:
        return 'Negligible';
    }
  }

  bool get isSignificant =>
      this == CorrelationStrength.strong || this == CorrelationStrength.moderate;
}

/// Extension for trend direction helpers
extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.insufficient:
        return 'Not enough data';
    }
  }

  String get emoji {
    switch (this) {
      case TrendDirection.improving:
        return '\u2191'; // Up arrow
      case TrendDirection.stable:
        return '\u2194'; // Left-right arrow
      case TrendDirection.declining:
        return '\u2193'; // Down arrow
      case TrendDirection.insufficient:
        return '-';
    }
  }
}
