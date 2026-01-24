import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/progress_goal.dart';

/// Service for generating predictive insights and trend analysis
class PredictiveInsightsService {
  final FirebaseFirestore _firestore;

  PredictiveInsightsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Analyze all progress trends and generate predictive insights
  Future<ProgressPredictions> analyzeProgressTrends({
    required String userId,
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    // Fetch data
    final weightEntries = await _getWeightEntries(userId, startDate, endDate);
    final goals = await _getActiveGoals(userId);

    // Calculate trend
    final weightTrend = _calculateTrend(weightEntries);

    // Predict goal completion
    final goalPredictions = <GoalPrediction>[];
    for (final goal in goals) {
      if (goal.type == GoalType.weight) {
        final prediction = _predictGoalCompletion(goal, weightEntries);
        if (prediction != null) {
          goalPredictions.add(prediction);
        }
      }
    }

    // Generate insights
    final insights = _generateInsights(
      weightTrend: weightTrend,
      weightEntries: weightEntries,
      goalPredictions: goalPredictions,
    );

    return ProgressPredictions(
      weightTrend: weightTrend,
      goalPredictions: goalPredictions,
      insights: insights,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate weight trend using linear regression
  TrendData _calculateTrend(List<WeightEntry> entries) {
    if (entries.length < 2) {
      return TrendData(
        direction: TrendDirection.stable,
        changePerWeek: 0,
        confidence: 0,
        dataPoints: entries.length,
      );
    }

    // Sort by date
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Linear regression
    final n = sorted.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // Day index
      final y = sorted[i].weight;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Calculate R-squared for confidence
    final meanY = sumY / n;
    double ssTotal = 0, ssResidual = 0;

    for (int i = 0; i < n; i++) {
      final y = sorted[i].weight;
      final yPredicted = intercept + slope * i;
      ssTotal += (y - meanY) * (y - meanY);
      ssResidual += (y - yPredicted) * (y - yPredicted);
    }

    final rSquared = ssTotal > 0 ? 1 - (ssResidual / ssTotal) : 0.0;

    // Convert daily slope to weekly change
    final weeklyChange = slope * 7;

    // Determine trend direction
    TrendDirection direction;
    if (weeklyChange.abs() < 0.1) {
      direction = TrendDirection.stable;
    } else if (weeklyChange < 0) {
      direction = TrendDirection.declining;
    } else {
      direction = TrendDirection.improving;
    }

    return TrendData(
      direction: direction,
      changePerWeek: weeklyChange,
      confidence: rSquared.clamp(0.0, 1.0),
      dataPoints: n,
    );
  }

  /// Predict when a goal will be completed based on current trend
  GoalPrediction? _predictGoalCompletion(
    ProgressGoal goal,
    List<WeightEntry> weightEntries,
  ) {
    if (weightEntries.length < 2) return null;

    final sorted = List<WeightEntry>.from(weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final currentWeight = sorted.last.weight;
    final targetWeight = goal.targetValue;
    final remaining = (currentWeight - targetWeight).abs();

    if (remaining < 0.5) {
      // Already at or very close to goal
      return GoalPrediction(
        goal: goal,
        estimatedCompletionDate: DateTime.now(),
        daysRemaining: 0,
        onTrack: true,
        progressPercentage: 100,
        message: 'Congratulations! You\'ve reached your goal!',
      );
    }

    // Calculate average daily change
    final totalDays = sorted.last.date.difference(sorted.first.date).inDays;
    if (totalDays == 0) return null;

    final totalChange = sorted.last.weight - sorted.first.weight;
    final dailyChange = totalChange / totalDays;

    // Predict days to goal
    final isWeightLoss = goal.targetValue < goal.startValue;
    final isMovingCorrectDirection = isWeightLoss
        ? dailyChange < 0
        : dailyChange > 0;

    if (!isMovingCorrectDirection || dailyChange.abs() < 0.001) {
      // Not making progress or moving wrong direction
      return GoalPrediction(
        goal: goal,
        estimatedCompletionDate: null,
        daysRemaining: null,
        onTrack: false,
        progressPercentage: goal.progressPercentage,
        message: isWeightLoss
            ? 'You need to reduce weight to reach your goal. Consider adjusting your approach.'
            : 'You need to gain weight to reach your goal. Consider adjusting your approach.',
      );
    }

    final daysToGoal = (remaining / dailyChange.abs()).round();
    final estimatedDate = DateTime.now().add(Duration(days: daysToGoal));

    // Check if on track for target date
    bool onTrack = true;
    String message;

    if (goal.targetDate != null) {
      final targetDate = goal.targetDate!;
      final daysUntilTarget = targetDate.difference(DateTime.now()).inDays;
      onTrack = daysToGoal <= daysUntilTarget;

      if (onTrack) {
        message = 'You\'re on track to reach your goal ${_formatDaysRemaining(daysToGoal)}!';
      } else {
        final daysOverdue = daysToGoal - daysUntilTarget;
        message = 'At current pace, you\'ll reach your goal $daysOverdue days after your target date.';
      }
    } else {
      message = 'At your current pace, you\'ll reach your goal in about ${_formatDaysRemaining(daysToGoal)}.';
    }

    return GoalPrediction(
      goal: goal,
      estimatedCompletionDate: estimatedDate,
      daysRemaining: daysToGoal,
      onTrack: onTrack,
      progressPercentage: goal.progressPercentage,
      message: message,
    );
  }

  /// Generate actionable insights
  List<String> _generateInsights({
    required TrendData weightTrend,
    required List<WeightEntry> weightEntries,
    required List<GoalPrediction> goalPredictions,
  }) {
    final insights = <String>[];

    // Weight trend insights
    if (weightEntries.length >= 7) {
      final weeklyChange = weightTrend.changePerWeek;
      if (weeklyChange.abs() > 0.5) {
        if (weeklyChange < 0) {
          insights.add(
            'You\'re losing about ${weeklyChange.abs().toStringAsFixed(1)}kg per week. This is a healthy, sustainable pace!',
          );
        } else {
          insights.add(
            'You\'re gaining about ${weeklyChange.toStringAsFixed(1)}kg per week.',
          );
        }
      } else if (weightEntries.length >= 14) {
        insights.add(
          'Your weight has been stable over the past weeks. If you\'re trying to change it, consider adjusting your approach.',
        );
      }
    }

    // Goal predictions
    for (final prediction in goalPredictions) {
      if (prediction.onTrack && prediction.daysRemaining != null) {
        if (prediction.daysRemaining! <= 7) {
          insights.add('You\'re about to reach your ${prediction.goal.title} goal! Keep going!');
        }
      } else if (!prediction.onTrack) {
        insights.add('Consider adjusting your approach to stay on track for "${prediction.goal.title}".');
      }
    }

    // Data consistency
    if (weightEntries.length < 5) {
      insights.add(
        'Log your weight more frequently for better predictions and insights.',
      );
    }

    // Confidence insight
    if (weightTrend.confidence < 0.3 && weightEntries.length >= 5) {
      insights.add(
        'Your weight fluctuates a lot. Try weighing yourself at the same time each day for more consistent data.',
      );
    }

    return insights;
  }

  String _formatDaysRemaining(int days) {
    if (days <= 1) return 'tomorrow';
    if (days < 7) return 'in $days days';
    if (days < 14) return 'in about a week';
    if (days < 30) return 'in ${(days / 7).round()} weeks';
    if (days < 60) return 'in about a month';
    return 'in ${(days / 30).round()} months';
  }

  Future<List<WeightEntry>> _getWeightEntries(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => WeightEntry.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<ProgressGoal>> _getActiveGoals(String userId) async {
    final snapshot = await _firestore
        .collection('progress_goals')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => ProgressGoal.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

/// Overall predictions for progress
class ProgressPredictions {
  final TrendData weightTrend;
  final List<GoalPrediction> goalPredictions;
  final List<String> insights;
  final DateTime lastUpdated;

  ProgressPredictions({
    required this.weightTrend,
    required this.goalPredictions,
    required this.insights,
    required this.lastUpdated,
  });
}

/// Direction of a trend
enum TrendDirection {
  improving,
  declining,
  stable,
}

extension TrendDirectionX on TrendDirection {
  String get label {
    switch (this) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }

  String get emoji {
    switch (this) {
      case TrendDirection.improving:
        return '📈';
      case TrendDirection.declining:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
    }
  }
}

/// Trend analysis data
class TrendData {
  final TrendDirection direction;
  final double changePerWeek;
  final double confidence; // 0-1 (R-squared)
  final int dataPoints;

  TrendData({
    required this.direction,
    required this.changePerWeek,
    required this.confidence,
    required this.dataPoints,
  });

  bool get hasEnoughData => dataPoints >= 3;

  String get confidenceLabel {
    if (confidence > 0.7) return 'High';
    if (confidence > 0.4) return 'Medium';
    return 'Low';
  }
}

/// Prediction for goal completion
class GoalPrediction {
  final ProgressGoal goal;
  final DateTime? estimatedCompletionDate;
  final int? daysRemaining;
  final bool onTrack;
  final double progressPercentage;
  final String message;

  GoalPrediction({
    required this.goal,
    required this.estimatedCompletionDate,
    required this.daysRemaining,
    required this.onTrack,
    required this.progressPercentage,
    required this.message,
  });
}
