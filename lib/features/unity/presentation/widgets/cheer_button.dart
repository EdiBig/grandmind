import 'package:flutter/material.dart';

/// Button to send a cheer with animated icon and count display
///
/// Opens a cheer selector bottom sheet on tap.
class CheerButton extends StatefulWidget {
  const CheerButton({
    super.key,
    required this.cheerCount,
    this.hasUserCheered = false,
    required this.onTap,
    this.size = CheerButtonSize.medium,
    this.showCount = true,
  });

  /// Total number of cheers received
  final int cheerCount;

  /// Whether the current user has already cheered
  final bool hasUserCheered;

  /// Callback when button is tapped
  final VoidCallback onTap;

  /// Size variant of the button
  final CheerButtonSize size;

  /// Whether to show the count
  final bool showCount;

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CheerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cheerCount > oldWidget.cheerCount) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.forward().then((_) => _controller.reverse());
  }

  void _handleTap() {
    _playAnimation();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = _getIconSize();
    final fontSize = _getFontSize();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.showCount ? 12 : 8,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  widget.hasUserCheered
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: iconSize,
                  color: widget.hasUserCheered
                      ? Colors.red
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (widget.showCount && widget.cheerCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  _formatCount(widget.cheerCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize,
                    color: widget.hasUserCheered
                        ? Colors.red
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _getIconSize() {
    switch (widget.size) {
      case CheerButtonSize.small:
        return 16;
      case CheerButtonSize.medium:
        return 20;
      case CheerButtonSize.large:
        return 24;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CheerButtonSize.small:
        return 11;
      case CheerButtonSize.medium:
        return 13;
      case CheerButtonSize.large:
        return 15;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

enum CheerButtonSize { small, medium, large }

/// Extended cheer button with label
class CheerButtonExtended extends StatelessWidget {
  const CheerButtonExtended({
    super.key,
    required this.cheerCount,
    this.hasUserCheered = false,
    required this.onTap,
    this.label = 'Cheer',
  });

  final int cheerCount;
  final bool hasUserCheered;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: hasUserCheered
            ? Colors.red.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: hasUserCheered
            ? Colors.red
            : theme.colorScheme.onSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUserCheered ? Icons.favorite : Icons.favorite_border,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            cheerCount > 0 ? '$label ($cheerCount)' : label,
          ),
        ],
      ),
    );
  }
}

/// Floating action button style cheer button
class CheerFab extends StatefulWidget {
  const CheerFab({
    super.key,
    required this.onTap,
    this.cheerCount = 0,
    this.hasUserCheered = false,
  });

  final VoidCallback onTap;
  final int cheerCount;
  final bool hasUserCheered;

  @override
  State<CheerFab> createState() => _CheerFabState();
}

class _CheerFabState extends State<CheerFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _handleTap,
        backgroundColor:
            widget.hasUserCheered ? Colors.red : null,
        foregroundColor:
            widget.hasUserCheered ? Colors.white : null,
        icon: Icon(
          widget.hasUserCheered ? Icons.favorite : Icons.favorite_border,
        ),
        label: Text(
          widget.cheerCount > 0 ? 'Cheer (${widget.cheerCount})' : 'Cheer',
        ),
      ),
    );
  }
}
