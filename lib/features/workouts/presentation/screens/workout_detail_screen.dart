import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/exercise.dart';
import '../providers/workout_providers.dart';
import 'workout_logging_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(
              child: Text('Workout not found'),
            );
          }

          return _buildWorkoutContent(context, workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      bottomNavigationBar: workoutAsync.when(
        data: (workout) {
          if (workout == null) return null;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WorkoutLoggingScreen(
                        workout: workout,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Workout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildWorkoutContent(BuildContext context, Workout workout) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, workout),
          const SizedBox(height: 24),
          _buildInfo(context, workout),
          const SizedBox(height: 24),
          _buildExercisesList(context, workout),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Workout workout) {
    final color = _getCategoryColor(workout.category);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(workout.category),
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                workout.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, Workout workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            workout.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.access_time,
                  '${workout.estimatedDuration} min',
                  'Duration',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.bar_chart,
                  workout.difficulty.displayName,
                  'Difficulty',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.category,
                  workout.category.displayName,
                  'Category',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.fitness_center,
                  '${workout.exercises.length} exercises',
                  'Exercises',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, Workout workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workout.exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exercise = workout.exercises[index];
              return _buildExerciseCard(context, exercise, index + 1);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    int number,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (exercise.metrics != null) ...[
                    const SizedBox(height: 10),
                    _buildExerciseMetrics(context, exercise.metrics!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseMetrics(BuildContext context, ExerciseMetrics metrics) {
    final List<Widget> metricChips = [];

    if (metrics.sets != null) {
      metricChips.add(_buildMetricChip(context, '${metrics.sets} sets'));
    }
    if (metrics.reps != null) {
      metricChips.add(_buildMetricChip(context, '${metrics.reps} reps'));
    }
    if (metrics.duration != null) {
      metricChips.add(_buildMetricChip(context, '${metrics.duration}s'));
    }
    if (metrics.weight != null) {
      metricChips.add(_buildMetricChip(context, '${metrics.weight}kg'));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: metricChips,
    );
  }

  Widget _buildMetricChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
}
