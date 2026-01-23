import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/data/services/user_stats_service.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/domain/models/progress_goal.dart';
import '../widgets/achievement_list.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutStatsAsync = ref.watch(workoutStatsProvider);
    final habitStatsAsync = ref.watch(habitStatsProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final allGoalsAsync = ref.watch(allGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your Milestones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock achievements by completing workouts, habits, and goals.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
          ),
          const SizedBox(height: 16),
          _buildAchievementsContent(
            context,
            workoutStatsAsync,
            habitStatsAsync,
            userStatsAsync,
            allGoalsAsync,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsContent(
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

    final unlockedCount =
        achievements.where((achievement) => achievement.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Text(
                '$unlockedCount of ${achievements.length} unlocked',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AchievementsList(achievements: achievements),
      ],
    );
  }
}
