import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Circle avatar widget with name and member count badge
///
/// Displays a circular avatar for a Circle with the circle name below
/// and an optional member count badge.
class CircleAvatarWidget extends StatelessWidget {
  const CircleAvatarWidget({
    super.key,
    required this.circle,
    this.onTap,
    this.size = 60.0,
    this.showName = true,
    this.showMemberCount = true,
    this.nameMaxLines = 1,
  });

  /// The Circle to display
  final Circle circle;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Size of the avatar
  final double size;

  /// Whether to show the circle name below
  final bool showName;

  /// Whether to show the member count badge
  final bool showMemberCount;

  /// Maximum lines for the name
  final int nameMaxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with optional badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar
              _buildAvatar(context),

              // Member count badge
              if (showMemberCount)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: _buildMemberBadge(context),
                ),
            ],
          ),

          // Name
          if (showName) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: size + 20,
              child: Text(
                circle.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: nameMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

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

    // Default avatar with gradient and initials
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
        child: Text(
          _getInitials(circle.name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 2,
        ),
      ),
      child: Text(
        '${circle.memberCount}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<Color> _getGradientColors(ThemeData theme, String id) {
    // Generate consistent colors based on circle ID
    final hash = id.hashCode;
    final hue1 = (hash % 360).toDouble();
    final hue2 = ((hash ~/ 360) % 360).toDouble();

    return [
      HSLColor.fromAHSL(1.0, hue1, 0.6, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, hue2, 0.6, 0.4).toColor(),
    ];
  }
}

/// Small avatar for inline display (e.g., in lists)
class CircleAvatarSmall extends StatelessWidget {
  const CircleAvatarSmall({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 32.0,
    this.onTap,
  });

  final String? avatarUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: avatarUrl != null
          ? CircleAvatar(
              radius: size / 2,
              backgroundImage: NetworkImage(avatarUrl!),
            )
          : CircleAvatar(
              radius: size / 2,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
