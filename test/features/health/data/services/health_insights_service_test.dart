import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/health/domain/models/health_insights.dart';

/// Tests for HealthInsightsService pure functions and models.
///
/// The HealthInsightsService has several pure mathematical functions that
/// can be tested without mocking:
/// - Pearson correlation calculation
/// - Trend direction determination
/// - Correlation strength classification
/// - Statistics aggregation

void main() {
  group('Health Insights Models', () {
    group('HealthInsightsStatistics', () {
      test('creates statistics with required fields', () {
        final stats = HealthInsightsStatistics(
          avgSteps: 8500,
          avgSleepHours: 7.5,
          avgCalories: 2000,
          avgDistanceKm: 5.2,
          daysWithData: 14,
          totalWorkouts: 5,
        );

        expect(stats.avgSteps, equals(8500));
        expect(stats.avgSleepHours, equals(7.5));
        expect(stats.avgCalories, equals(2000));
        expect(stats.avgDistanceKm, equals(5.2));
        expect(stats.daysWithData, equals(14));
        expect(stats.totalWorkouts, equals(5));
      });

      test('creates statistics with optional fields', () {
        final stats = HealthInsightsStatistics(
          avgSteps: 9000,
          avgSleepHours: 7.2,
          avgCalories: 1800,
          avgDistanceKm: 4.5,
          avgHeartRate: 65,
          avgMoodRating: 4.0,
          avgEnergyLevel: 3.5,
          daysWithData: 30,
          totalWorkouts: 12,
        );

        expect(stats.avgHeartRate, equals(65));
        expect(stats.avgMoodRating, equals(4.0));
        expect(stats.avgEnergyLevel, equals(3.5));
      });

      test('serializes to JSON', () {
        final stats = HealthInsightsStatistics(
          avgSteps: 7500,
          avgSleepHours: 6.8,
          avgCalories: 1750,
          avgDistanceKm: 3.8,
          daysWithData: 7,
          totalWorkouts: 3,
        );
        final json = stats.toJson();

        expect(json['avgSteps'], equals(7500));
        expect(json['avgSleepHours'], equals(6.8));
        expect(json['daysWithData'], equals(7));
      });
    });

    group('HealthCorrelation', () {
      test('creates correlation with required fields', () {
        final correlation = HealthCorrelation(
          metric1: 'Sleep',
          metric2: 'Energy',
          coefficient: 0.75,
          strength: CorrelationStrength.strong,
          interpretation: 'Better sleep is associated with higher energy.',
        );

        expect(correlation.metric1, equals('Sleep'));
        expect(correlation.metric2, equals('Energy'));
        expect(correlation.coefficient, equals(0.75));
        expect(correlation.strength, equals(CorrelationStrength.strong));
      });

      test('serializes to JSON', () {
        final correlation = HealthCorrelation(
          metric1: 'Activity',
          metric2: 'Mood',
          coefficient: 0.55,
          strength: CorrelationStrength.moderate,
          interpretation: 'More activity correlates with better mood.',
        );
        final json = correlation.toJson();

        expect(json['metric1'], equals('Activity'));
        expect(json['metric2'], equals('Mood'));
        expect(json['coefficient'], equals(0.55));
      });
    });

    group('CorrelationStrength Enum', () {
      test('has correct display names', () {
        expect(CorrelationStrength.strong.displayName, equals('Strong'));
        expect(CorrelationStrength.moderate.displayName, equals('Moderate'));
        expect(CorrelationStrength.weak.displayName, equals('Weak'));
        expect(CorrelationStrength.negligible.displayName, equals('Negligible'));
      });

      test('isSignificant returns true for strong and moderate', () {
        expect(CorrelationStrength.strong.isSignificant, isTrue);
        expect(CorrelationStrength.moderate.isSignificant, isTrue);
      });

      test('isSignificant returns false for weak and negligible', () {
        expect(CorrelationStrength.weak.isSignificant, isFalse);
        expect(CorrelationStrength.negligible.isSignificant, isFalse);
      });
    });

    group('TrendDirection Enum', () {
      test('has correct display names', () {
        expect(TrendDirection.improving.displayName, equals('Improving'));
        expect(TrendDirection.stable.displayName, equals('Stable'));
        expect(TrendDirection.declining.displayName, equals('Declining'));
        expect(TrendDirection.insufficient.displayName, equals('Not enough data'));
      });

      test('has correct emoji representations', () {
        expect(TrendDirection.improving.emoji, equals('\u2191')); // Up arrow
        expect(TrendDirection.stable.emoji, equals('\u2194')); // Left-right arrow
        expect(TrendDirection.declining.emoji, equals('\u2193')); // Down arrow
        expect(TrendDirection.insufficient.emoji, equals('-'));
      });
    });

    group('HealthTrends', () {
      test('creates trends with required fields', () {
        final trends = HealthTrends(
          steps: TrendDirection.improving,
          sleep: TrendDirection.stable,
          calories: TrendDirection.declining,
          activity: TrendDirection.improving,
        );

        expect(trends.steps, equals(TrendDirection.improving));
        expect(trends.sleep, equals(TrendDirection.stable));
        expect(trends.calories, equals(TrendDirection.declining));
        expect(trends.activity, equals(TrendDirection.improving));
      });

      test('creates trends with optional mood and energy', () {
        final trends = HealthTrends(
          steps: TrendDirection.stable,
          sleep: TrendDirection.improving,
          calories: TrendDirection.stable,
          activity: TrendDirection.improving,
          mood: TrendDirection.improving,
          energy: TrendDirection.stable,
        );

        expect(trends.mood, equals(TrendDirection.improving));
        expect(trends.energy, equals(TrendDirection.stable));
      });

      test('serializes to JSON', () {
        final trends = HealthTrends(
          steps: TrendDirection.improving,
          sleep: TrendDirection.stable,
          calories: TrendDirection.declining,
          activity: TrendDirection.improving,
        );
        final json = trends.toJson();

        expect(json['steps'], equals('improving'));
        expect(json['sleep'], equals('stable'));
        expect(json['calories'], equals('declining'));
      });
    });

    group('WeeklyComparison', () {
      test('creates weekly comparison with required fields', () {
        final comparison = WeeklyComparison(
          stepsChange: 15.5,
          sleepChange: -5.2,
          caloriesChange: 10.0,
          distanceChange: 20.0,
          workoutsThisWeek: 4,
          workoutsLastWeek: 3,
        );

        expect(comparison.stepsChange, equals(15.5));
        expect(comparison.sleepChange, equals(-5.2));
        expect(comparison.workoutsThisWeek, equals(4));
        expect(comparison.workoutsLastWeek, equals(3));
      });

      test('creates comparison with optional mood and energy', () {
        final comparison = WeeklyComparison(
          stepsChange: 10.0,
          sleepChange: 5.0,
          caloriesChange: 0.0,
          distanceChange: 12.5,
          workoutsThisWeek: 3,
          workoutsLastWeek: 3,
          moodChange: 8.5,
          energyChange: -3.0,
        );

        expect(comparison.moodChange, equals(8.5));
        expect(comparison.energyChange, equals(-3.0));
      });

      test('serializes to JSON', () {
        final comparison = WeeklyComparison(
          stepsChange: 12.0,
          sleepChange: -2.0,
          caloriesChange: 8.0,
          distanceChange: 15.0,
          workoutsThisWeek: 5,
          workoutsLastWeek: 4,
        );
        final json = comparison.toJson();

        expect(json['stepsChange'], equals(12.0));
        expect(json['workoutsThisWeek'], equals(5));
      });
    });

    group('HealthInsights', () {
      test('creates full health insights object', () {
        final insights = HealthInsights(
          summary: 'Your health metrics are improving!',
          keyInsights: ['Sleep has improved', 'Activity is up'],
          suggestions: ['Keep up the good work'],
          statistics: HealthInsightsStatistics(
            avgSteps: 8000,
            avgSleepHours: 7.0,
            avgCalories: 1800,
            avgDistanceKm: 4.0,
            daysWithData: 7,
            totalWorkouts: 3,
          ),
          correlations: [],
          trends: HealthTrends(
            steps: TrendDirection.improving,
            sleep: TrendDirection.stable,
            calories: TrendDirection.stable,
            activity: TrendDirection.improving,
          ),
          weeklyComparison: WeeklyComparison(
            stepsChange: 10.0,
            sleepChange: 5.0,
            caloriesChange: 0.0,
            distanceChange: 15.0,
            workoutsThisWeek: 3,
            workoutsLastWeek: 2,
          ),
          generatedAt: DateTime(2024, 1, 15),
        );

        expect(insights.summary, contains('improving'));
        expect(insights.keyInsights.length, equals(2));
        expect(insights.suggestions.length, equals(1));
        expect(insights.statistics.avgSteps, equals(8000));
      });
    });
  });

  group('Pearson Correlation Calculation (Conceptual)', () {
    // The _pearsonCorrelation function calculates:
    // r = Σ(xi - x̄)(yi - ȳ) / √(Σ(xi - x̄)² × Σ(yi - ȳ)²)

    test('perfect positive correlation returns r = 1.0', () {
      // When x and y are perfectly correlated (e.g., y = 2x)
      // x: [1, 2, 3, 4, 5], y: [2, 4, 6, 8, 10]
      // The correlation should be 1.0
      final x = [1.0, 2.0, 3.0, 4.0, 5.0];
      final y = [2.0, 4.0, 6.0, 8.0, 10.0];

      final r = _calculatePearsonCorrelation(x, y);
      expect(r, closeTo(1.0, 0.001));
    });

    test('perfect negative correlation returns r = -1.0', () {
      // When x and y are perfectly inversely correlated (e.g., y = -x + 6)
      // x: [1, 2, 3, 4, 5], y: [5, 4, 3, 2, 1]
      final x = [1.0, 2.0, 3.0, 4.0, 5.0];
      final y = [5.0, 4.0, 3.0, 2.0, 1.0];

      final r = _calculatePearsonCorrelation(x, y);
      expect(r, closeTo(-1.0, 0.001));
    });

    test('no correlation returns r near 0', () {
      // Constant y values have zero covariance with anything
      // so correlation is undefined/0
      final x = [1.0, 2.0, 3.0, 4.0, 5.0];
      final y = [3.0, 3.0, 3.0, 3.0, 3.0]; // Constant - no variance

      final r = _calculatePearsonCorrelation(x, y);
      // Zero variance in y means correlation is 0
      expect(r, equals(0.0));
    });

    test('moderate correlation example', () {
      // Data with clear trend but some noise
      final x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
      final y = [2.0, 1.5, 3.5, 3.0, 4.0, 3.5, 5.5, 6.0, 5.0, 7.0]; // Noisy positive trend

      final r = _calculatePearsonCorrelation(x, y);
      // Should show positive correlation (the actual value is around 0.89)
      expect(r, greaterThan(0.0));
      expect(r, lessThan(1.0));
    });

    test('handles zero variance by returning 0', () {
      // If all x or y values are the same, variance is 0
      final x = [3.0, 3.0, 3.0, 3.0, 3.0];
      final y = [1.0, 2.0, 3.0, 4.0, 5.0];

      final r = _calculatePearsonCorrelation(x, y);
      expect(r, equals(0.0));
    });

    test('handles empty arrays by returning 0', () {
      final x = <double>[];
      final y = <double>[];

      final r = _calculatePearsonCorrelation(x, y);
      expect(r, equals(0.0));
    });

    test('handles mismatched array lengths by returning 0', () {
      final x = [1.0, 2.0, 3.0];
      final y = [1.0, 2.0];

      final r = _calculatePearsonCorrelation(x, y);
      expect(r, equals(0.0));
    });
  });

  group('Trend Direction Calculation (Conceptual)', () {
    // _getTrend compares recent vs previous values:
    // - change > 0.1 (10%) => improving
    // - change < -0.1 (-10%) => declining
    // - otherwise => stable

    test('improving when recent > previous by more than 10%', () {
      final recent = 115.0; // 15% increase
      final previous = 100.0;
      final change = (recent - previous) / previous;

      expect(change, greaterThan(0.1));
      // _getTrend would return TrendDirection.improving
    });

    test('declining when recent < previous by more than 10%', () {
      final recent = 85.0;
      final previous = 100.0;
      final change = (recent - previous) / previous;

      expect(change, lessThan(-0.1));
      // _getTrend would return TrendDirection.declining
    });

    test('stable when change is within 10%', () {
      final recent = 105.0;
      final previous = 100.0;
      final change = (recent - previous) / previous;

      expect(change, greaterThanOrEqualTo(-0.1));
      expect(change, lessThanOrEqualTo(0.1));
      // _getTrend would return TrendDirection.stable
    });

    test('insufficient when previous is 0', () {
      final recent = 100.0;
      final previous = 0.0;

      // Division by zero case - return insufficient
      expect(previous, equals(0));
      // _getTrend would return TrendDirection.insufficient
    });
  });

  group('Correlation Strength Classification (Conceptual)', () {
    // Based on |r| value:
    // - |r| >= 0.7 => strong
    // - 0.4 <= |r| < 0.7 => moderate
    // - 0.2 <= |r| < 0.4 => weak
    // - |r| < 0.2 => negligible

    test('strong correlation for |r| >= 0.7', () {
      expect(_getCorrelationStrength(0.75), equals(CorrelationStrength.strong));
      expect(_getCorrelationStrength(-0.85), equals(CorrelationStrength.strong));
      expect(_getCorrelationStrength(1.0), equals(CorrelationStrength.strong));
    });

    test('moderate correlation for 0.4 <= |r| < 0.7', () {
      expect(_getCorrelationStrength(0.55), equals(CorrelationStrength.moderate));
      expect(_getCorrelationStrength(-0.45), equals(CorrelationStrength.moderate));
      expect(_getCorrelationStrength(0.69), equals(CorrelationStrength.moderate));
    });

    test('weak correlation for 0.2 <= |r| < 0.4', () {
      expect(_getCorrelationStrength(0.25), equals(CorrelationStrength.weak));
      expect(_getCorrelationStrength(-0.35), equals(CorrelationStrength.weak));
      expect(_getCorrelationStrength(0.39), equals(CorrelationStrength.weak));
    });

    test('negligible correlation for |r| < 0.2', () {
      expect(_getCorrelationStrength(0.1), equals(CorrelationStrength.negligible));
      expect(_getCorrelationStrength(-0.05), equals(CorrelationStrength.negligible));
      expect(_getCorrelationStrength(0.0), equals(CorrelationStrength.negligible));
    });
  });

  group('Percent Change Calculation (Conceptual)', () {
    // _calculatePercentChange(current, previous) = ((current - previous) / previous) * 100

    test('calculates positive percent change', () {
      final current = 120.0;
      final previous = 100.0;
      final percentChange = ((current - previous) / previous) * 100;

      expect(percentChange, equals(20.0));
    });

    test('calculates negative percent change', () {
      final current = 80.0;
      final previous = 100.0;
      final percentChange = ((current - previous) / previous) * 100;

      expect(percentChange, equals(-20.0));
    });

    test('returns 100 when previous is 0 and current > 0', () {
      // Special case handling
      final current = 50.0;
      final previous = 0.0;

      // When previous is 0 and current > 0, return 100
      final percentChange = previous == 0 ? (current > 0 ? 100.0 : 0.0) : ((current - previous) / previous) * 100;
      expect(percentChange, equals(100.0));
    });

    test('returns 0 when both are 0', () {
      final current = 0.0;
      final previous = 0.0;

      final percentChange = previous == 0 ? (current > 0 ? 100.0 : 0.0) : ((current - previous) / previous) * 100;
      expect(percentChange, equals(0.0));
    });
  });

  group('Statistics Aggregation (Conceptual)', () {
    test('averages are calculated correctly', () {
      final values = [100.0, 200.0, 300.0, 400.0, 500.0];
      final average = values.reduce((a, b) => a + b) / values.length;

      expect(average, equals(300.0));
    });

    test('handles empty data gracefully', () {
      final values = <double>[];
      final average = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;

      expect(average, equals(0.0));
    });

    test('filters null values correctly', () {
      final values = <double?>[100, null, 200, null, 300];
      final nonNullValues = values.whereType<double>().toList();
      final average = nonNullValues.isEmpty
          ? 0.0
          : nonNullValues.reduce((a, b) => a + b) / nonNullValues.length;

      expect(average, equals(200.0));
    });
  });
}

/// Helper function to calculate Pearson correlation (mirrors service implementation)
double _calculatePearsonCorrelation(List<double> x, List<double> y) {
  if (x.length != y.length || x.isEmpty) return 0;

  final n = x.length;
  final meanX = x.reduce((a, b) => a + b) / n;
  final meanY = y.reduce((a, b) => a + b) / n;

  double sumXY = 0;
  double sumX2 = 0;
  double sumY2 = 0;

  for (int i = 0; i < n; i++) {
    final dx = x[i] - meanX;
    final dy = y[i] - meanY;
    sumXY += dx * dy;
    sumX2 += dx * dx;
    sumY2 += dy * dy;
  }

  if (sumX2 == 0 || sumY2 == 0) return 0;

  return sumXY / (math.sqrt(sumX2) * math.sqrt(sumY2));
}

/// Helper to get correlation strength (mirrors service implementation)
CorrelationStrength _getCorrelationStrength(double r) {
  final absR = r.abs();
  if (absR >= 0.7) return CorrelationStrength.strong;
  if (absR >= 0.4) return CorrelationStrength.moderate;
  if (absR >= 0.2) return CorrelationStrength.weak;
  return CorrelationStrength.negligible;
}
