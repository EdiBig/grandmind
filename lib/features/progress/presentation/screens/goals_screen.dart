import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/progress_goal.dart';
import '../providers/progress_providers.dart';
import 'create_goal_screen.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(activeGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeGoalsProvider);
        },
        child: goalsAsync.when(
          data: (goals) {
            final activeGoals = goals.where((g) => g.status == GoalStatus.active).toList();
            final completedGoals = goals.where((g) => g.status == GoalStatus.completed).toList();

            if (activeGoals.isEmpty && completedGoals.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Active Goals Section
                if (activeGoals.isNotEmpty) ...[
                  Text(
                    'Active Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...activeGoals.map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildGoalCard(context, goal),
                      )),
                ],

                // Completed Goals Section
                if (completedGoals.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Completed Goals (${completedGoals.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    trailing: Icon(
                      _showCompleted
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        _showCompleted = !_showCompleted;
                      });
                    },
                  ),
                  if (_showCompleted)
                    ...completedGoals.map((goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGoalCard(context, goal),
                        )),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading goals'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(activeGoalsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGoalScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, ProgressGoal goal) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = goal.status == GoalStatus.completed;
    final cardColor = isCompleted
        ? Colors.green.withValues(alpha: 0.1)
        : Theme.of(context).cardColor;

    Color progressColor;
    switch (goal.type) {
      case GoalType.weight:
        progressColor = colorScheme.primary;
        break;
      case GoalType.measurement:
        progressColor = colorScheme.secondary;
        break;
      case GoalType.custom:
        progressColor = colorScheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.type.displayName,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (goal.isOverdue)
                const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (!isCompleted)
                    const PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Mark Complete'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'complete') {
                    _completeGoal(goal.id);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, goal);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            goal.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Progress Values
          Row(
            children: [
              Text(
                goal.getProgressDisplay(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const Spacer(),
              Text(
                '${goal.progressPercentage.toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          const SizedBox(height: 12),

          // Footer Info
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Started ${DateFormat('MMM d, yyyy').format(goal.startDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (goal.targetDate != null) ...[
                const Spacer(),
                Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  goal.daysRemaining != null && goal.daysRemaining! > 0
                      ? '${goal.daysRemaining} days left'
                      : goal.isOverdue
                          ? 'Overdue'
                          : 'Due today',
                  style: TextStyle(
                    fontSize: 12,
                    color: goal.isOverdue ? Colors.orange : Colors.grey[600],
                    fontWeight:
                        goal.isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),

          // Notes
          if (goal.notes != null && goal.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.notes!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Goals Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set goals to track your progress',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateGoalScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create First Goal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeGoal(String goalId) async {
    final operations = ref.read(progressOperationsProvider.notifier);
    final success = await operations.completeGoal(goalId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete goal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, ProgressGoal goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final operations = ref.read(progressOperationsProvider.notifier);
              final success = await operations.deleteGoal(goal.id);

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Goal deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete goal'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Goals'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎯 Goal Types:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Weight Goal: Track weight loss or gain'),
              Text('• Measurement Goal: Track body measurements'),
              Text('• Custom Goal: Track any other metric'),
              SizedBox(height: 16),
              Text('📊 Auto-Updates:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Goals automatically update when you:'),
              Text('• Log your weight'),
              Text('• Record body measurements'),
              SizedBox(height: 16),
              Text('✅ Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Set realistic target dates'),
              Text('• Track progress regularly'),
              Text('• Celebrate small wins'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
