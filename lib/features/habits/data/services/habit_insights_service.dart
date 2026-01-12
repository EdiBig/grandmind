import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/ai/data/services/claude_api_service.dart';
import '../../../../features/ai/presentation/providers/ai_providers.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';

/// Provider for HabitInsightsService
final habitInsightsServiceProvider = Provider<HabitInsightsService>((ref) {
  final claudeService = ref.watch(claudeAPIServiceProvider);
  return HabitInsightsService(claudeService);
});

class HabitInsightsService {
  final ClaudeAPIService _claudeService;

  HabitInsightsService(this._claudeService);

  /// Generate AI insights for user's habits
  Future<HabitInsights> generateInsights(
    String userId,
    List<Habit> habits,
    List<HabitLog> recentLogs,
  ) async {
    if (habits.isEmpty) {
      return HabitInsights.empty();
    }

    // Calculate statistics
    final stats = _calculateStats(habits, recentLogs);

    // Generate AI analysis
    final prompt = _buildAnalysisPrompt(userId, habits, recentLogs, stats);

    try {
      final response = await _claudeService.sendMessage(
        prompt: prompt,
        systemPrompt: 'You are a compassionate habit coach with expertise in behavioral psychology.',
        userId: userId,
        promptType: 'habit_insights',
        maxTokens: 1000,
      );

      return HabitInsights(
        summary: _extractSummary(response.content),
        keyInsights: _extractInsights(response.content),
        suggestions: _extractSuggestions(response.content),
        statistics: stats,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      // Return default insights if AI fails
      return HabitInsights(
        summary: 'Keep building those healthy habits! You\'re making progress.',
        keyInsights: [
          'Your habit tracking journey is underway',
          'Consistency is key to forming lasting habits',
          'Every completed habit builds momentum',
        ],
        suggestions: [
          'Set a consistent time for your daily habits',
          'Start with small, achievable targets',
          'Celebrate your wins, no matter how small',
        ],
        statistics: stats,
        generatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> _calculateStats(List<Habit> habits, List<HabitLog> logs) {
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    // Filter logs for different periods
    final logsLast7Days = logs.where((log) => log.date.isAfter(last7Days)).toList();
    final logsLast30Days = logs.where((log) => log.date.isAfter(last30Days)).toList();

    // Calculate completion rates
    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => h.isActive).length;

    // Group logs by date
    final logsByDate = <String, int>{};
    for (var log in logsLast7Days) {
      final dateKey = '${log.date.year}-${log.date.month}-${log.date.day}';
      logsByDate[dateKey] = (logsByDate[dateKey] ?? 0) + 1;
    }

    // Find best and worst days
    final sortedDays = logsByDate.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final bestDay = sortedDays.isNotEmpty ? sortedDays.first : null;
    final worstDay = sortedDays.isNotEmpty ? sortedDays.last : null;

    // Calculate average completion rate
    final avgCompletionRate = logsByDate.isEmpty
        ? 0.0
        : logsByDate.values.reduce((a, b) => a + b) / logsByDate.length / activeHabits;

    // Find longest current streak
    int longestStreak = 0;
    for (var habit in habits) {
      if (habit.currentStreak > longestStreak) {
        longestStreak = habit.currentStreak;
      }
    }

    // Calculate completion by day of week
    final completionByDayOfWeek = <int, int>{};
    for (var log in logsLast30Days) {
      final dayOfWeek = log.date.weekday; // 1 = Monday, 7 = Sunday
      completionByDayOfWeek[dayOfWeek] = (completionByDayOfWeek[dayOfWeek] ?? 0) + 1;
    }

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'logsLast7Days': logsLast7Days.length,
      'logsLast30Days': logsLast30Days.length,
      'avgCompletionRate': avgCompletionRate,
      'longestStreak': longestStreak,
      'bestDay': bestDay,
      'worstDay': worstDay,
      'completionByDayOfWeek': completionByDayOfWeek,
    };
  }

  String _buildAnalysisPrompt(
    String userId,
    List<Habit> habits,
    List<HabitLog> logs,
    Map<String, dynamic> stats,
  ) {
    final habitsInfo = habits.map((h) => '''
    - ${h.name}
      * Frequency: ${h.frequency.displayName}
      * Current Streak: ${h.currentStreak} days
      * Longest Streak: ${h.longestStreak} days
      * Target: ${h.targetCount > 0 ? '${h.targetCount} ${h.unit}' : 'Yes/No'}
    ''').join('\n');

    final completionByDay = stats['completionByDayOfWeek'] as Map<int, int>;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayStats = completionByDay.entries
        .map((e) => '${dayNames[e.key - 1]}: ${e.value}')
        .join(', ');

    return '''
You are a compassionate habit coach with expertise in behavioral psychology and evidence-based habit formation. Analyze this user's habit tracking data and provide actionable insights.

## User's Habits:
$habitsInfo

## Statistics:
- Active Habits: ${stats['activeHabits']}
- Logs Last 7 Days: ${stats['logsLast7Days']}
- Logs Last 30 Days: ${stats['logsLast30Days']}
- Average Completion Rate: ${(stats['avgCompletionRate'] * 100).toStringAsFixed(1)}%
- Longest Current Streak: ${stats['longestStreak']} days
- Completion by Day: $dayStats

## Instructions:
Provide a brief analysis in this EXACT format:

SUMMARY:
[One encouraging sentence about their overall progress]

INSIGHTS:
1. [Key pattern or achievement - be specific with numbers]
2. [Another important pattern - reference their data]
3. [Third insight about timing, streaks, or behavior]

SUGGESTIONS:
1. [One actionable suggestion based on their weakest area]
2. [One suggestion for maintaining their best habits]
3. [One evidence-based tip for improvement]

IMPORTANT:
- Keep each point concise (max 15 words)
- Be encouraging and compassionate
- Use their actual data (numbers, days, habits)
- Reference behavioral science when relevant
- Avoid medical advice
- Focus on what's working, not just problems
''';
  }

  String _extractSummary(String aiResponse) {
    final summaryMatch = RegExp(r'SUMMARY:\s*\n(.+?)(?=\n\n|INSIGHTS:)', dotAll: true)
        .firstMatch(aiResponse);
    return summaryMatch?.group(1)?.trim() ??
        'Keep building those healthy habits! You\'re making progress.';
  }

  List<String> _extractInsights(String aiResponse) {
    final insightsSection = RegExp(
      r'INSIGHTS:\s*\n((?:\d+\..+?\n?)+)',
      dotAll: true,
    ).firstMatch(aiResponse);

    if (insightsSection == null) {
      return [
        'Your habit tracking journey has just begun',
        'Every completed habit builds momentum',
        'Consistency beats perfection',
      ];
    }

    final insights = RegExp(r'\d+\.\s*(.+?)(?=\n\d+\.|\n\n|SUGGESTIONS:|$)', dotAll: true)
        .allMatches(insightsSection.group(1) ?? '')
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return insights.isEmpty
        ? ['Building healthy habits takes time', 'You\'re on the right track']
        : insights;
  }

  List<String> _extractSuggestions(String aiResponse) {
    final suggestionsSection = RegExp(
      r'SUGGESTIONS:\s*\n((?:\d+\..+?\n?)+)',
      dotAll: true,
    ).firstMatch(aiResponse);

    if (suggestionsSection == null) {
      return [
        'Set a consistent time for your habits',
        'Start with small, achievable targets',
        'Track your progress daily',
      ];
    }

    final suggestions = RegExp(r'\d+\.\s*(.+?)(?=\n\d+\.|\n\n|$)', dotAll: true)
        .allMatches(suggestionsSection.group(1) ?? '')
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return suggestions.isEmpty
        ? ['Keep your habit streak alive', 'Celebrate small wins']
        : suggestions;
  }
}

/// Model for habit insights
class HabitInsights {
  final String summary;
  final List<String> keyInsights;
  final List<String> suggestions;
  final Map<String, dynamic> statistics;
  final DateTime generatedAt;

  HabitInsights({
    required this.summary,
    required this.keyInsights,
    required this.suggestions,
    required this.statistics,
    required this.generatedAt,
  });

  factory HabitInsights.empty() {
    return HabitInsights(
      summary: 'Start tracking habits to get personalized insights!',
      keyInsights: [
        'Create your first habit to begin',
        'Track daily to see patterns emerge',
        'AI will analyze your progress',
      ],
      suggestions: [
        'Click the + button to create a habit',
        'Start with 1-2 easy habits',
        'Build momentum before adding more',
      ],
      statistics: {},
      generatedAt: DateTime.now(),
    );
  }

  bool get isEmpty => statistics.isEmpty;
}
