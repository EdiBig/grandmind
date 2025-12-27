import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class HabitsTab extends ConsumerWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProgressSummary(context),
          const SizedBox(height: 24),
          Text(
            'Today\'s Habits',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildHabitItem(
            context,
            'Drink 8 glasses of water',
            '6/8 completed',
            0.75,
            Icons.local_drink,
            AppColors.primary,
            true,
          ),
          const SizedBox(height: 12),
          _buildHabitItem(
            context,
            'Get 8 hours of sleep',
            'Not tracked today',
            0.0,
            Icons.bedtime,
            AppColors.secondary,
            false,
          ),
          const SizedBox(height: 12),
          _buildHabitItem(
            context,
            'Meditate for 10 minutes',
            'Completed',
            1.0,
            Icons.self_improvement,
            AppColors.accent,
            true,
          ),
          const SizedBox(height: 12),
          _buildHabitItem(
            context,
            'Walk 10,000 steps',
            '7,500 steps',
            0.75,
            Icons.directions_walk,
            AppColors.primary,
            true,
          ),
          const SizedBox(height: 12),
          _buildHabitItem(
            context,
            'Read for 30 minutes',
            'Not started',
            0.0,
            Icons.menu_book,
            AppColors.secondary,
            false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
              _buildProgressItem(context, '3', '5', 'Completed'),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildProgressItem(context, '60%', '', 'Completion'),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildProgressItem(context, '12', '', 'Day Streak'),
            ],
          ),
        ],
      ),
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
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
          ],
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

  Widget _buildHabitItem(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
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
              if (progress >= 1.0)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.grey,
                  onPressed: () {},
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
    );
  }
}
