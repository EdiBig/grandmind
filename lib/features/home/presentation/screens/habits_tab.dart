import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../habits/presentation/widgets/habit_icon_helper.dart';
import '../../../habits/presentation/widgets/ai_insights_card.dart';

class HabitsTab extends ConsumerWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(userHabitsProvider);
    final statsAsync = ref.watch(habitStatsProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Navigate to habit calendar view
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          return todayLogsAsync.when(
            data: (todayLogs) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userHabitsProvider);
                  ref.invalidate(habitStatsProvider);
                  ref.invalidate(todayHabitLogsProvider);
                },
                child: habits.isEmpty
                    ? _buildEmptyState(context)
                    : _buildHabitsList(context, ref, habits, todayLogs, statsAsync),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorState(context, error.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/habits/create');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitsList(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
    List todayLogs,
    AsyncValue<Map<String, dynamic>> statsAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProgressSummary(context, statsAsync),
        const SizedBox(height: 24),
        const AIInsightsCard(),
        Text(
          'Today\'s Habits',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...habits.map((habit) {
          final matchingLogs = todayLogs.where((log) => log.habitId == habit.id);
          final isCompletedToday = matchingLogs.isNotEmpty;
          final todayLog = matchingLogs.isNotEmpty ? matchingLogs.first : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHabitItem(
              context,
              ref,
              habit,
              isCompletedToday,
              todayLog?.count ?? 0,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building healthy habits today!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/habits/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Habit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading habits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> statsAsync,
  ) {
    return statsAsync.when(
      data: (stats) {
        final totalHabits = stats['totalHabits'] ?? 0;
        final completedToday = stats['completedToday'] ?? 0;
        final completionRate = stats['completionRate'] ?? 0;
        final longestStreak = stats['longestStreak'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Today\'s Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressItem(
                    context,
                    completedToday.toString(),
                    totalHabits.toString(),
                    'Completed',
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  _buildProgressItem(
                    context,
                    '$completionRate%',
                    '',
                    'Completion',
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  _buildProgressItem(
                    context,
                    longestStreak.toString(),
                    '',
                    'Best Streak',
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String value,
    String suffix,
    String label,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (suffix.isNotEmpty)
              Text(
                '/$suffix',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    bool isCompletedToday,
    int count,
  ) {
    final color = HabitIconHelper.getColor(habit.color);
    final icon = HabitIconHelper.getIconData(habit.icon);
    final habitOps = ref.read(habitOperationsProvider.notifier);

    // Calculate progress for quantifiable habits
    double progress = 0.0;
    String subtitle = '';

    if (habit.targetCount > 0) {
      progress = count / habit.targetCount;
      if (progress >= 1.0) {
        subtitle = 'Completed';
      } else if (count > 0) {
        subtitle = '$count/${habit.targetCount} ${habit.unit ?? ''}';
      } else {
        subtitle = 'Not started';
      }
    } else {
      // Simple yes/no habits
      if (isCompletedToday) {
        progress = 1.0;
        subtitle = 'Completed';
      } else {
        subtitle = 'Not started';
      }
    }

    return GestureDetector(
      onLongPress: () {
        _showHabitOptions(context, ref, habit);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompletedToday
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        if (habit.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department,
                              size: 14, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (progress >= 1.0)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.grey,
                  onPressed: () async {
                    // For quantifiable habits, mark as complete with target count
                    if (habit.targetCount > 0) {
                      await habitOps.logHabitWithCount(habit, habit.targetCount);
                    } else {
                      // For simple yes/no habits, toggle completion
                      await habitOps.toggleHabitCompletion(habit);
                    }
                    ref.invalidate(todayHabitLogsProvider);
                    ref.invalidate(userHabitsProvider);
                    ref.invalidate(habitStatsProvider);
                  },
                ),
            ],
          ),
          if (progress > 0 && progress < 1.0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Habit'),
              onTap: () {
                context.pop();
                context.push('/habits/edit/${habit.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Habit', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.pop();
                _confirmDeleteHabit(context, ref, habit);
              },
            ),
            ListTile(
              leading: Icon(habit.isActive ? Icons.archive : Icons.unarchive),
              title: Text(habit.isActive ? 'Archive Habit' : 'Unarchive Habit'),
              onTap: () async {
                context.pop();
                final habitOps = ref.read(habitOperationsProvider.notifier);
                await habitOps.setHabitActive(habit.id, !habit.isActive);
                ref.invalidate(userHabitsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              final habitOps = ref.read(habitOperationsProvider.notifier);
              final success = await habitOps.deleteHabit(habit.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Habit deleted successfully'
                        : 'Failed to delete habit'),
                  ),
                );
              }

              ref.invalidate(userHabitsProvider);
              ref.invalidate(habitStatsProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
