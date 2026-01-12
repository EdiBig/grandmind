import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import '../../../../core/constants/route_constants.dart';

class TogetherHubScreen extends ConsumerWidget {
  const TogetherHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengesProvider);
    final participantsAsync = ref.watch(userChallengeParticipantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity'),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.createChallenge),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create challenge',
          ),
        ],
      ),
      body: challengesAsync.when(
        data: (challenges) => participantsAsync.when(
          data: (participants) => _buildContent(
            context,
            ref,
            challenges,
            participants,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(context, error),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.createChallenge),
        label: const Text('Create Challenge'),
        icon: const Icon(Icons.flag_outlined),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ChallengeModel> challenges,
    List<ChallengeParticipantModel> participants,
  ) {
    final activeChallengeIds = participants
        .where((participant) => participant.leftAt == null)
        .map((participant) => participant.challengeId)
        .toSet();

    final activeChallenges = challenges
        .where((challenge) => activeChallengeIds.contains(challenge.id))
        .toList();
    final discoverChallenges = challenges
        .where((challenge) => !activeChallengeIds.contains(challenge.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildProfileCard(context, ref),
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Active Challenges', activeChallenges.length),
        const SizedBox(height: 8),
        if (activeChallenges.isEmpty)
          _buildEmptyState(context, 'No active challenges yet.'),
        ...activeChallenges.map((challenge) => _buildChallengeCard(
              context,
              challenge,
              isActive: true,
            )),
        const SizedBox(height: 20),
        _buildSectionHeader(context, 'Discover Challenges', discoverChallenges.length),
        const SizedBox(height: 8),
        if (discoverChallenges.isEmpty)
          _buildEmptyState(context, 'No public challenges available right now.'),
        ...discoverChallenges.map((challenge) => _buildChallengeCard(
              context,
              challenge,
              isActive: false,
            )),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: userAsync.when(
          data: (user) => Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  (user?.displayName ?? 'You')
                      .trim()
                      .characters
                      .first
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Your community space',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join challenges and build momentum together.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(height: 56),
          error: (_, __) => const SizedBox(height: 56),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    ChallengeModel challenge, {
    required bool isActive,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          RouteConstants.challengeDetail.replaceFirst(':id', challenge.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(context, challenge.type.name),
                  _buildTag(context, '${challenge.goalTarget} ${challenge.goalUnit}'),
                  _buildTag(context, _daysRemainingLabel(challenge)),
                  _buildTag(context, '${challenge.participantCount} participants'),
                ],
              ),
              if (!isActive) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tap to view details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _daysRemainingLabel(ChallengeModel challenge) {
    final now = DateTime.now();
    final difference = challenge.endDate.difference(now);
    if (difference.inDays <= 0) {
      return 'Ends today';
    }
    return '${difference.inDays} days left';
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Text(
        'Unable to load challenges: $error',
        textAlign: TextAlign.center,
      ),
    );
  }
}
