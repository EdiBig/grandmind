import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Animated readiness ring - the hero element of the home screen
class ReadinessRing extends StatefulWidget {
  final int score; // 0-100
  final String? userName;
  final VoidCallback? onTap;

  const ReadinessRing({
    super.key,
    required this.score,
    this.userName,
    this.onTap,
  });

  @override
  State<ReadinessRing> createState() => _ReadinessRingState();
}

class _ReadinessRingState extends State<ReadinessRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<int> _countAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _countAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(ReadinessRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _setupAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score <= 30) return AppColors.readinessLow;
    if (score <= 50) return AppColors.readinessModerate;
    if (score <= 70) return AppColors.readinessFair;
    if (score <= 85) return AppColors.readinessGood;
    return AppColors.readinessPeak;
  }

  String _getReadinessLabel(int score) {
    if (score <= 30) return "Rest Day";
    if (score <= 50) return "Take It Easy";
    if (score <= 70) return "Moderate";
    if (score <= 85) return "Good to Go";
    return "Peak Ready";
  }

  String _getGreeting(int score) {
    final hour = DateTime.now().hour;
    final name = widget.userName ?? 'there';

    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    return '$timeGreeting, $name!';
  }

  String _getSubGreeting(int score) {
    if (score <= 30) {
      return "Recovery day might be wise today.";
    } else if (score <= 50) {
      return "Listen to your body today.";
    } else if (score <= 70) {
      return "Steady energy for a balanced day.";
    } else if (score <= 85) {
      return "You're recovered and ready to move.";
    }
    return "You're primed for a great workout!";
  }

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final textStyles = context.textStyles;
    final spacing = context.spacing;

    final ringSize = sizes.readinessRingSize;
    final strokeWidth = sizes.readinessRingStroke;
    final glowSize = ringSize - 20;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final color = _getScoreColor(_countAnimation.value);

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The Ring
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      Container(
                        width: glowSize,
                        height: glowSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Background ring
                      CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _RingPainter(
                          progress: 1.0,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          strokeWidth: strokeWidth,
                        ),
                      ),
                      // Progress ring
                      CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _RingPainter(
                          progress: _progressAnimation.value,
                          color: color,
                          strokeWidth: strokeWidth,
                        ),
                      ),
                      // Score text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_countAnimation.value}',
                            style: TextStyle(
                              fontSize: textStyles.displaySmall,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          Text(
                            _getReadinessLabel(_countAnimation.value),
                            style: TextStyle(
                              fontSize: textStyles.labelMedium,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.xl),
                // Greeting
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
                  child: Text(
                    _getGreeting(_countAnimation.value),
                    style: TextStyle(
                      fontSize: textStyles.titleLarge,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
                  child: Text(
                    _getSubGreeting(_countAnimation.value),
                    style: TextStyle(
                      fontSize: textStyles.bodyMedium,
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc (starting from top, -90 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
