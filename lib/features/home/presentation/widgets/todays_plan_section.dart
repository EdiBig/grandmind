import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Collapsible Today's Plan section
class TodaysPlanSection extends StatefulWidget {
  final List<PlanTask> tasks;
  final bool initiallyExpanded;
  final Function(PlanTask task)? onTaskToggle;
  final Function(PlanTask task)? onTaskTap;

  const TodaysPlanSection({
    super.key,
    required this.tasks,
    this.initiallyExpanded = false,
    this.onTaskToggle,
    this.onTaskTap,
  });

  @override
  State<TodaysPlanSection> createState() => _TodaysPlanSectionState();
}

class _TodaysPlanSectionState extends State<TodaysPlanSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;
    final totalCount = widget.tasks.length;
    final spacing = context.spacing;
    final textStyles = context.textStyles;
    final sizes = context.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        GestureDetector(
          onTap: _toggleExpanded,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
            child: Row(
              children: [
                Text(
                  "Today's Plan",
                  style: TextStyle(
                    fontSize: textStyles.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount of $totalCount',
                    style: TextStyle(
                      fontSize: textStyles.labelSmall,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colors.textSecondary,
                    size: sizes.iconLarge,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tasks list (animated)
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            children: [
              SizedBox(height: spacing.md),
              ...widget.tasks.map((task) => _TaskRow(
                    task: task,
                    onToggle: () => widget.onTaskToggle?.call(task),
                    onTap: () => widget.onTaskTap?.call(task),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final PlanTask task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const _TaskRow({
    required this.task,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final sizes = context.sizes;
    final textStyles = context.textStyles;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.screenPadding,
        vertical: spacing.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(sizes.cardBorderRadius * 0.6),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onToggle?.call();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: sizes.iconLarge,
                  height: sizes.iconLarge,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.success
                          : context.colors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: sizes.iconSmall,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: spacing.md),

              // Task title
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: textStyles.bodyMedium,
                    color: task.isCompleted
                        ? context.colors.textSecondary
                        : context.colors.textPrimary,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),

              // Status/Progress
              if (task.isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: textStyles.labelSmall,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (task.progress != null)
                _buildProgressIndicator(context, task)
              else if (task.isActionable)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          fontSize: textStyles.labelSmall,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: spacing.xs / 2),
                      Icon(
                        Icons.arrow_forward,
                        size: sizes.iconSmall * 0.75,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, PlanTask task) {
    final progress = task.progress!;
    final current = progress['current'] as int? ?? 0;
    final target = progress['target'] as int? ?? 1;
    final progressValue = (current / target).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$current/$target',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Task data model for today's plan
class PlanTask {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isActionable;
  final Map<String, dynamic>? progress;
  final String? route;

  const PlanTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isActionable = false,
    this.progress,
    this.route,
  });

  PlanTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    bool? isActionable,
    Map<String, dynamic>? progress,
    String? route,
  }) {
    return PlanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isActionable: isActionable ?? this.isActionable,
      progress: progress ?? this.progress,
      route: route ?? this.route,
    );
  }
}
