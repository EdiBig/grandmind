import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import 'progress_bar.dart';

/// Card widget for displaying an active challenge participation
class ActiveChallengeCard extends StatelessWidget {
  const ActiveChallengeCard({
    super.key,
    required this.participation,
    this.onTap,
  });

  final ChallengeParticipation participation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTierColor(participation.selectedTier)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      participation.selectedTier.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getTierColor(participation.selectedTier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (participation.currentStreak > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${participation.currentStreak}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Spacer(),

              // Progress
              Text(
                '${participation.percentComplete.toStringAsFixed(0)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              UnityProgressBar(
                progress: participation.percentComplete / 100,
                height: 8,
              ),
              const SizedBox(height: 8),

              // Status
              Text(
                participation.status.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.gentle:
        return Colors.green;
      case DifficultyTier.steady:
        return Colors.blue;
      case DifficultyTier.intense:
        return Colors.orange;
    }
  }
}
