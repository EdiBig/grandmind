import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/progress_goal.dart';

/// Card widget displaying goal progress with visual indicator
class GoalProgressCard extends StatelessWidget {
  final ProgressGoal goal;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = goal.progressPercentage / 100;
    final isCompleted = goal.status == GoalStatus.completed;
    final isOverdue = goal.isOverdue;

    Color getStatusColor() {
      if (isCompleted) return Colors.green;
      if (isOverdue) return Colors.red;
      if (progress >= 0.75) return colorScheme.tertiary;
      if (progress >= 0.5) return colorScheme.primary;
      return colorScheme.secondary;
    }

    IconData getGoalIcon() {
      switch (goal.type) {
        case GoalType.weight:
          return Icons.monitor_weight;
        case GoalType.measurement:
          return Icons.straighten;
        case GoalType.custom:
          return Icons.star;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: getStatusColor().withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Goal Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    getGoalIcon(),
                    color: getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Goal Title & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.type.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Overdue',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.getProgressDisplay(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: getStatusColor(),
                          ),
                    ),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Goal Details Row
            Row(
              children: [
                // Start Date
                Expanded(
                  child: _buildDetailChip(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Started',
                    value: DateFormat('MMM d').format(goal.startDate),
                  ),
                ),
                const SizedBox(width: 8),
                // Target Date or Days Remaining
                if (goal.targetDate != null)
                  Expanded(
                    child: _buildDetailChip(
                      context,
                      icon: isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.flag,
                      label: isOverdue
                          ? 'Overdue'
                          : '${goal.daysRemaining} days',
                      value: DateFormat('MMM d').format(goal.targetDate!),
                      color: isOverdue ? Colors.red : null,
                    ),
                  )
                else
                  Expanded(
                    child: _buildDetailChip(
                      context,
                      icon: Icons.all_inclusive,
                      label: 'Duration',
                      value: '${goal.daysSinceStart} days',
                    ),
                  ),
              ],
            ),

            // Notes (if any)
            if (goal.notes != null && goal.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: chipColor,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: chipColor,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
