import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Avatar widget for displaying a circle
class UnityCircleAvatar extends StatelessWidget {
  const UnityCircleAvatar({
    super.key,
    required this.circle,
    this.onTap,
    this.size = 60,
  });

  final Circle circle;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circle.theme != null
                  ? Color(int.parse(circle.theme!.replaceFirst('#', '0xFF')))
                  : theme.colorScheme.primaryContainer,
              image: circle.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(circle.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: circle.avatarUrl == null
                ? Center(
                    child: Text(
                      circle.name.isNotEmpty ? circle.name[0].toUpperCase() : '?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 20,
            child: Text(
              circle.name,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
