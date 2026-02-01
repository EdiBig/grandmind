import 'package:flutter/material.dart';

/// Non-ranked member progress visualization
///
/// Shows visual bars without exact numbers, with encouraging labels
/// instead of competitive rankings. Supports anonymous mode.
class ProgressPortrait extends StatelessWidget {
  const ProgressPortrait({
    super.key,
    required this.progress,
    this.displayName,
    this.avatarUrl,
    this.isAnonymous = false,
    this.showLabel = true,
    this.onTap,
  });

  /// Progress value between 0 and 1
  final double progress;

  /// Display name (ignored if anonymous)
  final String? displayName;

  /// Avatar URL (ignored if anonymous)
  final String? avatarUrl;

  /// Whether to show as anonymous
  final bool isAnonymous;

  /// Whether to show the progress label
  final bool showLabel;

  /// Callback when tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _getProgressLabel();
    final color = _getProgressColor(theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(context),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    isAnonymous ? 'Anonymous' : (displayName ?? 'Member'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Progress bar
                  _buildProgressBar(context, color),

                  if (showLabel) ...[
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const size = 44.0;

    if (isAnonymous) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.person_outline,
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
      );
    }

    if (avatarUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        displayName != null && displayName!.isNotEmpty
            ? displayName![0].toUpperCase()
            : '?',
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Color color) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressLabel() {
    if (progress >= 1.0) {
      return 'Completed!';
    } else if (progress >= 0.9) {
      return 'Almost there!';
    } else if (progress >= 0.75) {
      return 'Leading';
    } else if (progress >= 0.5) {
      return 'Cruising';
    } else if (progress >= 0.25) {
      return 'Building momentum';
    } else if (progress > 0) {
      return 'Getting started';
    } else {
      return 'Catching up';
    }
  }

  Color _getProgressColor(ThemeData theme) {
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.75) {
      return theme.colorScheme.primary;
    } else if (progress >= 0.5) {
      return Colors.blue;
    } else if (progress >= 0.25) {
      return Colors.orange;
    } else {
      return theme.colorScheme.secondary;
    }
  }
}

/// A compact progress portrait for lists
class ProgressPortraitCompact extends StatelessWidget {
  const ProgressPortraitCompact({
    super.key,
    required this.progress,
    this.displayName,
    this.avatarUrl,
    this.isAnonymous = false,
    this.onTap,
  });

  final double progress;
  final String? displayName;
  final String? avatarUrl;
  final bool isAnonymous;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Avatar with progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 3,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 1.0
                        ? Colors.green
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              // Avatar
              _buildAvatar(context),
            ],
          ),
          const SizedBox(height: 6),

          // Name
          SizedBox(
            width: 64,
            child: Text(
              isAnonymous ? 'Anon' : (displayName ?? 'Member'),
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const size = 40.0;

    if (isAnonymous) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.person_outline,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      );
    }

    if (avatarUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        displayName != null && displayName!.isNotEmpty
            ? displayName![0].toUpperCase()
            : '?',
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
