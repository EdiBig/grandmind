import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Provider for filtered participations by status
final _activeChallengesFilteredProvider =
    Provider<AsyncValue<List<ChallengeParticipation>>>((ref) {
  final participations = ref.watch(userParticipationsProvider);
  return participations.whenData(
    (list) => list.where((p) => p.status == ParticipationStatus.active).toList(),
  );
});

final _completedChallengesFilteredProvider =
    Provider<AsyncValue<List<ChallengeParticipation>>>((ref) {
  final participations = ref.watch(userParticipationsProvider);
  return participations.whenData(
    (list) =>
        list.where((p) => p.status == ParticipationStatus.completed).toList(),
  );
});

final _inactiveChallengesFilteredProvider =
    Provider<AsyncValue<List<ChallengeParticipation>>>((ref) {
  final participations = ref.watch(userParticipationsProvider);
  return participations.whenData(
    (list) => list
        .where((p) =>
            p.status == ParticipationStatus.withdrawn ||
            p.status == ParticipationStatus.paused)
        .toList(),
  );
});

/// Screen showing user's challenges in different tabs
class MyChallengesScreen extends ConsumerStatefulWidget {
  const MyChallengesScreen({super.key});

  @override
  ConsumerState<MyChallengesScreen> createState() => _MyChallengesScreenState();
}

class _MyChallengesScreenState extends ConsumerState<MyChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Challenges'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Inactive'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveChallengesTab(),
          _CompletedChallengesTab(),
          _InactiveChallengesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/unity/discover'),
        icon: const Icon(Icons.add),
        label: const Text('Join Challenge'),
      ),
    );
  }
}

class _ActiveChallengesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participationsAsync = ref.watch(_activeChallengesFilteredProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userParticipationsProvider);
      },
      child: participationsAsync.when(
        data: (participations) {
          if (participations.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.emoji_events_outlined,
              title: 'No active challenges',
              subtitle: 'Join a challenge to get started!',
              actionLabel: 'Discover Challenges',
              onAction: () => context.push('/unity/discover'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final participation = participations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChallengeParticipationCard(
                  participation: participation,
                  onTap: () => context.push(
                    '/unity/challenge/${participation.challengeId}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CompletedChallengesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participationsAsync = ref.watch(_completedChallengesFilteredProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userParticipationsProvider);
      },
      child: participationsAsync.when(
        data: (participations) {
          if (participations.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.celebration_outlined,
              title: 'No completed challenges yet',
              subtitle: 'Complete your first challenge to see it here!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final participation = participations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChallengeParticipationCard(
                  participation: participation,
                  onTap: () => context.push(
                    '/unity/challenge/${participation.challengeId}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InactiveChallengesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participationsAsync = ref.watch(_inactiveChallengesFilteredProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userParticipationsProvider);
      },
      child: participationsAsync.when(
        data: (participations) {
          if (participations.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.pause_circle_outline,
              title: 'No inactive challenges',
              subtitle: 'Paused or withdrawn challenges will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final participation = participations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChallengeParticipationCard(
                  participation: participation,
                  onTap: () => context.push(
                    '/unity/challenge/${participation.challengeId}',
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final theme = Theme.of(context);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    ),
  );
}

class _ChallengeParticipationCard extends ConsumerWidget {
  const _ChallengeParticipationCard({
    required this.participation,
    this.onTap,
  });

  final ChallengeParticipation participation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final challengeAsync =
        ref.watch(challengeByIdProvider(participation.challengeId));

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: challengeAsync.when(
            data: (challenge) {
              if (challenge == null) {
                return const Text('Challenge not found');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _StatusBadge(status: participation.status),
                                const SizedBox(width: 8),
                                _TierBadge(tier: participation.selectedTier),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${participation.percentComplete.toStringAsFixed(0)}%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
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
                                  '${participation.currentStreak} day',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  UnityProgressBar(
                    progress: participation.percentComplete / 100,
                    height: 8,
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        challenge.isActive
                            ? '${challenge.daysRemaining} days left'
                            : 'Ended',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${participation.cheersReceived} cheers',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ParticipationStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case ParticipationStatus.active:
        color = Colors.green;
        break;
      case ParticipationStatus.completed:
        color = Colors.blue;
        break;
      case ParticipationStatus.paused:
        color = Colors.orange;
        break;
      case ParticipationStatus.withdrawn:
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final DifficultyTier tier;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (tier) {
      case DifficultyTier.gentle:
        color = Colors.green;
        break;
      case DifficultyTier.steady:
        color = Colors.blue;
        break;
      case DifficultyTier.intense:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tier.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
