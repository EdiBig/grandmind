import 'package:flutter/material.dart';

/// Toggle widget for anonymous participation (Whisper Mode)
///
/// Shows a switch with label, explanation text, and privacy icon.
class WhisperModeToggle extends StatelessWidget {
  const WhisperModeToggle({
    super.key,
    required this.isEnabled,
    required this.onChanged,
    this.showExplanation = true,
    this.compact = false,
  });

  /// Whether whisper mode is currently enabled
  final bool isEnabled;

  /// Callback when toggle is changed
  final ValueChanged<bool> onChanged;

  /// Whether to show explanation text
  final bool showExplanation;

  /// Whether to use compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEnabled ? Icons.visibility_off : Icons.visibility,
                  color: isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Label and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Whisper Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isEnabled ? 'Active' : 'Inactive',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        fontWeight: isEnabled ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Switch
              Switch(
                value: isEnabled,
                onChanged: onChanged,
              ),
            ],
          ),

          if (showExplanation) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildExplanation(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          isEnabled ? Icons.visibility_off : Icons.visibility,
          size: 20,
          color: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Whisper Mode',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildExplanation(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _ExplanationItem(
          icon: Icons.person_off,
          text: 'Your name appears as "Anonymous"',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _ExplanationItem(
          icon: Icons.hide_image,
          text: 'Your avatar is hidden',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _ExplanationItem(
          icon: Icons.bar_chart,
          text: 'Your progress is still tracked and visible',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _ExplanationItem(
          icon: Icons.favorite,
          text: 'You can still send and receive cheers',
          theme: theme,
        ),
      ],
    );
  }
}

class _ExplanationItem extends StatelessWidget {
  const _ExplanationItem({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Whisper mode indicator badge
class WhisperModeBadge extends StatelessWidget {
  const WhisperModeBadge({
    super.key,
    this.size = WhisperModeBadgeSize.medium,
  });

  final WhisperModeBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getPaddingH(),
        vertical: _getPaddingV(),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off,
            size: _getIconSize(),
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: _getSpacing()),
          Text(
            'Whisper Mode',
            style: _getTextStyle(theme),
          ),
        ],
      ),
    );
  }

  double _getPaddingH() {
    switch (size) {
      case WhisperModeBadgeSize.small:
        return 6;
      case WhisperModeBadgeSize.medium:
        return 10;
      case WhisperModeBadgeSize.large:
        return 14;
    }
  }

  double _getPaddingV() {
    switch (size) {
      case WhisperModeBadgeSize.small:
        return 2;
      case WhisperModeBadgeSize.medium:
        return 4;
      case WhisperModeBadgeSize.large:
        return 6;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case WhisperModeBadgeSize.small:
        return 6;
      case WhisperModeBadgeSize.medium:
        return 8;
      case WhisperModeBadgeSize.large:
        return 10;
    }
  }

  double _getIconSize() {
    switch (size) {
      case WhisperModeBadgeSize.small:
        return 12;
      case WhisperModeBadgeSize.medium:
        return 14;
      case WhisperModeBadgeSize.large:
        return 18;
    }
  }

  double _getSpacing() {
    switch (size) {
      case WhisperModeBadgeSize.small:
        return 4;
      case WhisperModeBadgeSize.medium:
        return 6;
      case WhisperModeBadgeSize.large:
        return 8;
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    final baseStyle = switch (size) {
      WhisperModeBadgeSize.small => theme.textTheme.labelSmall,
      WhisperModeBadgeSize.medium => theme.textTheme.labelMedium,
      WhisperModeBadgeSize.large => theme.textTheme.labelLarge,
    };

    return baseStyle?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

enum WhisperModeBadgeSize { small, medium, large }
