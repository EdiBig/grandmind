import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Card widget for displaying a Circle in lists
///
/// Shows avatar, name, description, member count, active challenges,
/// and visibility indicator.
class CircleCard extends StatelessWidget {
  const CircleCard({
    super.key,
    required this.circle,
    this.onTap,
    this.showVisibility = true,
    this.showActiveChallenges = true,
  });

  /// The Circle to display
  final Circle circle;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Whether to show visibility indicator
  final bool showVisibility;

  /// Whether to show active challenges count
  final bool showActiveChallenges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(context),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and visibility
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            circle.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showVisibility) _buildVisibilityIcon(context),
                      ],
                    ),

                    // Description
                    if (circle.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        circle.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Stats row
                    Row(
                      children: [
                        // Member count
                        _buildStatChip(
                          context,
                          Icons.people_outline,
                          '${circle.memberCount} ${circle.memberCount == 1 ? 'member' : 'members'}',
                        ),
                        const SizedBox(width: 12),

                        // Active challenges
                        if (showActiveChallenges &&
                            circle.activeChallengeCount > 0)
                          _buildStatChip(
                            context,
                            Icons.emoji_events_outlined,
                            '${circle.activeChallengeCount} active',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const size = 56.0;

    if (circle.avatarUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(circle.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Default avatar with gradient and icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _getGradientColors(theme, circle.id),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getCircleTypeIcon(circle.type),
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildVisibilityIcon(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    String tooltip;

    switch (circle.visibility) {
      case CircleVisibility.private:
        icon = Icons.lock_outline;
        tooltip = 'Private';
        break;
      case CircleVisibility.inviteOnly:
        icon = Icons.mail_outline;
        tooltip = 'Invite only';
        break;
      case CircleVisibility.public:
        icon = Icons.public;
        tooltip = 'Public';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 16,
        color: theme.colorScheme.outline,
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  IconData _getCircleTypeIcon(CircleType type) {
    switch (type) {
      case CircleType.duo:
        return Icons.people;
      case CircleType.squad:
        return Icons.groups;
      case CircleType.crew:
        return Icons.diversity_3;
      case CircleType.community:
        return Icons.public;
    }
  }

  List<Color> _getGradientColors(ThemeData theme, String id) {
    final hash = id.hashCode;
    final hue1 = (hash % 360).toDouble();
    final hue2 = ((hash ~/ 360) % 360).toDouble();

    return [
      HSLColor.fromAHSL(1.0, hue1, 0.6, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, hue2, 0.6, 0.4).toColor(),
    ];
  }
}

/// Compact circle card for horizontal lists
class CircleCardCompact extends StatelessWidget {
  const CircleCardCompact({
    super.key,
    required this.circle,
    this.onTap,
    this.width = 160,
  });

  final Circle circle;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and member count
                Row(
                  children: [
                    _buildSmallAvatar(context),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${circle.memberCount}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  circle.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (circle.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    circle.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAvatar(BuildContext context) {
    final theme = Theme.of(context);
    const size = 36.0;

    if (circle.avatarUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(circle.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        circle.name.isNotEmpty ? circle.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
