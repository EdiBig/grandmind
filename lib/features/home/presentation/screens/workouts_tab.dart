import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../workouts/domain/models/workout.dart';
import '../../../workouts/presentation/screens/workout_detail_screen.dart';
import '../../../workouts/presentation/screens/workout_logging_screen.dart';

class WorkoutsTab extends ConsumerWidget {
  const WorkoutsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(workoutFiltersProvider);
    final workoutsAsync = ref.watch(workoutsProvider(filters));

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WorkoutLoggingScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final color = _getCategoryColor(workout.category);
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
              color: Colors.black.withOpacity(0.05),
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
                  colors: [color.withOpacity(0.8), color],
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                        color: AppColors.textPrimaryLight,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.greyDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
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
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.greyLight.withOpacity(0.3),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.greyLight,
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
                    color: AppColors.textPrimaryLight,
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
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.greyLight.withOpacity(0.3),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.secondary : AppColors.greyLight,
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
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
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

  Color _getCategoryColor(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return AppColors.primary;
      case WorkoutCategory.cardio:
        return AppColors.secondary;
      case WorkoutCategory.yoga:
        return AppColors.accent;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
