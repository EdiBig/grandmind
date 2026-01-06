import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../../../health/presentation/widgets/health_dashboard_card.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinesa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(RouteConstants.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context, ref),
            const SizedBox(height: 24),
            // Health Dashboard Card
            const HealthDashboardCard(),
            const SizedBox(height: 24),
            _buildQuickStats(context, ref),
            const SizedBox(height: 24),
            _buildMotivationalTip(context, ref),
            const SizedBox(height: 24),
            _buildAICoachCard(context),
            const SizedBox(height: 24),
            _buildTodaySection(context, ref),
            const SizedBox(height: 24),
            _buildRecentActivity(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.logActivity),
        icon: const Icon(Icons.add),
        label: const Text('Log Activity'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final coachTone = user?.onboarding?['coachTone'] as String?;
        final userName = user?.displayName ?? user?.email?.split('@').first;
        final welcomeMessage = MotivationalMessages.getWelcomeMessage(coachTone, userName);
        final subtitleMessage = MotivationalMessages.getSubtitleMessage(coachTone);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                welcomeMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitleMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Workouts',
                  '${stats.workoutsThisWeek}',
                  'This week',
                  Icons.fitness_center,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Habits',
                  '${stats.habitCompletionRate.toStringAsFixed(0)}%',
                  'Completion',
                  Icons.track_changes,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          loading: () => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Workouts',
                  '...',
                  'This week',
                  Icons.fitness_center,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Habits',
                  '...',
                  'Completion',
                  Icons.track_changes,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          error: (_, __) => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Workouts',
                  '0',
                  'This week',
                  Icons.fitness_center,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Habits',
                  '0%',
                  'Completion',
                  Icons.track_changes,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalTip(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return userAsync.when(
      data: (user) {
        final coachTone = user?.onboarding?['coachTone'] as String?;

        return statsAsync.when(
          data: (stats) {
            final streakMessage = MotivationalMessages.getStreakMessage(stats.currentStreak, coachTone);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.accent,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Motivation',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streakMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTodaySection(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todayPlanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        planAsync.when(
          data: (planItems) {
            if (planItems.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    'No activities planned for today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            }

            return Column(
              children: planItems.map((item) {
                final icon = _getPlanItemIcon(item.type);
                final color = _getPlanItemColor(item.type);
                final time = item.scheduledTime != null
                    ? DateFormat('h:mm a').format(item.scheduledTime!)
                    : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTodayItem(
                    context,
                    item.title,
                    time,
                    item.description,
                    icon,
                    color,
                    item.isCompleted,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Center(child: Text('Error loading today\'s plan')),
          ),
        ),
      ],
    );
  }

  IconData _getPlanItemIcon(PlanItemType type) {
    switch (type) {
      case PlanItemType.workout:
        return Icons.fitness_center;
      case PlanItemType.meditation:
        return Icons.self_improvement;
      case PlanItemType.walk:
        return Icons.directions_walk;
      case PlanItemType.habit:
        return Icons.track_changes;
      case PlanItemType.meal:
        return Icons.restaurant;
      default:
        return Icons.task_alt;
    }
  }

  Color _getPlanItemColor(PlanItemType type) {
    switch (type) {
      case PlanItemType.workout:
        return AppColors.primary;
      case PlanItemType.meditation:
        return AppColors.secondary;
      case PlanItemType.walk:
        return AppColors.accent;
      case PlanItemType.habit:
        return Colors.green;
      case PlanItemType.meal:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTodayItem(
    BuildContext context,
    String title,
    String time,
    String subtitle,
    IconData icon,
    Color color,
    bool completed,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              if (completed)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    'No recent activities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            }

            return Column(
              children: activities.take(3).map((activity) {
                final icon = _getActivityIcon(activity.type);
                final color = _getActivityColor(activity.type);
                final timeAgo = _formatTimeAgo(activity.timestamp);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildActivityItem(
                    context,
                    activity.title,
                    timeAgo,
                    icon,
                    color,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Center(child: Text('Error loading activities')),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return Icons.fitness_center;
      case ActivityType.sleep:
        return Icons.bedtime;
      case ActivityType.steps:
        return Icons.directions_walk;
      case ActivityType.habit:
        return Icons.check_circle;
      case ActivityType.weight:
        return Icons.monitor_weight;
      case ActivityType.mood:
        return Icons.sentiment_satisfied;
      case ActivityType.nutrition:
        return Icons.restaurant;
      default:
        return Icons.local_activity;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return AppColors.primary;
      case ActivityType.sleep:
        return AppColors.secondary;
      case ActivityType.steps:
        return AppColors.accent;
      case ActivityType.habit:
        return Colors.green;
      case ActivityType.weight:
        return Colors.orange;
      case ActivityType.mood:
        return Colors.purple;
      case ActivityType.nutrition:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
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
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.aiCoach),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400,
              Colors.deepPurple.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Fitness Coach',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get personalized workout recommendations and expert guidance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Chat Now',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
