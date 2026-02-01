import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Card widget for displaying a feed post
class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    this.onCheer,
    this.onComment,
    this.onTap,
  });

  final FeedPost post;
  final VoidCallback? onCheer;
  final VoidCallback? onComment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.authorAvatarUrl != null
                        ? NetworkImage(post.authorAvatarUrl!)
                        : null,
                    child: post.authorAvatarUrl == null
                        ? Text(post.displayAuthorName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.displayAuthorName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (post.createdAt != null)
                          Text(
                            _formatTime(post.createdAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildPostTypeBadge(context),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              _buildContent(context),

              const SizedBox(height: 12),

              // Actions row
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onCheer,
                    icon: const Icon(Icons.favorite_border, size: 18),
                    label: Text('${post.totalCheers}'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onComment,
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: Text('${post.commentCount}'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final IconData icon;
    final Color color;

    switch (post.type) {
      case FeedPostType.activity:
        icon = Icons.fitness_center;
        color = Colors.blue;
        break;
      case FeedPostType.milestone:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case FeedPostType.celebration:
        icon = Icons.celebration;
        color = Colors.purple;
        break;
      case FeedPostType.checkIn:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case FeedPostType.text:
        icon = Icons.chat;
        color = theme.colorScheme.outline;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    switch (post.type) {
      case FeedPostType.activity:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.content.activityValue != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_run,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${post.content.activityValue?.toStringAsFixed(0)} ${post.content.activityUnit ?? ''}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (post.content.text != null) ...[
              const SizedBox(height: 8),
              Text(post.content.text!),
            ],
          ],
        );

      case FeedPostType.milestone:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestone Reached!',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.amber[700],
                      ),
                    ),
                    Text(
                      post.content.milestoneName ?? 'Milestone',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return post.content.text != null
            ? Text(post.content.text!)
            : const SizedBox.shrink();
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
