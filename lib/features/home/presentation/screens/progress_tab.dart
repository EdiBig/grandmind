import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../progress/presentation/widgets/weight_input_dialog.dart';
import '../../../progress/presentation/screens/weight_tracking_screen.dart';
import '../../../progress/presentation/screens/measurements_screen.dart';
import '../../../progress/presentation/screens/progress_photos_screen.dart';
import '../../../progress/presentation/screens/goals_screen.dart';
import '../../../progress/presentation/screens/progress_dashboard_screen.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/domain/models/progress_goal.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/data/services/user_stats_service.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/achievement_list.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch progress data
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final latestMeasurementsAsync = ref.watch(latestMeasurementsProvider);
    final workoutStatsAsync = ref.watch(workoutStatsProvider);
    final habitStatsAsync = ref.watch(habitStatsProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final allGoalsAsync = ref.watch(allGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'View Dashboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProgressDashboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share progress
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(
            context,
            ref,
            latestWeightAsync,
            activeGoalsAsync,
            latestMeasurementsAsync,
          ),
          const SizedBox(height: 24),
          // Quick Access Card for Weight Tracking
          _buildQuickAccessCard(
            context,
            'Weight Tracking',
            'Track your weight progress',
            Icons.monitor_weight,
            Theme.of(context).colorScheme.primary,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WeightTrackingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Quick Access Card for Body Measurements
          _buildQuickAccessCard(
            context,
            'Body Measurements',
            'Track your body measurements',
            Icons.straighten,
            Theme.of(context).colorScheme.secondary,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MeasurementsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Quick Access Card for Progress Photos
          _buildQuickAccessCard(
            context,
            'Progress Photos',
            'Track your visual transformation',
            Icons.photo_camera,
            Theme.of(context).colorScheme.tertiary,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProgressPhotosScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Quick Access Card for Goals
          _buildQuickAccessCard(
            context,
            'Goals',
            'Set and track your fitness goals',
            Icons.flag,
            Colors.purple,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMetricsSection(
            context,
            workoutStatsAsync,
            habitStatsAsync,
            userStatsAsync,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.push(RouteConstants.achievements),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAchievementsList(
            context,
            workoutStatsAsync,
            habitStatsAsync,
            userStatsAsync,
            allGoalsAsync,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => WeightInputDialog.show(context),
        icon: const Icon(Icons.monitor_weight),
        label: const Text('Log Weight'),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue latestWeight,
    AsyncValue activeGoals,
    AsyncValue latestMeasurements,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Latest Weight
              Expanded(
                child: latestWeight.when(
                  data: (weight) {
                    if (weight != null) {
                      return _buildOverviewStat(
                        context,
                        weight.weight.toStringAsFixed(1),
                        'kg',
                        Icons.monitor_weight,
                      );
                    }
                    return _buildOverviewStat(
                      context,
                      '--',
                      'Weight',
                      Icons.monitor_weight,
                    );
                  },
                  loading: () => _buildOverviewStat(
                    context,
                    '...',
                    'Loading',
                    Icons.monitor_weight,
                  ),
                  error: (_, __) => _buildOverviewStat(
                    context,
                    '--',
                    'Weight',
                    Icons.monitor_weight,
                  ),
                ),
              ),
              // Active Goals
              Expanded(
                child: activeGoals.when(
                  data: (goals) {
                    final count = goals.where((g) => g.status == GoalStatus.active).length;
                    return _buildOverviewStat(
                      context,
                      '$count',
                      count == 1 ? 'Goal' : 'Goals',
                      Icons.flag,
                    );
                  },
                  loading: () => _buildOverviewStat(
                    context,
                    '...',
                    'Goals',
                    Icons.flag,
                  ),
                  error: (_, __) => _buildOverviewStat(
                    context,
                    '0',
                    'Goals',
                    Icons.flag,
                  ),
                ),
              ),
              // Measurements Count
              Expanded(
                child: latestMeasurements.when(
                  data: (measurements) {
                    final count = measurements?.measurements.length ?? 0;
                    return _buildOverviewStat(
                      context,
                      '$count',
                      'Metrics',
                      Icons.straighten,
                    );
                  },
                  loading: () => _buildOverviewStat(
                    context,
                    '...',
                    'Metrics',
                    Icons.straighten,
                  ),
                  error: (_, __) => _buildOverviewStat(
                    context,
                    '0',
                    'Metrics',
                    Icons.straighten,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> workoutStatsAsync,
    AsyncValue<Map<String, dynamic>> habitStatsAsync,
    AsyncValue<UserStats> userStatsAsync,
  ) {
    if (workoutStatsAsync.isLoading ||
        habitStatsAsync.isLoading ||
        userStatsAsync.isLoading) {
      return Column(
        children: [
          _buildMetricCard(
            context,
            'Weekly Activity',
            'Loading...',
            0,
            Icons.fitness_center,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Habits Streak',
            'Loading...',
            0,
            Icons.local_fire_department,
            Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Total Workouts',
            'Loading...',
            0,
            Icons.show_chart,
            Theme.of(context).colorScheme.tertiary,
          ),
        ],
      );
    }

    if (workoutStatsAsync.hasError ||
        habitStatsAsync.hasError ||
        userStatsAsync.hasError) {
      return Column(
        children: [
          _buildMetricCard(
            context,
            'Weekly Activity',
            'Unavailable',
            0,
            Icons.fitness_center,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Habits Streak',
            'Unavailable',
            0,
            Icons.local_fire_department,
            Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Total Workouts',
            'Unavailable',
            0,
            Icons.show_chart,
            Theme.of(context).colorScheme.tertiary,
          ),
        ],
      );
    }

    final workoutStats = workoutStatsAsync.asData?.value ?? {};
    final habitStats = habitStatsAsync.asData?.value ?? {};
    final userStats = userStatsAsync.asData?.value ?? UserStats.empty();

    final workoutsThisWeek = workoutStats['workoutsThisWeek'] as int? ?? 0;
    final workoutsThisMonth = workoutStats['workoutsThisMonth'] as int? ?? 0;
    final totalWorkouts = workoutStats['totalWorkouts'] as int? ?? 0;
    final currentStreak = userStats.currentStreak;
    final habitCompletionRate =
        (habitStats['completionRate'] as num?)?.toDouble() ?? 0.0;

    final weeklyProgress = (workoutsThisWeek / 7).clamp(0.0, 1.0);
    final streakProgress = (currentStreak / 7).clamp(0.0, 1.0);
    final totalWorkoutsProgress = (totalWorkouts / 50).clamp(0.0, 1.0);

    return Column(
      children: [
        _buildMetricCard(
          context,
          'Weekly Activity',
          '$workoutsThisWeek of 7 days active',
          weeklyProgress,
          Icons.fitness_center,
          Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context,
          'Habits Streak',
          '$currentStreak days • ${habitCompletionRate.toStringAsFixed(0)}% today',
          streakProgress,
          Icons.local_fire_department,
          Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context,
          'Total Workouts',
          '$workoutsThisMonth this month',
          totalWorkoutsProgress,
          Icons.show_chart,
          Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildAchievementsList(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> workoutStatsAsync,
    AsyncValue<Map<String, dynamic>> habitStatsAsync,
    AsyncValue<UserStats> userStatsAsync,
    AsyncValue<List<ProgressGoal>> allGoalsAsync,
  ) {
    if (workoutStatsAsync.isLoading ||
        habitStatsAsync.isLoading ||
        userStatsAsync.isLoading ||
        allGoalsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (workoutStatsAsync.hasError ||
        habitStatsAsync.hasError ||
        userStatsAsync.hasError ||
        allGoalsAsync.hasError) {
      return Text(
        'Achievements unavailable',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final workoutStats = workoutStatsAsync.asData?.value ?? {};
    final habitStats = habitStatsAsync.asData?.value ?? {};
    final userStats = userStatsAsync.asData?.value ?? UserStats.empty();
    final goals = allGoalsAsync.asData?.value ?? [];

    final achievements = buildAchievementData(
      context: context,
      workoutStats: workoutStats,
      habitStats: habitStats,
      userStats: userStats,
      goals: goals,
    );

    return AchievementsList(
      achievements: achievements,
      maxItems: 4,
    );
  }

}
