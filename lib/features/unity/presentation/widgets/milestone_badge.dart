import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Badge widget for displaying a milestone
class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({
    super.key,
    required this.milestone,
    this.isUnlocked = false,
  });

  final Milestone milestone;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isUnlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (milestone.description.isNotEmpty)
                  Text(
                    milestone.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isUnlocked
                          ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                          : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${milestone.targetValue.toStringAsFixed(0)}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
