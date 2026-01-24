import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/ai/data/services/claude_api_service.dart';
import '../../../../features/ai/presentation/providers/ai_providers.dart';
import '../../domain/models/energy_log.dart';

/// Provider for MoodEnergyInsightsService
final moodEnergyInsightsServiceProvider =
    Provider<MoodEnergyInsightsService>((ref) {
  final claudeService = ref.watch(claudeAPIServiceProvider);
  return MoodEnergyInsightsService(claudeService);
});

class MoodEnergyInsightsService {
  final ClaudeAPIService _claudeService;

  MoodEnergyInsightsService(this._claudeService);

  /// Generate AI insights for user's mood and energy patterns
  Future<MoodEnergyInsights> generateInsights(
    String userId,
    List<EnergyLog> recentLogs,
  ) async {
    if (recentLogs.isEmpty) {
      return MoodEnergyInsights.empty();
    }

    // Calculate statistics
    final stats = _calculateStats(recentLogs);

    // Generate AI analysis
    final prompt = _buildAnalysisPrompt(userId, recentLogs, stats);

    try {
      final response = await _claudeService.sendMessage(
        prompt: prompt,
        systemPrompt:
            'You are a compassionate wellness coach with expertise in emotional intelligence and energy management.',
        userId: userId,
        promptType: 'mood_energy_insights',
        maxTokens: 1000,
      );

      return MoodEnergyInsights(
        summary: _extractSummary(response.content),
        keyInsights: _extractInsights(response.content),
        suggestions: _extractSuggestions(response.content),
        statistics: stats,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      // Return default insights if AI fails
      return MoodEnergyInsights(
        summary:
            'Keep tracking your mood and energy! Patterns will emerge over time.',
        keyInsights: [
          'Your mood/energy tracking journey is underway',
          'Regular check-ins help identify patterns',
          'Self-awareness is the first step to improvement',
        ],
        suggestions: [
          'Try checking in at the same time each day',
          'Notice what activities affect your energy',
          'Pay attention to sleep and mood correlations',
        ],
        statistics: stats,
        generatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> _calculateStats(List<EnergyLog> logs) {
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    // Filter logs for different periods
    final logsLast7Days =
        logs.where((log) => log.loggedAt.isAfter(last7Days)).toList();
    final logsLast30Days =
        logs.where((log) => log.loggedAt.isAfter(last30Days)).toList();

    // Calculate mood averages
    final moodLogs7Days =
        logsLast7Days.where((l) => l.moodRating != null).toList();
    final moodLogs30Days =
        logsLast30Days.where((l) => l.moodRating != null).toList();
    final avgMood7Days = moodLogs7Days.isEmpty
        ? 0.0
        : moodLogs7Days.map((l) => l.moodRating!).reduce((a, b) => a + b) /
            moodLogs7Days.length;
    final avgMood30Days = moodLogs30Days.isEmpty
        ? 0.0
        : moodLogs30Days.map((l) => l.moodRating!).reduce((a, b) => a + b) /
            moodLogs30Days.length;

    // Calculate energy averages
    final energyLogs7Days =
        logsLast7Days.where((l) => l.energyLevel != null).toList();
    final energyLogs30Days =
        logsLast30Days.where((l) => l.energyLevel != null).toList();
    final avgEnergy7Days = energyLogs7Days.isEmpty
        ? 0.0
        : energyLogs7Days.map((l) => l.energyLevel!).reduce((a, b) => a + b) /
            energyLogs7Days.length;
    final avgEnergy30Days = energyLogs30Days.isEmpty
        ? 0.0
        : energyLogs30Days.map((l) => l.energyLevel!).reduce((a, b) => a + b) /
            energyLogs30Days.length;

    // Calculate mood/energy by day of week
    final moodByDayOfWeek = <int, List<int>>{};
    final energyByDayOfWeek = <int, List<int>>{};
    for (var log in logsLast30Days) {
      final dayOfWeek = log.loggedAt.weekday;
      if (log.moodRating != null) {
        moodByDayOfWeek.putIfAbsent(dayOfWeek, () => []).add(log.moodRating!);
      }
      if (log.energyLevel != null) {
        energyByDayOfWeek
            .putIfAbsent(dayOfWeek, () => [])
            .add(log.energyLevel!);
      }
    }

    // Find best and worst days for mood
    final avgMoodByDay = moodByDayOfWeek.map((day, values) =>
        MapEntry(day, values.reduce((a, b) => a + b) / values.length));
    final sortedMoodDays = avgMoodByDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final bestMoodDay = sortedMoodDays.isNotEmpty ? sortedMoodDays.first : null;
    final worstMoodDay = sortedMoodDays.isNotEmpty ? sortedMoodDays.last : null;

    // Find best and worst days for energy
    final avgEnergyByDay = energyByDayOfWeek.map((day, values) =>
        MapEntry(day, values.reduce((a, b) => a + b) / values.length));
    final sortedEnergyDays = avgEnergyByDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final bestEnergyDay =
        sortedEnergyDays.isNotEmpty ? sortedEnergyDays.first : null;
    final worstEnergyDay =
        sortedEnergyDays.isNotEmpty ? sortedEnergyDays.last : null;

    // Count context tags frequency
    final tagFrequency = <String, int>{};
    for (var log in logsLast30Days) {
      for (var tag in log.contextTags) {
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
      }
    }
    final sortedTags = tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).map((e) => e.key).toList();

    // Calculate mood trend (improving, declining, stable)
    String moodTrend = 'stable';
    if (avgMood7Days > 0 && avgMood30Days > 0) {
      final diff = avgMood7Days - avgMood30Days;
      if (diff > 0.3) {
        moodTrend = 'improving';
      } else if (diff < -0.3) {
        moodTrend = 'declining';
      }
    }

    // Calculate energy trend
    String energyTrend = 'stable';
    if (avgEnergy7Days > 0 && avgEnergy30Days > 0) {
      final diff = avgEnergy7Days - avgEnergy30Days;
      if (diff > 0.3) {
        energyTrend = 'improving';
      } else if (diff < -0.3) {
        energyTrend = 'declining';
      }
    }

    // Find mood-energy correlation
    final logsWithBoth = logsLast30Days
        .where((l) => l.moodRating != null && l.energyLevel != null)
        .toList();
    double moodEnergyCorrelation = 0;
    if (logsWithBoth.length >= 3) {
      final moodValues = logsWithBoth.map((l) => l.moodRating!).toList();
      final energyValues = logsWithBoth.map((l) => l.energyLevel!).toList();
      moodEnergyCorrelation = _calculateCorrelation(moodValues, energyValues);
    }

    return {
      'totalLogs': logs.length,
      'logsLast7Days': logsLast7Days.length,
      'logsLast30Days': logsLast30Days.length,
      'avgMood7Days': avgMood7Days,
      'avgMood30Days': avgMood30Days,
      'avgEnergy7Days': avgEnergy7Days,
      'avgEnergy30Days': avgEnergy30Days,
      'moodTrend': moodTrend,
      'energyTrend': energyTrend,
      'bestMoodDay': bestMoodDay,
      'worstMoodDay': worstMoodDay,
      'bestEnergyDay': bestEnergyDay,
      'worstEnergyDay': worstEnergyDay,
      'topTags': topTags,
      'tagFrequency': tagFrequency,
      'moodEnergyCorrelation': moodEnergyCorrelation,
      'avgMoodByDay': avgMoodByDay,
      'avgEnergyByDay': avgEnergyByDay,
    };
  }

  double _calculateCorrelation(List<int> x, List<int> y) {
    if (x.length != y.length || x.length < 2) return 0;

    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);

    final numerator = n * sumXY - sumX * sumY;
    final denominator =
        (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY);

    if (denominator <= 0) return 0;
    return numerator / (denominator > 0 ? denominator.abs() : 1).clamp(0.001, double.infinity);
  }

  String _buildAnalysisPrompt(
    String userId,
    List<EnergyLog> logs,
    Map<String, dynamic> stats,
  ) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    String getDayName(int? day) {
      if (day == null || day < 1 || day > 7) return 'Unknown';
      return dayNames[day - 1];
    }

    final bestMoodDay = stats['bestMoodDay'] as MapEntry<int, double>?;
    final worstMoodDay = stats['worstMoodDay'] as MapEntry<int, double>?;
    final bestEnergyDay = stats['bestEnergyDay'] as MapEntry<int, double>?;
    final worstEnergyDay = stats['worstEnergyDay'] as MapEntry<int, double>?;
    final topTags = stats['topTags'] as List<String>;

    // Get recent logs summary
    final recentLogs = logs.take(10).map((log) {
      final mood = log.moodRating != null ? log.moodDescription : 'N/A';
      final energy = log.energyLevel != null ? log.energyDescription : 'N/A';
      final tags = log.contextTags.isNotEmpty ? log.contextTags.join(', ') : 'None';
      return '- Mood: $mood, Energy: $energy, Tags: $tags';
    }).join('\n');

    return '''
You are a compassionate wellness coach with expertise in emotional intelligence, energy management, and behavioral patterns. Analyze this user's mood and energy tracking data and provide personalized insights.

## Recent Check-ins (Last 10):
$recentLogs

## Statistics (Last 30 Days):
- Total Check-ins: ${stats['logsLast30Days']}
- Average Mood (7 days): ${(stats['avgMood7Days'] as double).toStringAsFixed(1)}/5
- Average Mood (30 days): ${(stats['avgMood30Days'] as double).toStringAsFixed(1)}/5
- Average Energy (7 days): ${(stats['avgEnergy7Days'] as double).toStringAsFixed(1)}/5
- Average Energy (30 days): ${(stats['avgEnergy30Days'] as double).toStringAsFixed(1)}/5
- Mood Trend: ${stats['moodTrend']}
- Energy Trend: ${stats['energyTrend']}
- Best Mood Day: ${bestMoodDay != null ? '${getDayName(bestMoodDay.key)} (${bestMoodDay.value.toStringAsFixed(1)})' : 'N/A'}
- Lowest Mood Day: ${worstMoodDay != null ? '${getDayName(worstMoodDay.key)} (${worstMoodDay.value.toStringAsFixed(1)})' : 'N/A'}
- Best Energy Day: ${bestEnergyDay != null ? '${getDayName(bestEnergyDay.key)} (${bestEnergyDay.value.toStringAsFixed(1)})' : 'N/A'}
- Lowest Energy Day: ${worstEnergyDay != null ? '${getDayName(worstEnergyDay.key)} (${worstEnergyDay.value.toStringAsFixed(1)})' : 'N/A'}
- Most Common Tags: ${topTags.isEmpty ? 'None yet' : topTags.join(', ')}
- Mood-Energy Correlation: ${(stats['moodEnergyCorrelation'] as double).toStringAsFixed(2)}

## Instructions:
Provide a brief analysis in this EXACT format:

SUMMARY:
[One encouraging sentence about their overall mood/energy patterns]

INSIGHTS:
1. [Key pattern about their mood - be specific with data]
2. [Key pattern about their energy levels - reference their best/worst days]
3. [Observation about mood-energy relationship or timing patterns]

SUGGESTIONS:
1. [One actionable suggestion for their lowest mood/energy day]
2. [One suggestion for maintaining their best patterns]
3. [One evidence-based tip for overall wellbeing]

IMPORTANT:
- Keep each point concise (max 15 words)
- Be encouraging and compassionate
- Use their actual data (numbers, days, tags)
- Reference the context tags when relevant
- Avoid medical advice - focus on lifestyle patterns
- Focus on what's working, not just problems
''';
  }

  String _extractSummary(String aiResponse) {
    final summaryMatch =
        RegExp(r'SUMMARY:\s*\n(.+?)(?=\n\n|INSIGHTS:)', dotAll: true)
            .firstMatch(aiResponse);
    return summaryMatch?.group(1)?.trim() ??
        'Keep tracking your mood and energy to uncover helpful patterns!';
  }

  List<String> _extractInsights(String aiResponse) {
    final insightsSection = RegExp(
      r'INSIGHTS:\s*\n((?:\d+\..+?\n?)+)',
      dotAll: true,
    ).firstMatch(aiResponse);

    if (insightsSection == null) {
      return [
        'Regular tracking reveals patterns over time',
        'Mood and energy often correlate with daily activities',
        'Awareness is the first step to positive change',
      ];
    }

    final insights =
        RegExp(r'\d+\.\s*(.+?)(?=\n\d+\.|\n\n|SUGGESTIONS:|$)', dotAll: true)
            .allMatches(insightsSection.group(1) ?? '')
            .map((m) => m.group(1)?.trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

    return insights.isEmpty
        ? ['Patterns emerge with consistent tracking', 'You\'re building self-awareness']
        : insights;
  }

  List<String> _extractSuggestions(String aiResponse) {
    final suggestionsSection = RegExp(
      r'SUGGESTIONS:\s*\n((?:\d+\..+?\n?)+)',
      dotAll: true,
    ).firstMatch(aiResponse);

    if (suggestionsSection == null) {
      return [
        'Check in at the same time each day',
        'Notice what activities boost your energy',
        'Prioritize sleep for better mood',
      ];
    }

    final suggestions =
        RegExp(r'\d+\.\s*(.+?)(?=\n\d+\.|\n\n|$)', dotAll: true)
            .allMatches(suggestionsSection.group(1) ?? '')
            .map((m) => m.group(1)?.trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

    return suggestions.isEmpty
        ? ['Stay consistent with check-ins', 'Celebrate small improvements']
        : suggestions;
  }
}

/// Model for mood & energy insights
class MoodEnergyInsights {
  final String summary;
  final List<String> keyInsights;
  final List<String> suggestions;
  final Map<String, dynamic> statistics;
  final DateTime generatedAt;

  MoodEnergyInsights({
    required this.summary,
    required this.keyInsights,
    required this.suggestions,
    required this.statistics,
    required this.generatedAt,
  });

  factory MoodEnergyInsights.empty() {
    return MoodEnergyInsights(
      summary: 'Start tracking your mood and energy to get personalized insights!',
      keyInsights: [
        'Log your first check-in to begin',
        'Track daily to see patterns emerge',
        'AI will analyze your mood and energy',
      ],
      suggestions: [
        'Tap the check-in card on the dashboard',
        'Rate your mood and energy honestly',
        'Add context tags for richer insights',
      ],
      statistics: {},
      generatedAt: DateTime.now(),
    );
  }

  bool get isEmpty => statistics.isEmpty;

  // Helper getters for common statistics
  double get avgMood7Days =>
      (statistics['avgMood7Days'] as double?) ?? 0.0;
  double get avgMood30Days =>
      (statistics['avgMood30Days'] as double?) ?? 0.0;
  double get avgEnergy7Days =>
      (statistics['avgEnergy7Days'] as double?) ?? 0.0;
  double get avgEnergy30Days =>
      (statistics['avgEnergy30Days'] as double?) ?? 0.0;
  String get moodTrend =>
      (statistics['moodTrend'] as String?) ?? 'stable';
  String get energyTrend =>
      (statistics['energyTrend'] as String?) ?? 'stable';
  List<String> get topTags =>
      (statistics['topTags'] as List<String>?) ?? [];
}
