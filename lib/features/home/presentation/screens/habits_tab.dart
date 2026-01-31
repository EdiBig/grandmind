import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../habits/data/repositories/habit_repository.dart';
import '../../../habits/presentation/widgets/habit_icon_helper.dart';
import '../../../habits/presentation/widgets/ai_insights_card.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../../core/constants/route_constants.dart';

/// Filter options for habits
enum HabitFilterType { all, active, archived }
enum HabitFilterFrequency { all, daily, weekly, custom }
enum HabitSortOption { createdAt, name, streak }

/// Provider for habit search query
final habitSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for habit filter type
final habitFilterTypeProvider = StateProvider<HabitFilterType>((ref) => HabitFilterType.all);

/// Provider for habit filter frequency
final habitFilterFrequencyProvider = StateProvider<HabitFilterFrequency>((ref) => HabitFilterFrequency.all);

/// Provider for habit sort option
final habitSortOptionProvider = StateProvider<HabitSortOption>((ref) => HabitSortOption.createdAt);

/// Provider for showing archived habits
final showArchivedHabitsProvider = StateProvider<bool>((ref) => false);

/// Provider for all habits (including archived) for filtering
final allUserHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final showArchived = ref.watch(showArchivedHabitsProvider);
  final userId = ref.watch(userHabitsProvider).asData?.value.firstOrNull?.userId;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(habitRepositoryProvider);
  return showArchived
    ? repository.getUserHabitsStream(userId)
    : repository.getUserHabitsStream(userId, isActive: true);
});

class HabitsTab extends ConsumerStatefulWidget {
  const HabitsTab({super.key});

  @override
  ConsumerState<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends ConsumerState<HabitsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Habit> _filterAndSortHabits(List<Habit> habits) {
    final searchQuery = ref.read(habitSearchQueryProvider).toLowerCase();
    final filterFrequency = ref.read(habitFilterFrequencyProvider);
    final sortOption = ref.read(habitSortOptionProvider);

    var filtered = habits.where((habit) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        if (!habit.name.toLowerCase().contains(searchQuery) &&
            !habit.description.toLowerCase().contains(searchQuery)) {
          return false;
        }
      }

      // Frequency filter
      if (filterFrequency != HabitFilterFrequency.all) {
        switch (filterFrequency) {
          case HabitFilterFrequency.daily:
            if (habit.frequency != HabitFrequency.daily) return false;
            break;
          case HabitFilterFrequency.weekly:
            if (habit.frequency != HabitFrequency.weekly) return false;
            break;
          case HabitFilterFrequency.custom:
            if (habit.frequency != HabitFrequency.custom) return false;
            break;
          default:
            break;
        }
      }

      return true;
    }).toList();

    // Sort
    switch (sortOption) {
      case HabitSortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case HabitSortOption.streak:
        filtered.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        break;
      case HabitSortOption.createdAt:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return filtered;
  }

  void _showFilterSheet(BuildContext context) {
    final filterFrequency = ref.read(habitFilterFrequencyProvider);
    final sortOption = ref.read(habitSortOptionProvider);
    final showArchived = ref.read(showArchivedHabitsProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(habitFilterFrequencyProvider.notifier).state = HabitFilterFrequency.all;
                        ref.read(habitSortOptionProvider.notifier).state = HabitSortOption.createdAt;
                        ref.read(showArchivedHabitsProvider.notifier).state = false;
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Frequency',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: HabitFilterFrequency.values.map((freq) {
                    final isSelected = filterFrequency == freq;
                    return FilterChip(
                      label: Text(freq.name[0].toUpperCase() + freq.name.substring(1)),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(habitFilterFrequencyProvider.notifier).state = freq;
                        setSheetState(() {});
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Created'),
                      selected: sortOption == HabitSortOption.createdAt,
                      onSelected: (selected) {
                        ref.read(habitSortOptionProvider.notifier).state = HabitSortOption.createdAt;
                        setSheetState(() {});
                        setState(() {});
                      },
                    ),
                    FilterChip(
                      label: const Text('Name'),
                      selected: sortOption == HabitSortOption.name,
                      onSelected: (selected) {
                        ref.read(habitSortOptionProvider.notifier).state = HabitSortOption.name;
                        setSheetState(() {});
                        setState(() {});
                      },
                    ),
                    FilterChip(
                      label: const Text('Streak'),
                      selected: sortOption == HabitSortOption.streak,
                      onSelected: (selected) {
                        ref.read(habitSortOptionProvider.notifier).state = HabitSortOption.streak;
                        setSheetState(() {});
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show archived habits'),
                  value: showArchived,
                  onChanged: (value) {
                    ref.read(showArchivedHabitsProvider.notifier).state = value;
                    setSheetState(() {});
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final habitsAsync = ref.watch(userHabitsProvider);
    final statsAsync = ref.watch(habitStatsProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);
    final searchQuery = ref.watch(habitSearchQueryProvider);
    final filterFrequency = ref.watch(habitFilterFrequencyProvider);

    final hasActiveFilters = searchQuery.isNotEmpty || filterFrequency != HabitFilterFrequency.all;

    if (!settings.habitsEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Habits'),
        ),
        body: _buildModuleDisabled(
          context,
          title: 'Habits are turned off',
          subtitle: 'Enable habits in Settings to use this tab.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search habits...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: (value) {
                  ref.read(habitSearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('Habits'),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            tooltip: _showSearchBar ? 'Close search' : 'Search habits',
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  ref.read(habitSearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'View calendar',
            onPressed: () {
              context.push(RouteConstants.habitCalendar);
            },
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          final filteredHabits = _filterAndSortHabits(habits);
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
                    : filteredHabits.isEmpty
                        ? _buildNoResultsState(context)
                        : _buildHabitsList(context, ref, filteredHabits, todayLogs, statsAsync),
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
        tooltip: 'Create new habit',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              ref.read(habitSearchQueryProvider.notifier).state = '';
              ref.read(habitFilterFrequencyProvider.notifier).state = HabitFilterFrequency.all;
              setState(() => _showSearchBar = false);
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleDisabled(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(RouteConstants.settings),
              child: const Text('Open Settings'),
            ),
          ],
        ),
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
    final searchQuery = this.ref.watch(habitSearchQueryProvider);
    final showSearch = searchQuery.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!showSearch) ...[
          _buildProgressSummary(context, statsAsync),
          const SizedBox(height: 24),
          const AIInsightsCard(),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showSearch ? 'Search Results' : 'Today\'s Habits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (!showSearch)
              TextButton.icon(
                onPressed: () {
                  context.push(RouteConstants.habitHistory);
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text('History'),
              ),
          ],
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
            Icons.checklist,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build consistency by tracking daily habits',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/habits/create');
            },
            icon: Icon(Icons.add),
            label: const Text('Add Your First Habit'),
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
                      color: AppColors.white,
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
                    color: AppColors.white.withValues(alpha: 0.3),
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
                    color: AppColors.white.withValues(alpha: 0.3),
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
          child: CircularProgressIndicator(color: AppColors.white),
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
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (suffix.isNotEmpty)
              Text(
                '/$suffix',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(
    BuildContext context,
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
        _showHabitOptions(context, habit);
      },
      onTap: () {
        // Navigate to habit history when tapping on the habit card
        context.push('/habits/${habit.id}/history');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompletedToday
                ? color.withValues(alpha: 0.3)
                : AppColors.grey.withValues(alpha: 0.2),
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
                                color: AppColors.grey,
                              ),
                        ),
                        if (habit.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.local_fire_department,
                              size: 14, color: AppColors.warning,
                              semanticLabel: 'Current streak'),
                          const SizedBox(width: 2),
                          Text(
                            '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
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
                Icon(Icons.check_circle, color: AppColors.success, size: 28,
                    semanticLabel: 'Habit completed')
              else
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.grey,
                  tooltip: 'Mark habit as complete',
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/habits/${habit.id}/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Habit'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/habits/edit/${habit.id}');
              },
            ),
            ListTile(
              leading: Icon(habit.isActive ? Icons.archive : Icons.unarchive),
              title: Text(habit.isActive ? 'Archive Habit' : 'Unarchive Habit'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final habitOps = ref.read(habitOperationsProvider.notifier);
                await habitOps.setHabitActive(habit.id, !habit.isActive);
                ref.invalidate(userHabitsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Habit', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDeleteHabit(context, habit);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Content-only version of HabitsTab for embedding in TrackTab.
/// Does not include Scaffold, AppBar, or FloatingActionButton.
class HabitsTabContent extends ConsumerStatefulWidget {
  const HabitsTabContent({super.key});

  @override
  ConsumerState<HabitsTabContent> createState() => _HabitsTabContentState();
}

class _HabitsTabContentState extends ConsumerState<HabitsTabContent> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final habitsAsync = ref.watch(userHabitsProvider);
    final statsAsync = ref.watch(habitStatsProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);

    if (!settings.habitsEnabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Habits are turned off',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enable habits in Settings to use this tab.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(RouteConstants.settings),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        habitsAsync.when(
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
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error loading habits', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(error.toString(), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error loading habits', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
        // Floating action button positioned at bottom right
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'habits_fab',
            onPressed: () => context.push('/habits/create'),
            tooltip: 'Create new habit',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build consistency by tracking daily habits',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/habits/create'),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Habit'),
          ),
        ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Habits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () => context.push(RouteConstants.habitHistory),
              icon: const Icon(Icons.history, size: 18),
              label: const Text('History'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...habits.map((habit) {
          final matchingLogs = todayLogs.where((log) => log.habitId == habit.id);
          final isCompletedToday = matchingLogs.isNotEmpty;
          final todayLog = matchingLogs.isNotEmpty ? matchingLogs.first : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHabitItem(context, habit, isCompletedToday, todayLog?.count ?? 0),
          );
        }),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildProgressSummary(BuildContext context, AsyncValue<Map<String, dynamic>> statsAsync) {
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
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressItem(context, completedToday.toString(), totalHabits.toString(), 'Completed'),
                  Container(height: 50, width: 1, color: AppColors.white.withValues(alpha: 0.3)),
                  _buildProgressItem(context, '$completionRate%', '', 'Completion'),
                  Container(height: 50, width: 1, color: AppColors.white.withValues(alpha: 0.3)),
                  _buildProgressItem(context, longestStreak.toString(), '', 'Best Streak'),
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
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressItem(BuildContext context, String value, String suffix, String label) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (suffix.isNotEmpty)
              Text(
                '/$suffix',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(BuildContext context, Habit habit, bool isCompletedToday, int count) {
    final color = HabitIconHelper.getColor(habit.color);
    final icon = HabitIconHelper.getIconData(habit.icon);
    final habitOps = ref.read(habitOperationsProvider.notifier);

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
      if (isCompletedToday) {
        progress = 1.0;
        subtitle = 'Completed';
      } else {
        subtitle = 'Not started';
      }
    }

    return GestureDetector(
      onTap: () => context.push('/habits/${habit.id}/history'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompletedToday ? color.withValues(alpha: 0.3) : AppColors.grey.withValues(alpha: 0.2),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                          ),
                          if (habit.currentStreak > 0) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.local_fire_department, size: 14, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
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
                  const Icon(Icons.check_circle, color: AppColors.success, size: 28)
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColors.grey,
                    tooltip: 'Mark habit as complete',
                    onPressed: () async {
                      if (habit.targetCount > 0) {
                        await habitOps.logHabitWithCount(habit, habit.targetCount);
                      } else {
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
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
