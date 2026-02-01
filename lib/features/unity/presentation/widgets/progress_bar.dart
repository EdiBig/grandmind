import 'package:flutter/material.dart';

/// Styled progress bar for Unity feature
///
/// A customizable animated progress bar with optional percentage label.
class UnityProgressBar extends StatelessWidget {
  const UnityProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor,
    this.foregroundColor,
    this.showPercentage = false,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.borderRadius,
    this.gradient,
  }) : assert(progress >= 0 && progress <= 1,
            'Progress must be between 0 and 1');

  /// Progress value between 0 and 1
  final double progress;

  /// Height of the progress bar
  final double height;

  /// Background color of the unfilled portion
  final Color? backgroundColor;

  /// Foreground color of the filled portion (ignored if gradient is set)
  final Color? foregroundColor;

  /// Whether to show percentage label
  final bool showPercentage;

  /// Whether to animate progress changes
  final bool animate;

  /// Duration of the animation
  final Duration animationDuration;

  /// Border radius of the progress bar
  final BorderRadius? borderRadius;

  /// Optional gradient for the filled portion
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.primary;

    if (showPercentage) {
      return Row(
        children: [
          Expanded(
            child: _buildProgressBar(
              effectiveBorderRadius,
              effectiveBackgroundColor,
              effectiveForegroundColor,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    }

    return _buildProgressBar(
      effectiveBorderRadius,
      effectiveBackgroundColor,
      effectiveForegroundColor,
    );
  }

  Widget _buildProgressBar(
    BorderRadius borderRadius,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
            ),
            // Foreground (progress)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * progress.clamp(0.0, 1.0);
                return AnimatedContainer(
                  duration: animate ? animationDuration : Duration.zero,
                  curve: Curves.easeInOut,
                  width: width,
                  decoration: BoxDecoration(
                    color: gradient == null ? foregroundColor : null,
                    gradient: gradient,
                    borderRadius: borderRadius,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A segmented progress bar showing multiple milestones
class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    super.key,
    required this.progress,
    required this.segments,
    this.height = 8.0,
    this.backgroundColor,
    this.activeColor,
    this.completedColor,
    this.segmentGap = 2.0,
  });

  /// Current progress value between 0 and 1
  final double progress;

  /// Number of segments
  final int segments;

  /// Height of the progress bar
  final double height;

  /// Background color
  final Color? backgroundColor;

  /// Color for the active segment
  final Color? activeColor;

  /// Color for completed segments
  final Color? completedColor;

  /// Gap between segments
  final double segmentGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveCompletedColor =
        completedColor ?? theme.colorScheme.primary;

    final currentSegment = (progress * segments).floor();
    final segmentProgress = (progress * segments) - currentSegment;

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(segments, (index) {
          final isCompleted = index < currentSegment;
          final isActive = index == currentSegment;
          final segmentFill = isCompleted
              ? 1.0
              : (isActive ? segmentProgress : 0.0);

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < segments - 1 ? segmentGap : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: Stack(
                  children: [
                    Container(color: effectiveBackgroundColor),
                    FractionallySizedBox(
                      widthFactor: segmentFill,
                      child: Container(
                        color: isCompleted
                            ? effectiveCompletedColor
                            : effectiveActiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
