import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Non-competitive visualization of challenge progress
/// Shows collective progress with encouraging labels instead of exact rankings
class ProgressPortraitScreen extends ConsumerWidget {
  const ProgressPortraitScreen({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final challengeAsync = ref.watch(challengeByIdProvider(challengeId));
    final participantsAsync = ref.watch(challengeParticipantsProvider(challengeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Portrait'),
      ),
      body: challengeAsync.when(
        data: (challenge) {
          if (challenge == null) {
            return const Center(child: Text('Challenge not found'));
          }

          return participantsAsync.when(
            data: (participants) {
              return _buildContent(context, ref, challenge, participants);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
    List<ChallengeParticipation> participants,
  ) {
    final theme = Theme.of(context);

    // Calculate collective progress
    final totalProgress = participants.fold<double>(
      0,
      (sum, p) => sum + p.currentProgress,
    );
    final averageProgress = participants.isNotEmpty
        ? totalProgress / participants.length
        : 0.0;
    final collectiveGoal = challenge.goal.targetValue * participants.length;
    final collectivePercentage =
        collectiveGoal > 0 ? (totalProgress / collectiveGoal * 100) : 0.0;

    // Filter visible participants (not in whisper mode)
    final visibleParticipants =
        participants.where((p) => !p.whisperModeEnabled).toList();

    // Sort by progress for visualization (but don't show rankings)
    visibleParticipants.sort((a, b) => b.percentComplete.compareTo(a.percentComplete));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Philosophy banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                  theme.colorScheme.secondaryContainer.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.spa,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Progress Portrait',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "No rankings here. Just everyone's journey, visualised together.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Collective progress
          Text(
            'Collective Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCollectiveProgress(
            context,
            collectivePercentage,
            totalProgress,
            collectiveGoal,
            challenge.goal.effectiveUnit,
          ),
          const SizedBox(height: 24),

          // Team stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  value: '${participants.length}',
                  label: 'Participants',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  value: '${averageProgress.toStringAsFixed(0)}',
                  label: 'Avg ${challenge.goal.effectiveUnit}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Individual progress visualization
          Text(
            'Everyone\'s Journey',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each bar represents a participant. No names, no rankings - just progress.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bars for each participant
          ...visibleParticipants.asMap().entries.map((entry) {
            final index = entry.key;
            final participant = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ParticipantProgressBar(
                progress: participant.percentComplete / 100,
                label: _getEncouragingLabel(participant.percentComplete),
                tier: participant.selectedTier,
              ),
            );
          }),

          // Hidden participants note
          if (participants.length != visibleParticipants.length) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_off,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${participants.length - visibleParticipants.length} participants are in Whisper Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Milestones section
          if (challenge.milestones.isNotEmpty) ...[
            Text(
              'Milestones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...challenge.milestones.map((milestone) {
              final unlockedCount = participants
                  .where((p) => p.milestonesUnlocked.contains(milestone.id))
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MilestoneProgress(
                  milestone: milestone,
                  unlockedCount: unlockedCount,
                  totalCount: participants.length,
                ),
              );
            }),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCollectiveProgress(
    BuildContext context,
    double percentage,
    double total,
    double goal,
    String unit,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCollectiveMessage(percentage),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 16,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${total.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _getEncouragingLabel(double percentComplete) {
    if (percentComplete >= 100) return 'Complete!';
    if (percentComplete >= 90) return 'Almost there!';
    if (percentComplete >= 75) return 'Strong progress';
    if (percentComplete >= 50) return 'Halfway';
    if (percentComplete >= 25) return 'Building momentum';
    if (percentComplete > 0) return 'Getting started';
    return 'Ready to begin';
  }

  String _getCollectiveMessage(double percentage) {
    if (percentage >= 100) return 'Amazing! The team has crushed it!';
    if (percentage >= 75) return 'Incredible progress together!';
    if (percentage >= 50) return 'Halfway there as a team!';
    if (percentage >= 25) return 'Great start, keep it up!';
    return 'The journey begins!';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantProgressBar extends StatelessWidget {
  const _ParticipantProgressBar({
    required this.progress,
    required this.label,
    required this.tier,
  });

  final double progress;
  final String label;
  final DifficultyTier tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTierColor(tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 24,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(color.withOpacity(0.8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
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

class _MilestoneProgress extends StatelessWidget {
  const _MilestoneProgress({
    required this.milestone,
    required this.unlockedCount,
    required this.totalCount,
  });

  final Milestone milestone;
  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: unlockedCount > 0 ? Colors.amber : theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$unlockedCount of $totalCount reached',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
