import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive.dart';

/// Minimal recent activity section
class RecentActivitySection extends StatelessWidget {
  final List<RecentActivity> activities;
  final VoidCallback? onViewAll;

  const RecentActivitySection({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(3).toList();
    final spacing = context.spacing;
    final textStyles = context.textStyles;
    final sizes = context.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: textStyles.titleMedium,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (activities.length > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: textStyles.labelMedium,
                          color: const Color(0xFF14B8A6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Icon(
                        Icons.arrow_forward,
                        size: sizes.iconSmall * 0.9,
                        color: const Color(0xFF14B8A6),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),

        // Activity list
        if (displayActivities.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
            child: Container(
              padding: EdgeInsets.all(spacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(sizes.cardBorderRadius * 0.6),
              ),
              child: Center(
                child: Text(
                  'No recent activities',
                  style: TextStyle(
                    fontSize: textStyles.bodyMedium,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          )
        else
          ...displayActivities.map((activity) => _ActivityRow(
                activity: activity,
              )),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final RecentActivity activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final sizes = context.sizes;
    final textStyles = context.textStyles;

    final iconContainerSize = sizes.avatarSmall + 4;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.screenPadding,
        vertical: spacing.xs,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius * 0.6),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  activity.emoji,
                  style: TextStyle(fontSize: sizes.iconMedium * 0.9),
                ),
              ),
            ),
            SizedBox(width: spacing.md),

            // Title
            Expanded(
              child: Text(
                activity.title,
                style: TextStyle(
                  fontSize: textStyles.bodyMedium,
                  color: Colors.white,
                ),
              ),
            ),

            // Time
            Text(
              activity.timeAgo,
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

/// Activity data model
class RecentActivity {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final DateTime timestamp;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.timestamp,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  // Factory constructors for common activity types
  static RecentActivity workout({
    required String id,
    required String title,
    required DateTime timestamp,
  }) =>
      RecentActivity(
        id: id,
        title: title,
        emoji: '💪',
        color: const Color(0xFFFB923C),
        timestamp: timestamp,
      );

  static RecentActivity meditation({
    required String id,
    required String title,
    required DateTime timestamp,
  }) =>
      RecentActivity(
        id: id,
        title: title,
        emoji: '🧘',
        color: const Color(0xFFA78BFA),
        timestamp: timestamp,
      );

  static RecentActivity habit({
    required String id,
    required String title,
    required DateTime timestamp,
  }) =>
      RecentActivity(
        id: id,
        title: title,
        emoji: '✓',
        color: const Color(0xFF4ADE80),
        timestamp: timestamp,
      );

  static RecentActivity sleep({
    required String id,
    required String title,
    required DateTime timestamp,
  }) =>
      RecentActivity(
        id: id,
        title: title,
        emoji: '😴',
        color: const Color(0xFFA78BFA),
        timestamp: timestamp,
      );

  static RecentActivity steps({
    required String id,
    required String title,
    required DateTime timestamp,
  }) =>
      RecentActivity(
        id: id,
        title: title,
        emoji: '🚶',
        color: const Color(0xFF60A5FA),
        timestamp: timestamp,
      );
}
