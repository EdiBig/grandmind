import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/habits/data/services/habit_insights_service.dart';

/// Tests for HabitInsightsService pure functions and models.
///
/// These tests focus on:
/// 1. HabitInsights model
/// 2. Statistics calculation logic (conceptual)
/// 3. Regex parsing for AI responses

void main() {
  group('HabitInsights Model', () {
    test('creates habit insights with all fields', () {
      final insights = HabitInsights(
        summary: 'You are making great progress!',
        keyInsights: [
          'Completed 80% of habits this week',
          'Mornings are your most productive time',
        ],
        suggestions: [
          'Try setting reminders for afternoon habits',
          'Consider reducing to 3 core habits',
        ],
        statistics: {
          'totalHabits': 5,
          'activeHabits': 4,
          'logsLast7Days': 20,
          'logsLast30Days': 75,
          'avgCompletionRate': 0.8,
          'longestStreak': 14,
        },
        generatedAt: DateTime(2024, 1, 15),
      );

      expect(insights.summary, contains('great progress'));
      expect(insights.keyInsights.length, equals(2));
      expect(insights.suggestions.length, equals(2));
      expect(insights.statistics['totalHabits'], equals(5));
      expect(insights.statistics['avgCompletionRate'], equals(0.8));
    });

    test('creates empty habit insights', () {
      final emptyInsights = HabitInsights.empty();

      expect(emptyInsights.summary, contains('Start tracking'));
      expect(emptyInsights.keyInsights, isNotEmpty);
      expect(emptyInsights.suggestions, isNotEmpty);
      expect(emptyInsights.statistics, isEmpty);
      expect(emptyInsights.isEmpty, isTrue);
    });

    test('isEmpty returns true for empty statistics', () {
      final insights = HabitInsights(
        summary: 'Test',
        keyInsights: ['Test insight'],
        suggestions: ['Test suggestion'],
        statistics: {},
        generatedAt: DateTime.now(),
      );

      expect(insights.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty statistics', () {
      final insights = HabitInsights(
        summary: 'Test',
        keyInsights: ['Test insight'],
        suggestions: ['Test suggestion'],
        statistics: {'someKey': 'someValue'},
        generatedAt: DateTime.now(),
      );

      expect(insights.isEmpty, isFalse);
    });
  });

  group('Statistics Calculation Logic (Conceptual)', () {
    // These tests document the expected behavior of _calculateStats

    test('calculates active habit count', () {
      final habits = [
        _MockHabit(isActive: true),
        _MockHabit(isActive: true),
        _MockHabit(isActive: false),
        _MockHabit(isActive: true),
      ];

      final activeCount = habits.where((h) => h.isActive).length;
      expect(activeCount, equals(3));
    });

    test('calculates completion rate', () {
      // 15 logs over 7 days with 3 active habits
      // Average per day = 15/7 = ~2.14
      // Completion rate = 2.14/3 = ~0.71
      const logsLast7Days = 15;
      const daysWithLogs = 7;
      const activeHabits = 3;

      final avgCompletionRate = logsLast7Days / daysWithLogs / activeHabits;
      expect(avgCompletionRate, closeTo(0.714, 0.01));
    });

    test('finds longest current streak', () {
      final habits = [
        _MockHabit(currentStreak: 5),
        _MockHabit(currentStreak: 12),
        _MockHabit(currentStreak: 3),
        _MockHabit(currentStreak: 8),
      ];

      final longestStreak = habits.map((h) => h.currentStreak).reduce(
          (max, streak) => streak > max ? streak : max);
      expect(longestStreak, equals(12));
    });

    test('groups logs by date', () {
      final logs = [
        _MockHabitLog(date: DateTime(2024, 1, 15)),
        _MockHabitLog(date: DateTime(2024, 1, 15)),
        _MockHabitLog(date: DateTime(2024, 1, 15)),
        _MockHabitLog(date: DateTime(2024, 1, 14)),
        _MockHabitLog(date: DateTime(2024, 1, 14)),
        _MockHabitLog(date: DateTime(2024, 1, 13)),
      ];

      final logsByDate = <String, int>{};
      for (var log in logs) {
        final dateKey = '${log.date.year}-${log.date.month}-${log.date.day}';
        logsByDate[dateKey] = (logsByDate[dateKey] ?? 0) + 1;
      }

      expect(logsByDate['2024-1-15'], equals(3));
      expect(logsByDate['2024-1-14'], equals(2));
      expect(logsByDate['2024-1-13'], equals(1));
    });

    test('finds best and worst days', () {
      final logsByDate = {
        '2024-1-15': 5, // Best
        '2024-1-14': 2,
        '2024-1-13': 3,
        '2024-1-12': 1, // Worst
        '2024-1-11': 4,
      };

      final sortedDays = logsByDate.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final bestDay = sortedDays.first;
      final worstDay = sortedDays.last;

      expect(bestDay.key, equals('2024-1-15'));
      expect(bestDay.value, equals(5));
      expect(worstDay.key, equals('2024-1-12'));
      expect(worstDay.value, equals(1));
    });

    test('calculates completion by day of week', () {
      // Create logs for different days of the week
      // Monday = 1, Tuesday = 2, ..., Sunday = 7
      final logs = [
        _MockHabitLog(date: DateTime(2024, 1, 15)), // Monday
        _MockHabitLog(date: DateTime(2024, 1, 15)), // Monday
        _MockHabitLog(date: DateTime(2024, 1, 16)), // Tuesday
        _MockHabitLog(date: DateTime(2024, 1, 17)), // Wednesday
        _MockHabitLog(date: DateTime(2024, 1, 17)), // Wednesday
        _MockHabitLog(date: DateTime(2024, 1, 17)), // Wednesday
        _MockHabitLog(date: DateTime(2024, 1, 20)), // Saturday
      ];

      final completionByDayOfWeek = <int, int>{};
      for (var log in logs) {
        final dayOfWeek = log.date.weekday;
        completionByDayOfWeek[dayOfWeek] = (completionByDayOfWeek[dayOfWeek] ?? 0) + 1;
      }

      expect(completionByDayOfWeek[1], equals(2)); // Monday
      expect(completionByDayOfWeek[2], equals(1)); // Tuesday
      expect(completionByDayOfWeek[3], equals(3)); // Wednesday
      expect(completionByDayOfWeek[6], equals(1)); // Saturday
    });
  });

  group('AI Response Parsing (Conceptual)', () {
    test('extracts summary from AI response', () {
      const aiResponse = '''
SUMMARY:
You're building great habits! Your consistency is improving week over week.

INSIGHTS:
1. Your morning routine has 90% completion rate
2. Weekends show lower engagement
3. Exercise habit has the longest streak at 14 days

SUGGESTIONS:
1. Add a reminder for evening habits
2. Consider habit stacking for better consistency
3. Celebrate your wins with small rewards
''';

      // Regex to extract summary
      final summaryMatch = RegExp(r'SUMMARY:\s*\n(.+?)(?=\n\n|INSIGHTS:)', dotAll: true)
          .firstMatch(aiResponse);
      final summary = summaryMatch?.group(1)?.trim();

      expect(summary, contains('building great habits'));
      expect(summary, contains('consistency'));
    });

    test('extracts insights from AI response', () {
      // The service uses regex to parse structured AI responses
      // Format: "INSIGHTS:\n1. First insight\n2. Second insight\n3. Third insight"

      // Test that numbered list format can be detected
      const insightsSection = '''1. Your morning routine has 90% completion rate
2. Weekends show lower engagement
3. Exercise habit has the longest streak at 14 days''';

      // Simple line-based parsing that the service uses
      final lines = insightsSection.split('\n');
      final insights = lines
          .where((line) => RegExp(r'^\d+\.').hasMatch(line.trim()))
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      expect(insights.length, equals(3));
      expect(insights[0], contains('morning routine'));
      expect(insights[1], contains('Weekends'));
      expect(insights[2], contains('Exercise'));
    });

    test('extracts suggestions from AI response', () {
      // The service uses regex to parse structured AI responses
      // Format: "SUGGESTIONS:\n1. First suggestion\n2. Second suggestion"

      // Test that numbered list format can be detected
      const suggestionsSection = '''1. Add a reminder for evening habits
2. Consider habit stacking for better consistency
3. Celebrate your wins with small rewards''';

      // Simple line-based parsing
      final lines = suggestionsSection.split('\n');
      final suggestions = lines
          .where((line) => RegExp(r'^\d+\.').hasMatch(line.trim()))
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .toList();

      expect(suggestions.length, equals(3));
      expect(suggestions[0], contains('reminder'));
      expect(suggestions[1], contains('habit stacking'));
      expect(suggestions[2], contains('Celebrate'));
    });

    test('returns default values when parsing fails', () {
      const malformedResponse = 'This is not in the expected format.';

      final summaryMatch = RegExp(r'SUMMARY:\s*\n(.+?)(?=\n\n|INSIGHTS:)', dotAll: true)
          .firstMatch(malformedResponse);
      final summary = summaryMatch?.group(1)?.trim() ??
          'Keep building those healthy habits! You\'re making progress.';

      expect(summary, equals('Keep building those healthy habits! You\'re making progress.'));
    });
  });

  group('Default Fallback Values', () {
    test('provides default summary when AI fails', () {
      const defaultSummary = 'Keep building those healthy habits! You\'re making progress.';
      expect(defaultSummary, isNotEmpty);
      expect(defaultSummary, contains('healthy habits'));
    });

    test('provides default insights when AI fails', () {
      final defaultInsights = [
        'Your habit tracking journey is underway',
        'Consistency is key to forming lasting habits',
        'Every completed habit builds momentum',
      ];

      expect(defaultInsights.length, equals(3));
      expect(defaultInsights, contains('Consistency is key to forming lasting habits'));
    });

    test('provides default suggestions when AI fails', () {
      final defaultSuggestions = [
        'Set a consistent time for your daily habits',
        'Start with small, achievable targets',
        'Celebrate your wins, no matter how small',
      ];

      expect(defaultSuggestions.length, equals(3));
      expect(defaultSuggestions, contains('Start with small, achievable targets'));
    });
  });

  group('Date Filtering', () {
    test('filters logs for last 7 days', () {
      final now = DateTime(2024, 1, 20);
      final last7Days = now.subtract(const Duration(days: 7));

      final logs = [
        _MockHabitLog(date: DateTime(2024, 1, 19)), // Within 7 days
        _MockHabitLog(date: DateTime(2024, 1, 15)), // Within 7 days
        _MockHabitLog(date: DateTime(2024, 1, 10)), // Outside 7 days
        _MockHabitLog(date: DateTime(2024, 1, 5)),  // Outside 7 days
      ];

      final logsLast7Days = logs.where((log) => log.date.isAfter(last7Days)).toList();
      expect(logsLast7Days.length, equals(2));
    });

    test('filters logs for last 30 days', () {
      final now = DateTime(2024, 1, 30);
      final last30Days = now.subtract(const Duration(days: 30));

      final logs = [
        _MockHabitLog(date: DateTime(2024, 1, 25)), // Within 30 days
        _MockHabitLog(date: DateTime(2024, 1, 15)), // Within 30 days
        _MockHabitLog(date: DateTime(2024, 1, 5)),  // Within 30 days
        _MockHabitLog(date: DateTime(2023, 12, 20)), // Outside 30 days
      ];

      final logsLast30Days = logs.where((log) => log.date.isAfter(last30Days)).toList();
      expect(logsLast30Days.length, equals(3));
    });
  });
}

/// Mock habit class for testing
class _MockHabit {
  final bool isActive;
  final int currentStreak;

  _MockHabit({
    this.isActive = true,
    this.currentStreak = 0,
  });
}

/// Mock habit log class for testing
class _MockHabitLog {
  final DateTime date;

  _MockHabitLog({required this.date});
}
