import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../providers/challenge_providers.dart';

class ChallengeActivityFeedScreen extends ConsumerWidget {
  const ChallengeActivityFeedScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeProvider(challengeId));
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(challengeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: challengeAsync.when(
        data: (challenge) {
          if (challenge == null) {
            return _buildEmptyState(
              context,
              icon: Icons.flag_outlined,
              title: 'Challenge not found',
              subtitle: 'This challenge may have been removed.',
            );
          }

          if (!challenge.hasActivityFeed) {
            return _buildEmptyState(
              context,
              icon: Icons.forum_outlined,
              title: 'Activity feed disabled',
              subtitle: 'This challenge does not have an activity feed.',
            );
          }

          return participantsAsync.when(
            data: (participants) => _buildFeed(
              context,
              challenge,
              participants,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildEmptyState(
              context,
              icon: Icons.error_outline,
              title: 'Unable to load activity',
              subtitle: error.toString(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildEmptyState(
          context,
          icon: Icons.error_outline,
          title: 'Unable to load challenge',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Widget _buildFeed(
    BuildContext context,
    ChallengeModel challenge,
    List<ChallengeParticipantModel> participants,
  ) {
    final optedIn = participants
        .where((participant) =>
            participant.leftAt == null && participant.optInActivityFeed)
        .toList();

    final items = _buildFeedItems(challenge, optedIn);

    if (items.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.forum_outlined,
        title: 'No activity yet',
        subtitle: 'Be the first to share progress in this challenge.',
      );
    }

    final totalParticipants =
        participants.where((participant) => participant.leftAt == null).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(
          context,
          totalParticipants: totalParticipants,
          optedInCount: optedIn.length,
          goalType: challenge.goalType,
          goalTarget: challenge.goalTarget,
          goalUnit: challenge.goalUnit,
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildFeedTile(context, item)),
      ],
    );
  }

  List<_ActivityFeedItem> _buildFeedItems(
    ChallengeModel challenge,
    List<ChallengeParticipantModel> participants,
  ) {
    final items = participants.map((participant) {
      final timestamp = participant.lastActivityAt ?? participant.joinedAt;
      final isJoin = participant.lastActivityAt == null;
      final progress = participant.currentProgress;
      final label = isJoin
          ? '${participant.displayName} joined the challenge'
          : _activityLabel(
              participant.displayName,
              challenge,
              progress,
            );
      return _ActivityFeedItem(
        title: label,
        timestamp: timestamp,
        isJoin: isJoin,
        progress: progress,
      );
    }).toList();

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  String _activityLabel(
    String name,
    ChallengeModel challenge,
    int progress,
  ) {
    final unit = challenge.goalUnit;
    switch (challenge.goalType) {
      case ChallengeGoalType.steps:
        return '$name logged $progress $unit';
      case ChallengeGoalType.workouts:
        return '$name completed $progress $unit';
      case ChallengeGoalType.habit:
        return '$name checked in $progress $unit';
      case ChallengeGoalType.distance:
        return '$name logged $progress $unit';
    }
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalParticipants,
    required int optedInCount,
    required ChallengeGoalType goalType,
    required int goalTarget,
    required String goalUnit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.groups_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$optedInCount of $totalParticipants sharing updates',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Goal: $goalTarget $goalUnit • ${goalType.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTile(BuildContext context, _ActivityFeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              item.isJoin ? Icons.person_add_alt : Icons.emoji_events_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(item.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class _ActivityFeedItem {
  const _ActivityFeedItem({
    required this.title,
    required this.timestamp,
    required this.isJoin,
    required this.progress,
  });

  final String title;
  final DateTime timestamp;
  final bool isJoin;
  final int progress;
}
