import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../workouts/domain/models/workout.dart';
import '../../../workouts/presentation/screens/workout_detail_screen.dart';
import '../../../workouts/presentation/screens/workout_logging_screen.dart';
import '../../../workouts/presentation/screens/easy_pick_workouts_screen.dart';
import '../../../workouts/presentation/screens/create_workout_template_screen.dart';

class WorkoutsTab extends ConsumerWidget {
  const WorkoutsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(workoutFiltersProvider);
    final workoutsAsync = ref.watch(workoutsProvider(filters));
    final recentLogsAsync = ref.watch(recentWorkoutLogsProvider);
    final workoutStatsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: workoutsAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState(
              context,
              ref,
              recentLogsAsync: recentLogsAsync,
              workoutStatsAsync: workoutStatsAsync,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _buildWorkoutCard(context, workout);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading workouts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<List<dynamic>> recentLogsAsync,
    required AsyncValue<Map<String, dynamic>> workoutStatsAsync,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.secondary.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.self_improvement,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No workouts logged yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(        
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to log your first workout.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(        
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WorkoutLoggingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Workout'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 180,
                      child: _ActionCard(
                        label: 'Log Workout',
                        subtitle: 'Quick entry',
                        icon: Icons.add_task,
                        color: colorScheme.primary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkoutLoggingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: _ActionCard(
                        label: 'Easy Pick',
                        subtitle: 'Curated plans',
                        icon: Icons.auto_awesome,
                        color: colorScheme.secondary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EasyPickWorkoutsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: _ActionCard(
                        label: 'Create Template',
                        subtitle: 'Build your own plan',
                        icon: Icons.edit,
                        color: colorScheme.tertiary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateWorkoutTemplateScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      child: _ActionCard(
                        label: 'Add Workout',
                        subtitle: 'More options',
                        icon: Icons.add_circle,
                        color: colorScheme.primary,
                        onTap: () => _showAddWorkoutSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Week',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        workoutStatsAsync.when(
          data: (stats) => Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  label: 'Workouts',
                  value: '${stats['workoutsThisWeek'] ?? 0}',
                  icon: Icons.fitness_center,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatMiniCard(
                  label: 'Minutes',
                  value: '${stats['totalDuration'] ?? 0}',
                  icon: Icons.schedule,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatMiniCard(
                  label: 'Calories',
                  value: '${stats['totalCalories'] ?? 0}',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        recentLogsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return _EmptyPlaceholder(
                icon: Icons.history_toggle_off,
                title: 'No logged workouts yet',
                subtitle: 'Your recent sessions will show up here.',
              );
            }
            return Column(
              children: logs.take(3).map((log) {
                return _RecentLogTile(
                  title: log.workoutName,
                  subtitle: '${log.duration} min - ${log.category?.displayName ?? 'Workout'}',
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => _EmptyPlaceholder(
            icon: Icons.error_outline,
            title: 'Unable to load activity',
            subtitle: 'Try again in a moment.',
          ),
        ),
      ],
    );
  }

  void _showAddWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Workout',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose how you want to add a workout.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Log Workout'),
              subtitle: const Text('Quick or detailed manual entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkoutLoggingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: const Text('Easy Pick'),
              subtitle: const Text('Browse curated workouts and add fast'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EasyPickWorkoutsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              title: const Text('Create Template'),
              subtitle: const Text('Build a reusable workout plan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateWorkoutTemplateScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final color = _getCategoryColor(context, workout.category);
    final icon = _getCategoryIcon(workout.category);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(icon, size: 64, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.access_time,
                        '${workout.estimatedDuration} min',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        Icons.bar_chart,
                        workout.difficulty.displayName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetailScreen(
                              workoutId: workout.id,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Start Workout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final surface = Theme.of(context).colorScheme.surface;
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Workouts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkoutCategory.values.map((category) {
                final filters = ref.watch(workoutFiltersProvider);
                final isSelected = filters.category == category;
                return FilterChip(
                  label: Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primary,
                  backgroundColor: outline.withValues(alpha: 0.3),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? primary : outline,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(workoutFiltersProvider.notifier).state =
                          filters.copyWith(category: category);
                    } else {
                      ref.read(workoutFiltersProvider.notifier).state =
                          filters.clearCategory();
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkoutDifficulty.values.map((difficulty) {
                final filters = ref.watch(workoutFiltersProvider);
                final isSelected = filters.difficulty == difficulty;
                return FilterChip(
                  label: Text(
                    difficulty.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: secondary,
                  backgroundColor: outline.withValues(alpha: 0.3),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? secondary : outline,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(workoutFiltersProvider.notifier).state =
                          filters.copyWith(difficulty: difficulty);
                    } else {
                      ref.read(workoutFiltersProvider.notifier).state =
                          filters.clearDifficulty();
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(workoutFiltersProvider.notifier).state =
                      const WorkoutFilters();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Clear All Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Theme.of(context).colorScheme.primary;
      case WorkoutCategory.cardio:
        return Theme.of(context).colorScheme.secondary;
      case WorkoutCategory.yoga:
        return Theme.of(context).colorScheme.tertiary;
      case WorkoutCategory.hiit:
        return Colors.orange;
      case WorkoutCategory.flexibility:
        return Colors.purple;
      case WorkoutCategory.sports:
        return Colors.green;
      case WorkoutCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Icons.fitness_center;
      case WorkoutCategory.cardio:
        return Icons.directions_run;
      case WorkoutCategory.yoga:
        return Icons.self_improvement;
      case WorkoutCategory.hiit:
        return Icons.local_fire_department;
      case WorkoutCategory.flexibility:
        return Icons.accessibility_new;
      case WorkoutCategory.sports:
        return Icons.sports_basketball;
      case WorkoutCategory.other:
        return Icons.local_activity;
    }
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentLogTile extends StatelessWidget {
  const _RecentLogTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



