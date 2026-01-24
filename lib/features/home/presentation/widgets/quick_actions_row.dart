import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Horizontal scrollable quick actions row
class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsRow({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final textStyles = context.textStyles;
    final sizes = context.sizes;

    // Quick action height based on button size
    final actionHeight = sizes.quickActionSize + 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: textStyles.titleMedium,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        SizedBox(
          height: actionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
            itemCount: actions.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing.md),
            itemBuilder: (context, index) {
              return _QuickActionCard(action: actions[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final spacing = context.spacing;
    final textStyles = context.textStyles;

    final actionSize = sizes.quickActionSize;
    final iconSize = sizes.quickActionIconSize;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.action.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: actionSize,
          padding: EdgeInsets.symmetric(
            vertical: spacing.sm + 2,
            horizontal: spacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.action.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(sizes.cardBorderRadius * 0.8),
            boxShadow: [
              BoxShadow(
                color: widget.action.gradientColors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.action.icon != null
                  ? Icon(
                      widget.action.icon,
                      color: Colors.white,
                      size: iconSize,
                    )
                  : Text(
                      widget.action.emoji ?? '',
                      style: TextStyle(fontSize: iconSize * 0.85),
                    ),
              SizedBox(height: spacing.xs),
              Text(
                widget.action.label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: textStyles.labelSmall * 0.9,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action data model
class QuickAction {
  final String label;
  final IconData? icon;
  final String? emoji;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const QuickAction({
    required this.label,
    this.icon,
    this.emoji,
    required this.gradientColors,
    this.onTap,
  });

  // Pre-defined quick actions
  static QuickAction logWorkout(VoidCallback? onTap) => QuickAction(
        label: 'Log',
        icon: Icons.add,
        gradientColors: const [Color(0xFF14B8A6), Color(0xFF0D9488)],
        onTap: onTap,
      );

  static QuickAction aiCoach(VoidCallback? onTap) => QuickAction(
        label: 'Coach',
        emoji: '🤖',
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        onTap: onTap,
      );

  static QuickAction planWeek(VoidCallback? onTap) => QuickAction(
        label: 'Plan',
        emoji: '📅',
        gradientColors: const [Color(0xFFFB923C), Color(0xFFEA580C)],
        onTap: onTap,
      );

  static QuickAction unity(VoidCallback? onTap) => QuickAction(
        label: 'Unity',
        emoji: '🏆',
        gradientColors: const [Color(0xFFFBBF24), Color(0xFFD97706)],
        onTap: onTap,
      );

  static QuickAction checkIn(VoidCallback? onTap) => QuickAction(
        label: 'Check-In',
        icon: Icons.check,
        gradientColors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
        onTap: onTap,
      );

  static QuickAction health(VoidCallback? onTap) => QuickAction(
        label: 'Health',
        icon: Icons.favorite,
        gradientColors: const [Color(0xFFF87171), Color(0xFFEF4444)],
        onTap: onTap,
      );

  static QuickAction progress(VoidCallback? onTap) => QuickAction(
        label: 'Progress',
        icon: Icons.show_chart,
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
        onTap: onTap,
      );
}
