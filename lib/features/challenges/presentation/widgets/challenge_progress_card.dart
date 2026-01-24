import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/models/challenge_progress_model.dart';
import '../providers/challenge_providers.dart';

/// Card displaying user's progress in a challenge
class ChallengeProgressCard extends ConsumerWidget {
  final ChallengeModel challenge;
  final ChallengeParticipantModel participation;

  const ChallengeProgressCard({
    super.key,
    required this.challenge,
    required this.participation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = participation.currentProgress;
    final goal = challenge.goalTarget;
    final percentage = goal > 0 ? (progress / goal).clamp(0.0, 1.0) : 0.0;
    final percentDisplay = (percentage * 100).toInt();

    // Fetch milestones
    final milestonesAsync = ref.watch(challengeMilestonesProvider((
      challengeId: challenge.id,
      userId: participation.userId,
    )));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(percentage, colorScheme)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$percentDisplay%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _getProgressColor(percentage, colorScheme),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(percentage, colorScheme),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progress ${challenge.goalUnit}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Goal: $goal ${challenge.goalUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Milestone badges
            milestonesAsync.when(
              data: (milestones) => _buildMilestones(context, milestones),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Days remaining
            _buildDaysRemaining(context, challenge),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones(
      BuildContext context, List<ChallengeMilestone> milestones) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones Achieved',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: milestones.map((m) => _buildMilestoneBadge(context, m)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMilestoneBadge(BuildContext context, ChallengeMilestone milestone) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _getMilestoneIcon(milestone.milestoneType);
    final label = _getMilestoneLabel(milestone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getMilestoneIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.progressPercentage:
        return Icons.flag;
      case MilestoneType.streak:
        return Icons.local_fire_department;
      case MilestoneType.rankImprovement:
        return Icons.leaderboard;
      case MilestoneType.firstActivity:
        return Icons.star;
      case MilestoneType.goalCompleted:
        return Icons.emoji_events;
    }
  }

  String _getMilestoneLabel(ChallengeMilestone milestone) {
    switch (milestone.milestoneType) {
      case MilestoneType.progressPercentage:
        return '${milestone.threshold}% Complete';
      case MilestoneType.streak:
        return '${milestone.threshold} Day Streak';
      case MilestoneType.rankImprovement:
        return 'Rank Up';
      case MilestoneType.firstActivity:
        return 'First Activity';
      case MilestoneType.goalCompleted:
        return 'Goal Complete!';
    }
  }

  Widget _buildDaysRemaining(BuildContext context, ChallengeModel challenge) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final daysRemaining = challenge.endDate.difference(now).inDays;
    final isEnded = daysRemaining < 0;
    final isStarting = now.isBefore(challenge.startDate);

    String text;
    Color color;
    IconData icon;

    if (isEnded) {
      text = 'Challenge ended';
      color = colorScheme.outline;
      icon = Icons.check_circle;
    } else if (isStarting) {
      final daysUntilStart = challenge.startDate.difference(now).inDays;
      text = 'Starts in $daysUntilStart days';
      color = colorScheme.tertiary;
      icon = Icons.schedule;
    } else if (daysRemaining <= 3) {
      text = '$daysRemaining days left';
      color = colorScheme.error;
      icon = Icons.warning;
    } else if (daysRemaining <= 7) {
      text = '$daysRemaining days left';
      color = colorScheme.tertiary;
      icon = Icons.timer;
    } else {
      text = '$daysRemaining days left';
      color = colorScheme.onSurfaceVariant;
      icon = Icons.calendar_today;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage, ColorScheme colorScheme) {
    if (percentage >= 1.0) {
      return colorScheme.primary;
    } else if (percentage >= 0.75) {
      return colorScheme.tertiary;
    } else if (percentage >= 0.5) {
      return colorScheme.secondary;
    } else {
      return colorScheme.outline;
    }
  }
}

/// Compact progress indicator for list items
class ChallengeProgressIndicator extends StatelessWidget {
  final int progress;
  final int goal;
  final String unit;

  const ChallengeProgressIndicator({
    super.key,
    required this.progress,
    required this.goal,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = goal > 0 ? (progress / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${(percentage * 100).toInt()}%',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$progress/$goal',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
