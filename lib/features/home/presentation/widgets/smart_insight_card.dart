import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Smart insight card that provides AI-powered actionable suggestions
class SmartInsightCard extends StatefulWidget {
  final SmartInsight insight;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SmartInsightCard({
    super.key,
    required this.insight,
    this.onDismiss,
    this.onAction,
  });

  @override
  State<SmartInsightCard> createState() => _SmartInsightCardState();
}

class _SmartInsightCardState extends State<SmartInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    HapticFeedback.lightImpact();
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final sizes = context.sizes;
    final textStyles = context.textStyles;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
          padding: EdgeInsets.all(spacing.cardPadding),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.insight.icon,
                    style: TextStyle(fontSize: sizes.iconLarge),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.insight.title,
                          style: TextStyle(
                            fontSize: textStyles.titleSmall,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          widget.insight.message,
                          style: TextStyle(
                            fontSize: textStyles.bodySmall,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleDismiss,
                    child: Icon(
                      Icons.close,
                      size: sizes.iconMedium * 0.9,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              if (widget.insight.actionLabel != null) ...[
                SizedBox(height: spacing.md),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        widget.onAction?.call();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.lg,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.insight.actionLabel!,
                              style: TextStyle(
                                fontSize: textStyles.labelMedium,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            SizedBox(width: spacing.xs),
                            Icon(
                              Icons.arrow_forward,
                              size: sizes.iconSmall * 0.9,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    GestureDetector(
                      onTap: _handleDismiss,
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: textStyles.labelMedium,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Model for smart insights
class SmartInsight {
  final String icon;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionRoute;
  final InsightType type;

  const SmartInsight({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionRoute,
    this.type = InsightType.general,
  });
}

enum InsightType {
  recovery,
  sleep,
  workout,
  streak,
  stress,
  energy,
  milestone,
  challenge,
  general,
}

/// Generates smart insights based on user data
class InsightGenerator {
  static SmartInsight? generateInsight({
    required double sleepHours,
    required int energyLevel,
    required int workoutsThisWeek,
    required int currentStreak,
    required int habitsCompleted,
    required int totalHabits,
    required int readinessScore,
  }) {
    // Priority-based insight generation
    // Note: sleepHours == 0 means no data available, not zero sleep
    final hasSleepData = sleepHours > 0;

    // Good recovery + high energy (only if we have sleep data)
    if (hasSleepData && sleepHours >= 7 && energyLevel >= 4 && readinessScore >= 70) {
      return const SmartInsight(
        icon: '💪',
        title: 'Great recovery!',
        message: 'Your sleep and energy are excellent. Perfect time for a challenging workout.',
        actionLabel: 'Start Workout',
        actionRoute: '/workouts',
        type: InsightType.recovery,
      );
    }

    // Poor sleep (only if we have actual sleep data, not just missing data)
    if (hasSleepData && sleepHours < 6) {
      return SmartInsight(
        icon: '😴',
        title: 'Only ${sleepHours.toStringAsFixed(1)}h sleep',
        message: 'Consider a gentler workout today. Your body needs recovery time.',
        actionLabel: 'Light Workouts',
        actionRoute: '/workouts',
        type: InsightType.sleep,
      );
    }

    // No sleep data - encourage tracking
    if (!hasSleepData) {
      return const SmartInsight(
        icon: '🌙',
        title: 'Track your sleep',
        message: 'Connect a health app or log manually to get personalised recovery insights.',
        actionLabel: 'Health Settings',
        actionRoute: '/settings/health-sync',
        type: InsightType.sleep,
      );
    }

    // Workout streak
    if (currentStreak >= 3) {
      return SmartInsight(
        icon: '🔥',
        title: '$currentStreak day streak!',
        message: 'Amazing consistency! Consider a rest day to prevent burnout.',
        actionLabel: 'Schedule Rest',
        actionRoute: '/plan',
        type: InsightType.streak,
      );
    }

    // Low energy
    if (energyLevel <= 2) {
      return const SmartInsight(
        icon: '⚡',
        title: 'Low energy detected',
        message: 'Hydration and light movement can help boost your energy levels.',
        actionLabel: 'Log Water',
        actionRoute: '/habits',
        type: InsightType.energy,
      );
    }

    // High habits completion
    if (totalHabits > 0 && habitsCompleted == totalHabits) {
      return const SmartInsight(
        icon: '✨',
        title: 'All habits complete!',
        message: "You're crushing it today. Keep up the momentum!",
        type: InsightType.general,
      );
    }

    // Workouts this week
    if (workoutsThisWeek == 0) {
      return const SmartInsight(
        icon: '🏃',
        title: 'Ready to move?',
        message: 'No workouts logged yet this week. Even 10 minutes helps!',
        actionLabel: 'Quick Workout',
        actionRoute: '/workouts',
        type: InsightType.workout,
      );
    }

    // Default insight
    return const SmartInsight(
      icon: '💡',
      title: 'Tip of the day',
      message: 'Small consistent actions lead to big results. You got this!',
      type: InsightType.general,
    );
  }
}
