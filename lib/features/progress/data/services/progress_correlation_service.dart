import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/domain/models/habit_log.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/measurement_entry.dart';

/// Service for analyzing correlations between habits and progress
class ProgressCorrelationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Analyze habit-to-weight correlation
  /// Returns insights about which habits correlate with weight changes
  Future<HabitProgressInsights> analyzeHabitWeightCorrelation({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Fetch habits and their logs
    final habitsSnapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    final habits = habitsSnapshot.docs
        .map((doc) => Habit.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Fetch habit logs
    final habitLogsSnapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))))
        .get();

    final habitLogs = habitLogsSnapshot.docs
        .map((doc) => HabitLog.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Fetch weight entries
    final weightEntriesSnapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))))
        .orderBy('date', descending: false)
        .get();

    final weightEntries = weightEntriesSnapshot.docs
        .map((doc) => WeightEntry.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // Analyze correlations
    return _computeHabitWeightCorrelations(
      habits: habits,
      habitLogs: habitLogs,
      weightEntries: weightEntries,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Compute habit-weight correlations
  HabitProgressInsights _computeHabitWeightCorrelations({
    required List<Habit> habits,
    required List<HabitLog> habitLogs,
    required List<WeightEntry> weightEntries,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (weightEntries.length < 2) {
      return HabitProgressInsights(
        hasEnoughData: false,
        correlations: [],
        overallWeightChange: 0,
        dateRange: '${_formatDate(startDate)} - ${_formatDate(endDate)}',
      );
    }

    final totalWeightChange =
        weightEntries.last.weight - weightEntries.first.weight;

    final correlations = <HabitCorrelation>[];

    for (final habit in habits) {
      final habitLogsForHabit =
          habitLogs.where((log) => log.habitId == habit.id).toList();

      if (habitLogsForHabit.isEmpty) continue;

      // Calculate completion rate
      final totalDays = endDate.difference(startDate).inDays + 1;
      final completedDays = habitLogsForHabit.where((log) => log.completed).length;
      final completionRate = (completedDays / totalDays * 100).clamp(0, 100);

      // Group habit completion by week and correlate with weight changes
      final weeklyData = _groupHabitLogsByWeek(habitLogsForHabit, startDate, endDate);
      final weeklyWeightData = _groupWeightByWeek(weightEntries, startDate, endDate);

      // Simple correlation: check if weeks with high habit completion had better weight outcomes
      double correlationScore = 0;
      int weekCount = 0;

      for (final week in weeklyData.keys) {
        if (weeklyWeightData.containsKey(week)) {
          final habitCompletionRate = weeklyData[week]!;
          final weightChangeInWeek = weeklyWeightData[week]!;

          // Positive correlation: high completion = weight loss (negative change)
          // Negative correlation: high completion = weight gain (positive change)
          if (totalWeightChange < 0) {
            // User is losing weight (good)
            if (habitCompletionRate > 0.5 && weightChangeInWeek < 0) {
              correlationScore += 1; // Positive correlation
            } else if (habitCompletionRate <= 0.5 && weightChangeInWeek >= 0) {
              correlationScore += 1; // Still positive
            }
          } else {
            // User is gaining weight
            if (habitCompletionRate > 0.5 && weightChangeInWeek > 0) {
              correlationScore -= 1; // This habit may be causing gain
            }
          }
          weekCount++;
        }
      }

      final normalizedCorrelation = weekCount > 0 ? correlationScore / weekCount : 0;

      correlations.add(HabitCorrelation(
        habit: habit,
        completionRate: completionRate,
        correlationStrength: normalizedCorrelation,
        insight: _generateHabitInsight(
          habit: habit,
          completionRate: completionRate,
          correlationStrength: normalizedCorrelation,
          weightChange: totalWeightChange,
        ),
      ));
    }

    // Sort by correlation strength (absolute value)
    correlations.sort((a, b) =>
        b.correlationStrength.abs().compareTo(a.correlationStrength.abs()));

    return HabitProgressInsights(
      hasEnoughData: true,
      correlations: correlations,
      overallWeightChange: totalWeightChange,
      dateRange: '${_formatDate(startDate)} - ${_formatDate(endDate)}',
    );
  }

  /// Group habit logs by week
  Map<int, double> _groupHabitLogsByWeek(
    List<HabitLog> logs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<int, List<HabitLog>> weeklyLogs = {};

    for (final log in logs) {
      final weekNumber = log.date.difference(startDate).inDays ~/ 7;
      weeklyLogs.putIfAbsent(weekNumber, () => []).add(log);
    }

    // Calculate completion rate for each week
    final Map<int, double> weeklyCompletionRates = {};
    for (final week in weeklyLogs.keys) {
      final logsInWeek = weeklyLogs[week]!;
      final completedCount = logsInWeek.where((log) => log.completed).length;
      weeklyCompletionRates[week] = completedCount / logsInWeek.length;
    }

    return weeklyCompletionRates;
  }

  /// Group weight entries by week
  Map<int, double> _groupWeightByWeek(
    List<WeightEntry> entries,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<int, List<WeightEntry>> weeklyEntries = {};

    for (final entry in entries) {
      final weekNumber = entry.date.difference(startDate).inDays ~/ 7;
      weeklyEntries.putIfAbsent(weekNumber, () => []).add(entry);
    }

    // Calculate weight change for each week
    final Map<int, double> weeklyWeightChanges = {};
    for (final week in weeklyEntries.keys) {
      final entriesInWeek = weeklyEntries[week]!;
      if (entriesInWeek.length >= 2) {
        final change =
            entriesInWeek.last.weight - entriesInWeek.first.weight;
        weeklyWeightChanges[week] = change;
      }
    }

    return weeklyWeightChanges;
  }

  /// Generate insight text for habit correlation
  String _generateHabitInsight({
    required Habit habit,
    required double completionRate,
    required double correlationStrength,
    required double weightChange,
  }) {
    if (completionRate < 20) {
      return 'You completed "${habit.name}" only ${completionRate.toStringAsFixed(0)}% of the time. Try to be more consistent to see its impact!';
    }

    if (correlationStrength.abs() < 0.2) {
      return 'No clear correlation yet between "${habit.name}" and weight changes. Keep tracking!';
    }

    final isLosingWeight = weightChange < 0;

    if (correlationStrength > 0.5) {
      // Strong positive correlation
      if (isLosingWeight) {
        return '${habit.name}" appears to help with weight loss! You completed it ${completionRate.toStringAsFixed(0)}% of the time, and weeks with better completion showed more progress.';
      } else {
        return '"${habit.name}" may be contributing to weight gain. Completed ${completionRate.toStringAsFixed(0)}% of the time.';
      }
    } else if (correlationStrength > 0.2) {
      // Moderate positive correlation
      return '"${habit.name}" might be helping! Keep it up (${completionRate.toStringAsFixed(0)}% completion rate).';
    } else if (correlationStrength < -0.2) {
      // Negative correlation
      return '"${habit.name}" doesn\'t seem to correlate with your progress. Consider adjusting this habit.';
    }

    return 'No clear pattern yet for "${habit.name}". Keep tracking to see the impact!';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// Insights about habit-progress correlations
class HabitProgressInsights {
  final bool hasEnoughData;
  final List<HabitCorrelation> correlations;
  final double overallWeightChange;
  final String dateRange;

  HabitProgressInsights({
    required this.hasEnoughData,
    required this.correlations,
    required this.overallWeightChange,
    required this.dateRange,
  });

  /// Get top positive correlations (habits that help)
  List<HabitCorrelation> get topHelpfulHabits {
    return correlations
        .where((c) => c.correlationStrength > 0.3)
        .take(3)
        .toList();
  }

  /// Get habits with negative or no correlation
  List<HabitCorrelation> get habitsToReview {
    return correlations
        .where((c) => c.correlationStrength < 0.2)
        .take(3)
        .toList();
  }
}

/// Correlation between a habit and progress
class HabitCorrelation {
  final Habit habit;
  final double completionRate; // 0-100
  final double correlationStrength; // -1 to 1
  final String insight;

  HabitCorrelation({
    required this.habit,
    required this.completionRate,
    required this.correlationStrength,
    required this.insight,
  });

  /// Get strength label
  String get strengthLabel {
    final abs = correlationStrength.abs();
    if (abs > 0.7) return 'Strong';
    if (abs > 0.4) return 'Moderate';
    if (abs > 0.2) return 'Weak';
    return 'Unclear';
  }

  /// Is this a positive correlation?
  bool get isPositive => correlationStrength > 0.2;

  /// Is this a negative correlation?
  bool get isNegative => correlationStrength < -0.2;
}
