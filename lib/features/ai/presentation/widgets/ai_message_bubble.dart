import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';
import 'package:intl/intl.dart';

/// Message bubble for AI coach conversations
class AIMessageBubble extends StatelessWidget {
  final AIMessage message;
  final bool showCostInfo;

  const AIMessageBubble({
    super.key,
    required this.message,
    this.showCostInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar for assistant messages
          if (!isUser) _buildAvatar(context, isUser),

          const SizedBox(width: 8),

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message content
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 4),

                // Metadata (timestamp, cache indicator, cost)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                    ),
                    if (!isUser && message.fromCache == true) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.cached,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'cached',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontSize: 11,
                                ),
                      ),
                    ],
                    if (showCostInfo && message.cost != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${message.cost!.toStringAsFixed(4)}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Avatar for user messages
          if (isUser) _buildAvatar(context, isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isUser
          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        isUser ? Icons.person : Icons.fitness_center,
        size: 20,
        color: isUser
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
