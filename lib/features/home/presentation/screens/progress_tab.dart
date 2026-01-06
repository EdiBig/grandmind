import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../progress/presentation/widgets/weight_input_dialog.dart';
import '../../../progress/presentation/screens/weight_tracking_screen.dart';
import '../../../progress/presentation/screens/measurements_screen.dart';
import '../../../progress/presentation/screens/progress_photos_screen.dart';
import '../../../progress/presentation/screens/goals_screen.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(context),
          const SizedBox(height: 24),
          // Quick Access Card for Weight Tracking
          _buildQuickAccessCard(
            context,
            'Weight Tracking',
            'Track your weight progress',
            Icons.monitor_weight,
            AppColors.primary,
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
            AppColors.secondary,
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
            AppColors.accent,
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
          _buildMetricCard(
            context,
            'Weekly Activity',
            '5 of 7 days active',
            0.71,
            Icons.fitness_center,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Habits Streak',
            '12 days in a row',
            0.85,
            Icons.local_fire_department,
            AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Total Workouts',
            '48 this month',
            0.92,
            Icons.show_chart,
            AppColors.accent,
          ),
          const SizedBox(height: 24),
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildAchievementsList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => WeightInputDialog.show(context),
        icon: const Icon(Icons.monitor_weight),
        label: const Text('Log Weight'),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(context, '245', 'Minutes', Icons.timer),
              ),
              Expanded(
                child: _buildOverviewStat(context, '1,850', 'Calories', Icons.local_fire_department),
              ),
              Expanded(
                child: _buildOverviewStat(context, '12', 'Workouts', Icons.fitness_center),
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
                color: Colors.white.withOpacity(0.9),
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
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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

  Widget _buildAchievementsList(BuildContext context) {
    return Column(
      children: [
        _buildAchievementItem(
          context,
          'Early Bird',
          'Complete 5 morning workouts',
          Icons.wb_sunny,
          AppColors.primary,
          true,
        ),
        const SizedBox(height: 8),
        _buildAchievementItem(
          context,
          'Consistency King',
          'Maintain a 7-day streak',
          Icons.trending_up,
          AppColors.secondary,
          true,
        ),
        const SizedBox(height: 8),
        _buildAchievementItem(
          context,
          'Habit Master',
          'Complete all habits for a week',
          Icons.stars,
          AppColors.accent,
          false,
        ),
        const SizedBox(height: 8),
        _buildAchievementItem(
          context,
          'Iron Will',
          'Complete 100 workouts',
          Icons.military_tech,
          Colors.grey,
          false,
        ),
      ],
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool unlocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? color : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
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
                        color: unlocked ? null : Colors.grey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 28)
          else
            Icon(Icons.lock_outline, color: Colors.grey[400], size: 28),
        ],
      ),
    );
  }
}
