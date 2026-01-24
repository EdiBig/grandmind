import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/responsive/responsive.dart';

/// Bento-style metrics grid with large and small cards
class BentoMetricsGrid extends StatelessWidget {
  final double sleepHours;
  final int energyLevel;
  final int steps;
  final int? heartRate;
  final int habitsCompleted;
  final int totalHabits;
  final int workoutsThisWeek;
  final double? sleepDelta; // compared to average
  final VoidCallback? onSleepTap;
  final VoidCallback? onEnergyTap;
  final VoidCallback? onStepsTap;
  final VoidCallback? onHeartTap;
  final VoidCallback? onHabitsTap;
  final VoidCallback? onWorkoutsTap;

  const BentoMetricsGrid({
    super.key,
    required this.sleepHours,
    required this.energyLevel,
    required this.steps,
    this.heartRate,
    required this.habitsCompleted,
    required this.totalHabits,
    required this.workoutsThisWeek,
    this.sleepDelta,
    this.onSleepTap,
    this.onEnergyTap,
    this.onStepsTap,
    this.onHeartTap,
    this.onHabitsTap,
    this.onWorkoutsTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final sizes = context.sizes;
    final responsive = context.responsive;

    // On larger screens, show more columns
    final gridSpacing = spacing.gridSpacing;

    return Column(
      children: [
        // Large cards row (Sleep + Energy)
        Row(
          children: [
            Expanded(
              child: _LargeMetricCard(
                icon: '🌙',
                label: 'Sleep',
                value: '${sleepHours.toStringAsFixed(1)}h',
                progress: sleepHours / 8,
                delta: sleepDelta,
                color: const Color(0xFFA78BFA),
                onTap: onSleepTap,
                minHeight: sizes.bentoCardMinHeight,
              ),
            ),
            SizedBox(width: gridSpacing),
            Expanded(
              child: _LargeMetricCard(
                icon: '⚡',
                label: 'Energy',
                value: '$energyLevel/5',
                progress: energyLevel / 5,
                subtitle: _getEnergyLabel(energyLevel),
                color: const Color(0xFFFBBF24),
                onTap: onEnergyTap,
                minHeight: sizes.bentoCardMinHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: gridSpacing),
        // Small cards row - wrap on very small screens
        responsive.isMobileSmall
            ? _buildSmallCardsWrap(context, gridSpacing)
            : _buildSmallCardsRow(context, gridSpacing),
      ],
    );
  }

  Widget _buildSmallCardsRow(BuildContext context, double gridSpacing) {
    return Row(
      children: [
        Expanded(
          child: _SmallMetricCard(
            icon: '🚶',
            label: 'Steps',
            value: _formatNumber(steps),
            color: const Color(0xFF60A5FA),
            onTap: onStepsTap,
          ),
        ),
        SizedBox(width: gridSpacing),
        Expanded(
          child: _SmallMetricCard(
            icon: '❤️',
            label: 'Heart',
            value: heartRate != null ? '${heartRate}bpm' : '--',
            color: const Color(0xFFF87171),
            onTap: onHeartTap,
          ),
        ),
        SizedBox(width: gridSpacing),
        Expanded(
          child: _SmallMetricCard(
            icon: '✓',
            label: 'Habits',
            value: '$habitsCompleted/$totalHabits',
            color: const Color(0xFF4ADE80),
            onTap: onHabitsTap,
          ),
        ),
        SizedBox(width: gridSpacing),
        Expanded(
          child: _SmallMetricCard(
            icon: '💪',
            label: 'Workout',
            value: '$workoutsThisWeek',
            color: const Color(0xFFFB923C),
            onTap: onWorkoutsTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCardsWrap(BuildContext context, double gridSpacing) {
    // Two rows of two cards for very small screens
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: '🚶',
                label: 'Steps',
                value: _formatNumber(steps),
                color: const Color(0xFF60A5FA),
                onTap: onStepsTap,
              ),
            ),
            SizedBox(width: gridSpacing),
            Expanded(
              child: _SmallMetricCard(
                icon: '❤️',
                label: 'Heart',
                value: heartRate != null ? '${heartRate}bpm' : '--',
                color: const Color(0xFFF87171),
                onTap: onHeartTap,
              ),
            ),
          ],
        ),
        SizedBox(height: gridSpacing),
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: '✓',
                label: 'Habits',
                value: '$habitsCompleted/$totalHabits',
                color: const Color(0xFF4ADE80),
                onTap: onHabitsTap,
              ),
            ),
            SizedBox(width: gridSpacing),
            Expanded(
              child: _SmallMetricCard(
                icon: '💪',
                label: 'Workout',
                value: '$workoutsThisWeek',
                color: const Color(0xFFFB923C),
                onTap: onWorkoutsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getEnergyLabel(int level) {
    switch (level) {
      case 1:
        return 'Exhausted';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'Energized';
      case 5:
        return 'Peak';
      default:
        return '--';
    }
  }

  String _formatNumber(int value) {
    return NumberFormat.compact().format(value);
  }
}

/// Large metric card for primary metrics (Sleep, Energy)
class _LargeMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final double progress;
  final double? delta;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final double? minHeight;

  const _LargeMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    this.delta,
    this.subtitle,
    required this.color,
    this.onTap,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final spacing = context.spacing;
    final textStyles = context.textStyles;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: minHeight != null
            ? BoxConstraints(minHeight: minHeight!)
            : null,
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: TextStyle(fontSize: sizes.iconMedium)),
                SizedBox(width: spacing.sm),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: textStyles.bodySmall,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Text(
              value,
              style: TextStyle(
                fontSize: textStyles.headlineMedium,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing.sm),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            SizedBox(height: spacing.sm),
            if (delta != null)
              Row(
                children: [
                  Icon(
                    delta! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: sizes.iconSmall,
                    color: delta! >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                  SizedBox(width: spacing.xs),
                  Text(
                    '${delta!.abs().toStringAsFixed(0)}min from avg',
                    style: TextStyle(
                      fontSize: textStyles.labelSmall,
                      color: delta! >= 0
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              )
            else if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: textStyles.labelSmall,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small metric card for secondary metrics
class _SmallMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _SmallMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final spacing = context.spacing;
    final textStyles = context.textStyles;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing.md,
          horizontal: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius * 0.8),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: sizes.iconLarge)),
            SizedBox(height: spacing.xs + 2),
            Text(
              value,
              style: TextStyle(
                fontSize: textStyles.titleMedium,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing.xs / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: textStyles.labelSmall,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
