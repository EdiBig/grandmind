import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../domain/models/health_data.dart';
import '../../domain/models/health_insights.dart';
import '../../../mood_energy/domain/models/energy_log.dart';
import '../../../workouts/domain/models/workout_log.dart';
import '../../../ai/data/services/claude_api_service.dart';

/// Service for generating health insights from cross-domain analytics
class HealthInsightsService {
  final ClaudeAPIService? _claudeService;

  HealthInsightsService({ClaudeAPIService? claudeService}) : _claudeService = claudeService;

  /// Generate comprehensive health insights
  Future<HealthInsights> generateInsights({
    required List<HealthData> healthData,
    required List<EnergyLog> energyLogs,
    required List<WorkoutLog> workoutLogs,
  }) async {
    // Calculate statistics
    final statistics = _calculateStatistics(healthData, energyLogs, workoutLogs);

    // Calculate correlations
    final correlations = _calculateCorrelations(healthData, energyLogs, workoutLogs);

    // Calculate trends
    final trends = _calculateTrends(healthData, energyLogs);

    // Calculate weekly comparison
    final weeklyComparison = _calculateWeeklyComparison(healthData, workoutLogs);

    // Generate AI insights
    String summary;
    List<String> keyInsights;
    List<String> suggestions;

    try {
      final aiInsights = await _generateAIInsights(
        statistics: statistics,
        correlations: correlations,
        trends: trends,
        weeklyComparison: weeklyComparison,
      );
      summary = aiInsights['summary'] ?? _getDefaultSummary(statistics, trends);
      keyInsights = (aiInsights['insights'] as List?)?.cast<String>() ??
          _getDefaultInsights(statistics, correlations, trends);
      suggestions = (aiInsights['suggestions'] as List?)?.cast<String>() ??
          _getDefaultSuggestions(statistics, trends);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AI insights generation failed: $e');
      }
      summary = _getDefaultSummary(statistics, trends);
      keyInsights = _getDefaultInsights(statistics, correlations, trends);
      suggestions = _getDefaultSuggestions(statistics, trends);
    }

    return HealthInsights(
      summary: summary,
      keyInsights: keyInsights,
      suggestions: suggestions,
      statistics: statistics,
      correlations: correlations.where((c) => c.strength.isSignificant).toList(),
      trends: trends,
      weeklyComparison: weeklyComparison,
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate aggregated statistics
  HealthInsightsStatistics _calculateStatistics(
    List<HealthData> healthData,
    List<EnergyLog> energyLogs,
    List<WorkoutLog> workoutLogs,
  ) {
    if (healthData.isEmpty) {
      return const HealthInsightsStatistics(
        avgSteps: 0,
        avgSleepHours: 0,
        avgCalories: 0,
        avgDistanceKm: 0,
        daysWithData: 0,
        totalWorkouts: 0,
      );
    }

    final totalSteps = healthData.fold<int>(0, (sum, d) => sum + d.steps);
    final totalSleep = healthData.fold<double>(0, (sum, d) => sum + d.sleepHours);
    final totalCalories = healthData.fold<double>(0, (sum, d) => sum + d.caloriesBurned);
    final totalDistance = healthData.fold<double>(0, (sum, d) => sum + d.distanceKm);

    // Heart rate (only from records that have it)
    final hrData = healthData.where((d) => d.averageHeartRate != null).toList();
    final avgHr = hrData.isNotEmpty
        ? hrData.fold<double>(0, (sum, d) => sum + d.averageHeartRate!) / hrData.length
        : null;

    // Mood and energy from energy logs
    final moodLogs = energyLogs.where((l) => l.moodRating != null).toList();
    final avgMood = moodLogs.isNotEmpty
        ? moodLogs.fold<double>(0, (sum, l) => sum + l.moodRating!) / moodLogs.length
        : null;

    final energyData = energyLogs.where((l) => l.energyLevel != null).toList();
    final avgEnergy = energyData.isNotEmpty
        ? energyData.fold<double>(0, (sum, l) => sum + l.energyLevel!) / energyData.length
        : null;

    return HealthInsightsStatistics(
      avgSteps: totalSteps / healthData.length,
      avgSleepHours: totalSleep / healthData.length,
      avgCalories: totalCalories / healthData.length,
      avgDistanceKm: totalDistance / healthData.length,
      avgHeartRate: avgHr,
      avgMoodRating: avgMood,
      avgEnergyLevel: avgEnergy,
      daysWithData: healthData.length,
      totalWorkouts: workoutLogs.length,
    );
  }

  /// Calculate correlations between metrics using Pearson correlation
  List<HealthCorrelation> _calculateCorrelations(
    List<HealthData> healthData,
    List<EnergyLog> energyLogs,
    List<WorkoutLog> workoutLogs,
  ) {
    final correlations = <HealthCorrelation>[];

    if (healthData.length < 7) {
      // Need at least 7 days for meaningful correlations
      return correlations;
    }

    // Map energy logs by date for easy lookup
    final energyByDate = <String, EnergyLog>{};
    for (final log in energyLogs) {
      final dateKey = _dateKey(log.loggedAt);
      energyByDate[dateKey] = log;
    }

    // Map workout count by date
    final workoutsByDate = <String, int>{};
    for (final workout in workoutLogs) {
      final dateKey = _dateKey(workout.startedAt);
      workoutsByDate[dateKey] = (workoutsByDate[dateKey] ?? 0) + 1;
    }

    // Prepare paired data arrays
    final sleepData = <double>[];
    final energyData = <double>[];
    final moodData = <double>[];
    final stepsData = <double>[];
    final workoutData = <double>[];

    for (final health in healthData) {
      final dateKey = health.dateString;
      final energyLog = energyByDate[dateKey];

      sleepData.add(health.sleepHours);
      stepsData.add(health.steps.toDouble());
      workoutData.add((workoutsByDate[dateKey] ?? 0).toDouble());

      if (energyLog != null) {
        if (energyLog.energyLevel != null) {
          energyData.add(energyLog.energyLevel!.toDouble());
        }
        if (energyLog.moodRating != null) {
          moodData.add(energyLog.moodRating!.toDouble());
        }
      }
    }

    // Sleep <-> Energy correlation
    if (sleepData.length >= 7 && energyData.length >= 7 && sleepData.length == energyData.length) {
      final r = _pearsonCorrelation(sleepData, energyData);
      correlations.add(_createCorrelation('Sleep', 'Energy', r));
    }

    // Sleep <-> Mood correlation
    if (sleepData.length >= 7 && moodData.length >= 7 && sleepData.length == moodData.length) {
      final r = _pearsonCorrelation(sleepData, moodData);
      correlations.add(_createCorrelation('Sleep', 'Mood', r));
    }

    // Steps <-> Workouts correlation
    if (stepsData.length >= 7 && workoutData.length >= 7) {
      final r = _pearsonCorrelation(stepsData, workoutData);
      correlations.add(_createCorrelation('Steps', 'Workouts', r));
    }

    // Activity (steps) <-> Mood correlation
    if (stepsData.length >= 7 && moodData.length >= 7 && stepsData.length == moodData.length) {
      final r = _pearsonCorrelation(stepsData, moodData);
      correlations.add(_createCorrelation('Activity', 'Mood', r));
    }

    // Activity <-> Energy correlation
    if (stepsData.length >= 7 && energyData.length >= 7 && stepsData.length == energyData.length) {
      final r = _pearsonCorrelation(stepsData, energyData);
      correlations.add(_createCorrelation('Activity', 'Energy', r));
    }

    return correlations;
  }

  /// Create a correlation object from coefficient
  HealthCorrelation _createCorrelation(String metric1, String metric2, double r) {
    final absR = r.abs();
    final strength = absR >= 0.7
        ? CorrelationStrength.strong
        : absR >= 0.4
            ? CorrelationStrength.moderate
            : absR >= 0.2
                ? CorrelationStrength.weak
                : CorrelationStrength.negligible;

    final interpretation = _getCorrelationInterpretation(metric1, metric2, r, strength);

    return HealthCorrelation(
      metric1: metric1,
      metric2: metric2,
      coefficient: r,
      strength: strength,
      interpretation: interpretation,
    );
  }

  /// Get human-readable interpretation of correlation
  String _getCorrelationInterpretation(
    String metric1,
    String metric2,
    double r,
    CorrelationStrength strength,
  ) {
    if (strength == CorrelationStrength.negligible) {
      return 'No significant relationship found between $metric1 and $metric2.';
    }

    final direction = r >= 0 ? 'higher' : 'lower';
    final strengthWord = strength == CorrelationStrength.strong ? 'strongly' : 'moderately';

    // Custom interpretations for common pairs
    if (metric1 == 'Sleep' && metric2 == 'Energy') {
      return r >= 0
          ? 'Better sleep is $strengthWord associated with higher energy levels.'
          : 'Surprisingly, more sleep correlates with lower energy. Consider sleep quality.';
    }
    if (metric1 == 'Sleep' && metric2 == 'Mood') {
      return r >= 0
          ? 'Better sleep is $strengthWord linked to improved mood.'
          : 'Sleep duration may not be improving your mood. Quality might matter more.';
    }
    if (metric1 == 'Activity' && metric2 == 'Mood') {
      return r >= 0
          ? 'More activity is $strengthWord associated with better mood.'
          : 'High activity may be linked to lower mood. Consider recovery time.';
    }
    if (metric1 == 'Steps' && metric2 == 'Workouts') {
      return r >= 0
          ? 'Workout days tend to have $direction step counts.'
          : 'You may be less active on rest days, which is normal.';
    }

    return 'Days with $direction $metric1 tend to have $direction $metric2.';
  }

  /// Calculate Pearson correlation coefficient
  double _pearsonCorrelation(List<double> x, List<double> y) {
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

  /// Calculate trends by comparing recent data to historical
  HealthTrends _calculateTrends(
    List<HealthData> healthData,
    List<EnergyLog> energyLogs,
  ) {
    if (healthData.length < 14) {
      return const HealthTrends(
        steps: TrendDirection.insufficient,
        sleep: TrendDirection.insufficient,
        calories: TrendDirection.insufficient,
        activity: TrendDirection.insufficient,
      );
    }

    // Sort by date descending
    final sorted = List<HealthData>.from(healthData)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Recent 7 days vs previous 7 days
    final recent = sorted.take(7).toList();
    final previous = sorted.skip(7).take(7).toList();

    final recentSteps = recent.fold<double>(0, (s, d) => s + d.steps) / recent.length;
    final previousSteps = previous.fold<double>(0, (s, d) => s + d.steps) / previous.length;

    final recentSleep = recent.fold<double>(0, (s, d) => s + d.sleepHours) / recent.length;
    final previousSleep = previous.fold<double>(0, (s, d) => s + d.sleepHours) / previous.length;

    final recentCalories = recent.fold<double>(0, (s, d) => s + d.caloriesBurned) / recent.length;
    final previousCalories = previous.fold<double>(0, (s, d) => s + d.caloriesBurned) / previous.length;

    final recentDistance = recent.fold<double>(0, (s, d) => s + d.distanceKm) / recent.length;
    final previousDistance = previous.fold<double>(0, (s, d) => s + d.distanceKm) / previous.length;

    // Mood and energy trends from energy logs
    TrendDirection? moodTrend;
    TrendDirection? energyTrend;

    if (energyLogs.length >= 14) {
      final sortedLogs = List<EnergyLog>.from(energyLogs)
        ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

      final recentMoods = sortedLogs.take(7).where((l) => l.moodRating != null).toList();
      final previousMoods = sortedLogs.skip(7).take(7).where((l) => l.moodRating != null).toList();

      if (recentMoods.length >= 3 && previousMoods.length >= 3) {
        final recentMoodAvg = recentMoods.fold<double>(0, (s, l) => s + l.moodRating!) / recentMoods.length;
        final previousMoodAvg = previousMoods.fold<double>(0, (s, l) => s + l.moodRating!) / previousMoods.length;
        moodTrend = _getTrend(recentMoodAvg, previousMoodAvg);
      }

      final recentEnergy = sortedLogs.take(7).where((l) => l.energyLevel != null).toList();
      final previousEnergy = sortedLogs.skip(7).take(7).where((l) => l.energyLevel != null).toList();

      if (recentEnergy.length >= 3 && previousEnergy.length >= 3) {
        final recentEnergyAvg = recentEnergy.fold<double>(0, (s, l) => s + l.energyLevel!) / recentEnergy.length;
        final previousEnergyAvg = previousEnergy.fold<double>(0, (s, l) => s + l.energyLevel!) / previousEnergy.length;
        energyTrend = _getTrend(recentEnergyAvg, previousEnergyAvg);
      }
    }

    return HealthTrends(
      steps: _getTrend(recentSteps, previousSteps),
      sleep: _getTrend(recentSleep, previousSleep),
      calories: _getTrend(recentCalories, previousCalories),
      activity: _getTrend(recentDistance, previousDistance),
      mood: moodTrend,
      energy: energyTrend,
    );
  }

  /// Determine trend direction based on percentage change
  TrendDirection _getTrend(double recent, double previous) {
    if (previous == 0) return TrendDirection.insufficient;

    final change = (recent - previous) / previous;

    if (change > 0.1) return TrendDirection.improving;
    if (change < -0.1) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// Calculate weekly comparison
  WeeklyComparison _calculateWeeklyComparison(
    List<HealthData> healthData,
    List<WorkoutLog> workoutLogs,
  ) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    // Filter health data by week
    final thisWeekHealth = healthData.where((d) =>
        d.date.isAfter(thisWeekStart.subtract(const Duration(days: 1)))).toList();
    final lastWeekHealth = healthData.where((d) =>
        d.date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
        d.date.isBefore(thisWeekStart)).toList();

    // Calculate averages
    double thisWeekSteps = 0, lastWeekSteps = 0;
    double thisWeekSleep = 0, lastWeekSleep = 0;
    double thisWeekCalories = 0, lastWeekCalories = 0;
    double thisWeekDistance = 0, lastWeekDistance = 0;

    if (thisWeekHealth.isNotEmpty) {
      thisWeekSteps = thisWeekHealth.fold<double>(0, (s, d) => s + d.steps) / thisWeekHealth.length;
      thisWeekSleep = thisWeekHealth.fold<double>(0, (s, d) => s + d.sleepHours) / thisWeekHealth.length;
      thisWeekCalories = thisWeekHealth.fold<double>(0, (s, d) => s + d.caloriesBurned) / thisWeekHealth.length;
      thisWeekDistance = thisWeekHealth.fold<double>(0, (s, d) => s + d.distanceKm) / thisWeekHealth.length;
    }

    if (lastWeekHealth.isNotEmpty) {
      lastWeekSteps = lastWeekHealth.fold<double>(0, (s, d) => s + d.steps) / lastWeekHealth.length;
      lastWeekSleep = lastWeekHealth.fold<double>(0, (s, d) => s + d.sleepHours) / lastWeekHealth.length;
      lastWeekCalories = lastWeekHealth.fold<double>(0, (s, d) => s + d.caloriesBurned) / lastWeekHealth.length;
      lastWeekDistance = lastWeekHealth.fold<double>(0, (s, d) => s + d.distanceKm) / lastWeekHealth.length;
    }

    // Calculate workouts by week
    final thisWeekWorkouts = workoutLogs.where((w) =>
        w.startedAt.isAfter(thisWeekStart.subtract(const Duration(days: 1)))).length;
    final lastWeekWorkouts = workoutLogs.where((w) =>
        w.startedAt.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
        w.startedAt.isBefore(thisWeekStart)).length;

    return WeeklyComparison(
      stepsChange: _calculatePercentChange(thisWeekSteps, lastWeekSteps),
      sleepChange: _calculatePercentChange(thisWeekSleep, lastWeekSleep),
      caloriesChange: _calculatePercentChange(thisWeekCalories, lastWeekCalories),
      distanceChange: _calculatePercentChange(thisWeekDistance, lastWeekDistance),
      workoutsThisWeek: thisWeekWorkouts,
      workoutsLastWeek: lastWeekWorkouts,
    );
  }

  double _calculatePercentChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// Generate AI-powered insights
  Future<Map<String, dynamic>> _generateAIInsights({
    required HealthInsightsStatistics statistics,
    required List<HealthCorrelation> correlations,
    required HealthTrends trends,
    required WeeklyComparison weeklyComparison,
  }) async {
    if (_claudeService == null) {
      return {};
    }

    final prompt = _buildAIPrompt(statistics, correlations, trends, weeklyComparison);
    final systemPrompt = '''You are a supportive health and fitness coach. Analyze the user's health data and provide personalized, encouraging insights.

Respond with a JSON object containing exactly these fields:
- "summary": A 2-3 sentence overview of their health status (encouraging tone)
- "insights": An array of 3-5 specific observations about their data (strings)
- "suggestions": An array of 2-4 actionable recommendations (strings)

Keep responses concise and practical. Focus on positive progress while gently addressing areas for improvement.
Respond ONLY with valid JSON, no additional text.''';

    try {
      final response = await _claudeService!.sendMessage(
        prompt: prompt,
        systemPrompt: systemPrompt,
        maxTokens: 800,
        temperature: 0.7,
        promptType: 'health_insights',
      );

      // Parse the JSON response
      final content = response.content.trim();
      // Try to extract JSON from the response (in case there's any surrounding text)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AI insights error: $e');
      }
      return {};
    }
  }

  String _buildAIPrompt(
    HealthInsightsStatistics statistics,
    List<HealthCorrelation> correlations,
    HealthTrends trends,
    WeeklyComparison weeklyComparison,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Analyze this health data and provide personalized insights:');
    buffer.writeln();
    buffer.writeln('Statistics (${statistics.daysWithData} days):');
    buffer.writeln('- Average steps: ${statistics.avgSteps.toStringAsFixed(0)}');
    buffer.writeln('- Average sleep: ${statistics.avgSleepHours.toStringAsFixed(1)} hours');
    buffer.writeln('- Average calories burned: ${statistics.avgCalories.toStringAsFixed(0)}');
    buffer.writeln('- Total workouts: ${statistics.totalWorkouts}');
    if (statistics.avgMoodRating != null) {
      buffer.writeln('- Average mood: ${statistics.avgMoodRating!.toStringAsFixed(1)}/5');
    }
    if (statistics.avgEnergyLevel != null) {
      buffer.writeln('- Average energy: ${statistics.avgEnergyLevel!.toStringAsFixed(1)}/5');
    }
    buffer.writeln();

    buffer.writeln('Trends:');
    buffer.writeln('- Steps: ${trends.steps.displayName}');
    buffer.writeln('- Sleep: ${trends.sleep.displayName}');
    buffer.writeln('- Activity: ${trends.activity.displayName}');
    if (trends.mood != null) buffer.writeln('- Mood: ${trends.mood!.displayName}');
    buffer.writeln();

    buffer.writeln('Weekly comparison:');
    buffer.writeln('- Steps change: ${weeklyComparison.stepsChange.toStringAsFixed(1)}%');
    buffer.writeln('- Sleep change: ${weeklyComparison.sleepChange.toStringAsFixed(1)}%');
    buffer.writeln('- Workouts: ${weeklyComparison.workoutsThisWeek} this week vs ${weeklyComparison.workoutsLastWeek} last week');
    buffer.writeln();

    if (correlations.isNotEmpty) {
      buffer.writeln('Notable correlations:');
      for (final c in correlations.where((c) => c.strength.isSignificant)) {
        buffer.writeln('- ${c.metric1} <-> ${c.metric2}: ${c.strength.displayName} (${c.coefficient.toStringAsFixed(2)})');
      }
    }

    return buffer.toString();
  }

  /// Get default summary when AI is unavailable
  String _getDefaultSummary(HealthInsightsStatistics stats, HealthTrends trends) {
    final buffer = StringBuffer();
    buffer.write('Based on ${stats.daysWithData} days of data, ');

    final improvingAreas = <String>[];
    final decliningAreas = <String>[];

    if (trends.steps == TrendDirection.improving) improvingAreas.add('steps');
    if (trends.steps == TrendDirection.declining) decliningAreas.add('steps');
    if (trends.sleep == TrendDirection.improving) improvingAreas.add('sleep');
    if (trends.sleep == TrendDirection.declining) decliningAreas.add('sleep');
    if (trends.activity == TrendDirection.improving) improvingAreas.add('activity');
    if (trends.activity == TrendDirection.declining) decliningAreas.add('activity');

    if (improvingAreas.isNotEmpty) {
      buffer.write('your ${improvingAreas.join(', ')} ${improvingAreas.length == 1 ? 'is' : 'are'} improving. ');
    }
    if (decliningAreas.isNotEmpty) {
      buffer.write('Consider focusing on ${decliningAreas.join(', ')}. ');
    }
    if (improvingAreas.isEmpty && decliningAreas.isEmpty) {
      buffer.write('your health metrics are stable. Keep up the consistent effort!');
    }

    return buffer.toString().trim();
  }

  /// Get default insights when AI is unavailable
  List<String> _getDefaultInsights(
    HealthInsightsStatistics stats,
    List<HealthCorrelation> correlations,
    HealthTrends trends,
  ) {
    final insights = <String>[];

    // Steps insight
    if (stats.avgSteps >= 10000) {
      insights.add('Excellent! You\'re averaging ${stats.avgSteps.toStringAsFixed(0)} steps daily, exceeding the 10,000 step goal.');
    } else if (stats.avgSteps >= 7000) {
      insights.add('You\'re averaging ${stats.avgSteps.toStringAsFixed(0)} steps daily. You\'re close to the recommended 10,000 steps!');
    } else if (stats.avgSteps > 0) {
      insights.add('Your average of ${stats.avgSteps.toStringAsFixed(0)} steps is a good start. Try to gradually increase to 7,000-10,000 steps.');
    }

    // Sleep insight
    if (stats.avgSleepHours >= 7 && stats.avgSleepHours <= 9) {
      insights.add('Your average sleep of ${stats.avgSleepHours.toStringAsFixed(1)} hours is within the recommended 7-9 hour range.');
    } else if (stats.avgSleepHours < 7 && stats.avgSleepHours > 0) {
      insights.add('You\'re averaging ${stats.avgSleepHours.toStringAsFixed(1)} hours of sleep. Consider aiming for 7-9 hours for optimal recovery.');
    }

    // Workout insight
    if (stats.totalWorkouts > 0) {
      final workoutsPerWeek = stats.totalWorkouts / (stats.daysWithData / 7);
      if (workoutsPerWeek >= 3) {
        insights.add('Great workout consistency! You\'re averaging ${workoutsPerWeek.toStringAsFixed(1)} workouts per week.');
      } else {
        insights.add('You\'re averaging ${workoutsPerWeek.toStringAsFixed(1)} workouts per week. Aim for 3-5 sessions for better results.');
      }
    }

    // Correlation insights
    for (final c in correlations.where((c) => c.strength.isSignificant).take(2)) {
      insights.add(c.interpretation);
    }

    return insights.take(5).toList();
  }

  /// Get default suggestions when AI is unavailable
  List<String> _getDefaultSuggestions(HealthInsightsStatistics stats, HealthTrends trends) {
    final suggestions = <String>[];

    if (trends.steps == TrendDirection.declining) {
      suggestions.add('Try taking short walking breaks throughout the day to boost your step count.');
    }

    if (trends.sleep == TrendDirection.declining || stats.avgSleepHours < 7) {
      suggestions.add('Consider setting a consistent bedtime and avoiding screens 1 hour before sleep.');
    }

    if (stats.totalWorkouts == 0) {
      suggestions.add('Start with 2-3 short workouts per week. Even 15-20 minute sessions are beneficial.');
    }

    if (stats.avgMoodRating != null && stats.avgMoodRating! < 3) {
      suggestions.add('Try incorporating mindfulness or relaxation techniques into your daily routine.');
    }

    if (stats.avgEnergyLevel != null && stats.avgEnergyLevel! < 3) {
      suggestions.add('Focus on improving sleep quality and staying hydrated to boost energy levels.');
    }

    // Generic positive suggestions
    if (suggestions.isEmpty) {
      suggestions.add('Keep up the great work! Consider setting a new fitness goal to challenge yourself.');
      suggestions.add('Try varying your workouts to keep things interesting and target different muscle groups.');
    }

    return suggestions.take(4).toList();
  }

  /// Helper to create date key string
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
