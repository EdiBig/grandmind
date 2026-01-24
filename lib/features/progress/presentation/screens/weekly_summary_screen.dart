import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../features/home/presentation/providers/dashboard_provider.dart';
import '../../../../features/habits/domain/models/habit.dart';
import '../../../../features/habits/domain/models/habit_log.dart';
import '../../../../features/habits/presentation/providers/habit_providers.dart';
import '../../../../features/progress/presentation/providers/weekly_summary_provider.dart';
import '../../../../features/user/data/services/firestore_service.dart';
import '../../../../features/user/data/models/user_model.dart';
import '../../../../features/mood_energy/domain/models/energy_log.dart';
import '../../../../features/workouts/domain/models/workout.dart';
import '../../../../features/workouts/domain/models/workout_log.dart';
import '../../../../features/workouts/presentation/providers/workout_providers.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(weeklySummaryRangeProvider);
    final workoutLogsAsync = ref.watch(userWorkoutLogsProvider);
    final habitLogsAsync = ref.watch(weeklyHabitLogsProvider);
    final habitsAsync = ref.watch(userHabitsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final energyLogsAsync = ref.watch(weeklyEnergyLogsProvider);
    final previousEnergyLogsAsync = ref.watch(previousWeeklyEnergyLogsProvider);

    final dateFormat = DateFormat('MMM d');
    final rangeLabel =
        '${dateFormat.format(range.start)} - ${dateFormat.format(range.end)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Week in Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            rangeLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,        
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _NoDataCard(
            range: range,
            workoutLogsAsync: workoutLogsAsync,
            habitLogsAsync: habitLogsAsync,
            onLogActivity: () => context.go(RouteConstants.logActivity),
          ),
          workoutLogsAsync.when(
            loading: () => const _SectionLoadingCard(),
            error: (_, __) => _SectionErrorCard(
              message: 'Unable to load workout summary.',
            ),
            data: (logs) {
              final summary = _buildWorkoutSummary(logs, range);
              final weeklyGoal = _weeklyGoalFromUser(userAsync.asData?.value);
              return _WorkoutSummaryCard(
                summary: summary,
                weeklyGoal: weeklyGoal,
              );
            },
          ),
          const SizedBox(height: 16),
          habitsAsync.when(
            loading: () => const _SectionLoadingCard(),
            error: (_, __) => _SectionErrorCard(
              message: 'Unable to load habit summary.',
            ),
            data: (habits) {
              return habitLogsAsync.when(
                loading: () => const _SectionLoadingCard(),
                error: (_, __) => _SectionErrorCard(
                  message: 'Unable to load habit summary.',
                ),
                data: (logs) => _HabitSummaryCard(
                  habits: habits,
                  logs: logs,
                  range: range,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          energyLogsAsync.when(
            loading: () => const _SectionLoadingCard(),
            error: (_, __) => _SectionErrorCard(
              message: 'Unable to load energy summary.',
            ),
            data: (logs) {
              final previous = previousEnergyLogsAsync.asData?.value ?? [];
              final summary = _buildEnergySummary(logs, previous);
              return _EnergyMoodCard(summary: summary);
            },
          ),
          const SizedBox(height: 16),
          workoutLogsAsync.when(
            loading: () => const _SectionLoadingCard(),
            error: (_, __) => _SectionErrorCard(
              message: 'Unable to load insights.',
            ),
            data: (logs) => _InsightsCard(
              insights: _buildInsights(logs, range),
            ),
          ),
          const SizedBox(height: 16),
          _NextWeekCard(
            weeklyGoal: _weeklyGoalFromUser(userAsync.asData?.value),
            coachTone: _coachToneFromUser(userAsync.asData?.value),
            onGoalUpdated: (value) => _updateWeeklyGoal(
              context,
              ref,
              userAsync.asData?.value?.id,
              value,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(RouteConstants.progress),
              child: const Text('View Detailed Stats'),
            ),
          ),
        ],
      ),
    );
  }

  static int _weeklyGoalFromUser(UserModel? user) {
    final onboarding = user?.onboarding;
    final value = onboarding?['weeklyWorkouts'];
    if (value is num) {
      final goal = value.toInt();
      if (goal < 1) return 1;
      if (goal > 7) return 7;
      return goal;
    }
    return 3;
  }

  static String? _coachToneFromUser(UserModel? user) {
    final onboarding = user?.onboarding;
    final value = onboarding?['coachTone'];
    return value is String ? value.toLowerCase() : null;
  }

  static Future<void> _updateWeeklyGoal(
    BuildContext context,
    WidgetRef ref,
    String? userId,
    int? goal,
  ) async {
    if (userId == null || goal == null) return;

    final service = ref.read(firestoreServiceProvider);
    await service.updateUser(userId, {
      'onboarding.weeklyWorkouts': goal,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly goal updated.')),
      );
    }
  }

  static _WorkoutSummary _buildWorkoutSummary(
    List<WorkoutLog> logs,
    WeeklySummaryRange range,
  ) {
    final inRange = logs.where((log) {
      final date = log.completedAt ?? log.startedAt;
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();

    final totalDuration = inRange.fold<int>(0, (sum, log) => sum + log.duration);
    final breakdown = <WorkoutCategory, int>{};
    for (final log in inRange) {
      final category = log.category ?? WorkoutCategory.other;
      breakdown[category] = (breakdown[category] ?? 0) + 1;
    }

    return _WorkoutSummary(
      count: inRange.length,
      totalDuration: totalDuration,
      breakdown: breakdown,
      logs: inRange,
    );
  }

  static List<String> _buildInsights(
    List<WorkoutLog> logs,
    WeeklySummaryRange range,
  ) {
    final inRange = logs.where((log) {
      final date = log.completedAt ?? log.startedAt;
      return !date.isBefore(range.start) && !date.isAfter(range.end);
    }).toList();

    if (inRange.isEmpty) {
      return ['No workouts logged this week. Start with a short session.'];
    }

    final countsByWeekday = List<int>.filled(8, 0);
    for (final log in inRange) {
      final date = log.completedAt ?? log.startedAt;
      countsByWeekday[date.weekday] += 1;
    }

    final insights = <String>[];
    if (countsByWeekday[1] == 0 && inRange.length >= 2) {
      insights.add('Pattern spotted: Mondays are quieter. Try a short session.');
    }

    final maxCount = countsByWeekday.skip(1).reduce((a, b) => a > b ? a : b);
    if (maxCount >= 2) {
      final maxDay = countsByWeekday
          .asMap()
          .entries
          .firstWhere((entry) => entry.value == maxCount)
          .key;
      final dayLabel = _weekdayLabel(maxDay);
      insights.add('Your workouts peak on $dayLabel. Plan tougher sessions then.');
    }

    if (insights.isEmpty) {
      insights.add('Nice rhythm this week. Keep building consistency.');
    }

    return insights;
  }

  static _EnergySummary _buildEnergySummary(
    List<EnergyLog> logs,
    List<EnergyLog> previousLogs,
  ) {
    double? currentAverage = _averageEnergy(logs);
    double? previousAverage =
        previousLogs.isEmpty ? null : _averageEnergy(previousLogs);

    final tagCounts = <String, int>{};
    for (final log in logs) {
      for (final tag in log.contextTags) {
        if (tag.trim().isEmpty) continue;
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    return _EnergySummary(
      average: currentAverage,
      previousAverage: previousAverage,
      tagCounts: tagCounts,
    );
  }

  static double? _averageEnergy(List<EnergyLog> logs) {
    if (logs.isEmpty) return null;
    final values = <double>[];
    for (final log in logs) {
      final avg = log.averageEnergy;
      if (avg != null) {
        values.add(avg);
      }
    }
    if (values.isEmpty) return null;
    final total = values.reduce((a, b) => a + b);
    return total / values.length;
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'this day';
    }
  }
}

class _WorkoutSummary {
  final int count;
  final int totalDuration;
  final Map<WorkoutCategory, int> breakdown;
  final List<WorkoutLog> logs;

  const _WorkoutSummary({
    required this.count,
    required this.totalDuration,
    required this.breakdown,
    required this.logs,
  });
}

class _EnergySummary {
  final double? average;
  final double? previousAverage;
  final Map<String, int> tagCounts;

  const _EnergySummary({
    required this.average,
    required this.previousAverage,
    required this.tagCounts,
  });
}

class _NoDataCard extends StatelessWidget {
  final WeeklySummaryRange range;
  final AsyncValue<List<WorkoutLog>> workoutLogsAsync;
  final AsyncValue<List<HabitLog>> habitLogsAsync;
  final VoidCallback onLogActivity;

  const _NoDataCard({
    required this.range,
    required this.workoutLogsAsync,
    required this.habitLogsAsync,
    required this.onLogActivity,
  });

  @override
  Widget build(BuildContext context) {
    return workoutLogsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (workoutLogs) {
        final workoutSummary =
            WeeklySummaryScreen._buildWorkoutSummary(workoutLogs, range);
        return habitLogsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (habitLogs) {
            if (workoutSummary.count > 0 || habitLogs.isNotEmpty) {
              return const SizedBox.shrink();
            }

            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Life happens. This week is a fresh start.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No workouts this week. That\'s okay - rest matters too.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onLogActivity,
                    icon: Icon(Icons.add_task),
                    label: const Text('Log Today\'s Activity'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  final _WorkoutSummary summary;
  final int weeklyGoal;

  const _WorkoutSummaryCard({
    required this.summary,
    required this.weeklyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final goal = weeklyGoal <= 0 ? 1 : weeklyGoal;
    final progress = (summary.count / goal).clamp(0.0, 1.0);
    final goalReached = summary.count >= goal;
    final breakdownChips = summary.breakdown.entries
        .map((entry) => _StatChip(
              label: '${entry.key.displayName} (${entry.value})',
            ))
        .toList();

    return _SummaryCard(
      title: 'Workouts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.count} workouts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Goal: $goal/week • ${goalReached ? 'Achieved' : 'In progress'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: goalReached
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 12),
          if (breakdownChips.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: breakdownChips,
            ),
          if (breakdownChips.isEmpty)
            Text(
              'Add workouts to see a breakdown by type.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          const SizedBox(height: 12),
          Text(
            'Total duration: ${_formatDuration(summary.totalDuration)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '0m';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) {
      return '${remaining}m';
    }
    return '${hours}h ${remaining.toString().padLeft(2, '0')}m';
  }
}

class _HabitSummaryCard extends StatelessWidget {
  final List<Habit> habits;
  final List<HabitLog> logs;
  final WeeklySummaryRange range;

  const _HabitSummaryCard({
    required this.habits,
    required this.logs,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final rangeDays = List.generate(
      7,
      (index) => range.start.add(Duration(days: index)),
    );
    final completedKeys = logs
        .map((log) => '${log.habitId}|${_dateKey(log.date)}')
        .toSet();
    final completedDays = logs.map((log) => _dateKey(log.date)).toSet();

    final expectedCount = habits.fold<int>(
      0,
      (sum, habit) => sum + _expectedDaysForHabit(habit),
    );
    final completedCount = completedKeys.length;
    final completionRate =
        expectedCount > 0 ? completedCount / expectedCount : 0.0;

    final topHabit = _findTopHabit(habits, logs);

    return _SummaryCard(
      title: 'Habits',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completedCount of $expectedCount (${(completionRate * 100).round()}%)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionRate.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 12),
          _WeekGrid(
            days: rangeDays,
            completedDays: completedDays,
          ),
          const SizedBox(height: 12),
          Text(
            topHabit ?? 'Log habits to see your top streak.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String? _findTopHabit(List<Habit> habits, List<HabitLog> logs) {
    if (habits.isEmpty || logs.isEmpty) {
      return null;
    }

    String? bestHabit;
    int bestCount = 0;
    int bestExpected = 0;

    for (final habit in habits) {
      final habitLogs = logs
          .where((log) => log.habitId == habit.id)
          .map((log) => _dateKey(log.date))
          .toSet();
      final completed = habitLogs.length;
      final expected = _expectedDaysForHabit(habit);
      if (completed > bestCount) {
        bestHabit = habit.name;
        bestCount = completed;
        bestExpected = expected;
      }
    }

    if (bestHabit == null) return null;
    return '$bestHabit: $bestCount/$bestExpected days';
  }

  int _expectedDaysForHabit(Habit habit) {
    if (habit.daysOfWeek.isNotEmpty) {
      return habit.daysOfWeek.length;
    }
    if (habit.frequency == HabitFrequency.weekly && habit.targetCount > 0) {
      return habit.targetCount;
    }
    return 7;
  }
}

class _EnergyMoodCard extends StatelessWidget {
  final _EnergySummary summary;

  const _EnergyMoodCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final average = summary.average;
    final previous = summary.previousAverage;
    final hasEnergy = average != null;
    final energyText = hasEnergy ? '${average.toStringAsFixed(1)}/5' : '—';
    final trendText = _trendLabel(average, previous);
    final contextInsight = _contextInsight(summary.tagCounts);

    return _SummaryCard(
      title: 'Energy & Mood',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average energy: $energyText',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            trendText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            contextInsight,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  String _trendLabel(double? current, double? previous) {
    if (current == null) {
      return 'No energy check-ins yet. Log today to unlock trends.';
    }
    if (previous == null) {
      return 'Track daily check-ins for week-over-week trends.';
    }
    final delta = current - previous;
    final direction = delta > 0.05
        ? 'Up'
        : delta < -0.05
            ? 'Down'
            : 'Steady';
    return '$direction from last week (${previous.toStringAsFixed(1)}).';
  }

  String _contextInsight(Map<String, int> tagCounts) {
    if (tagCounts.isEmpty) {
      return 'Context insights will appear as you log mood tags.';
    }
    final top = tagCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final lower = top.key.toLowerCase();
    final suggestion = (lower == 'stressed' || lower == 'tired' || lower == 'sick')
        ? 'Consider rest days.'
        : 'Keep leaning into what works.';
    return "You logged '${top.key}' ${top.value} times. $suggestion";
  }
}

class _InsightsCard extends StatelessWidget {
  final List<String> insights;

  const _InsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      title: 'Insights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: insights
            .map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _NextWeekCard extends StatelessWidget {
  final int weeklyGoal;
  final String? coachTone;
  final ValueChanged<int?> onGoalUpdated;

  const _NextWeekCard({
    required this.weeklyGoal,
    required this.coachTone,
    required this.onGoalUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final toneMessage = coachTone == 'clinical'
        ? 'Keep going.'
        : 'You\'ve got this!';

    return _SummaryCard(
      title: 'Next Week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set this week\'s goal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: weeklyGoal,
            items: List.generate(
              7,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('${index + 1} workouts'),
              ),
            ),
            onChanged: onGoalUpdated,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            toneMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  final List<DateTime> days;
  final Set<String> completedDays;

  const _WeekGrid({
    required this.days,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final dayKey = _dateKey(day);
        final isComplete = completedDays.contains(dayKey);
        final label = DateFormat('E').format(day).substring(0, 1);
        final color = isComplete
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest;
        final textColor = isComplete
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isComplete
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: textColor,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummaryCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;

  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SectionErrorCard extends StatelessWidget {
  final String message;

  const _SectionErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}
