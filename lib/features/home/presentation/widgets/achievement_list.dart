import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/services/user_stats_service.dart';
import '../../../progress/domain/models/progress_goal.dart';

@immutable
class AchievementData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final double progress;
  final String progressLabel;

  const AchievementData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.progress,
    required this.progressLabel,
  });
}

List<AchievementData> buildAchievementData({
  required BuildContext context,
  required Map<String, dynamic> workoutStats,
  required Map<String, dynamic> habitStats,
  required UserStats userStats,
  required List<ProgressGoal> goals,
}) {
  final totalWorkouts = workoutStats['totalWorkouts'] as int? ?? 0;
  final longestStreak = userStats.longestStreak;
  final completedGoals =
      goals.where((goal) => goal.status == GoalStatus.completed).length;
  final completionRate =
      (habitStats['completionRate'] as num?)?.toDouble() ?? 0.0;

  return [
    AchievementData(
      title: 'First Workout',
      description: 'Complete your first workout',
      icon: Icons.fitness_center,
      color: Theme.of(context).colorScheme.primary,
      unlocked: totalWorkouts >= 1,
      progress: (totalWorkouts / 1).clamp(0.0, 1.0),
      progressLabel: '$totalWorkouts / 1',
    ),
    AchievementData(
      title: 'Workout Consistency',
      description: 'Complete 10 workouts',
      icon: Icons.trending_up,
      color: Theme.of(context).colorScheme.primary,
      unlocked: totalWorkouts >= 10,
      progress: (totalWorkouts / 10).clamp(0.0, 1.0),
      progressLabel: '$totalWorkouts / 10',
    ),
    AchievementData(
      title: 'Streak Starter',
      description: 'Maintain a 7-day habit streak',
      icon: Icons.local_fire_department,
      color: Theme.of(context).colorScheme.secondary,
      unlocked: longestStreak >= 7,
      progress: (longestStreak / 7).clamp(0.0, 1.0),
      progressLabel: '$longestStreak / 7',
    ),
    AchievementData(
      title: 'Habit Hero',
      description: 'Hit 100% habit completion today',
      icon: Icons.stars,
      color: Theme.of(context).colorScheme.tertiary,
      unlocked: completionRate >= 100,
      progress: (completionRate / 100).clamp(0.0, 1.0),
      progressLabel: '${completionRate.toStringAsFixed(0)}%',
    ),
    AchievementData(
      title: 'Goal Getter',
      description: 'Complete your first goal',
      icon: Icons.flag,
      color: Theme.of(context).colorScheme.tertiary,
      unlocked: completedGoals >= 1,
      progress: (completedGoals / 1).clamp(0.0, 1.0),
      progressLabel: '$completedGoals / 1',
    ),
  ];
}

class AchievementsList extends StatelessWidget {
  final List<AchievementData> achievements;
  final int? maxItems;

  const AchievementsList({
    super.key,
    required this.achievements,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final items = maxItems == null
        ? achievements
        : achievements.take(maxItems!).toList();

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          'No achievements yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: items
          .map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AchievementItem(achievement: achievement),
            ),
          )
          .toList(),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final AchievementData achievement;

  const _AchievementItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final color = achievement.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(achievement.icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: unlocked
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      achievement.progressLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: unlocked
                                ? color
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(Icons.check_circle, color: AppColors.success, size: 28)
          else
            Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.outlineVariant,
              size: 28,
            ),
        ],
      ),
    );
  }
}
