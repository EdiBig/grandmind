import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Challenge detail screen showing challenge info, progress, and activity
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen>
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
    final challengeAsync = ref.watch(challengeByIdProvider(widget.challengeId));
    final participationAsync =
        ref.watch(userChallengeParticipationProvider(widget.challengeId));

    return challengeAsync.when(
      data: (challenge) {
        if (challenge == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Challenge not found')),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(context, challenge),
                SliverToBoxAdapter(
                  child: _buildChallengeHeader(context, challenge),
                ),
                participationAsync.when(
                  data: (participation) {
                    if (participation != null) {
                      return SliverToBoxAdapter(
                        child: _buildProgressSection(
                            context, challenge, participation),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                  loading: () =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (_, __) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
                SliverPersistentHeader(
                  delegate: _TabBarDelegate(
                    tabController: _tabController,
                    hasLeaderboard: challenge.hasLeaderboard,
                    hasFeed: challenge.hasActivityFeed,
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, challenge),
                if (challenge.hasActivityFeed)
                  _buildFeedTab(context, challenge)
                else
                  const SizedBox.shrink(),
                _buildMembersTab(context, challenge),
              ],
            ),
          ),
          bottomNavigationBar: participationAsync.when(
            data: (participation) =>
                _buildBottomBar(context, challenge, participation),
            loading: () => null,
            error: (_, __) => null,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Challenge challenge) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(challenge.name),
        background: challenge.imageUrl != null
            ? Image.network(
                challenge.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultBackground(context),
              )
            : _buildDefaultBackground(context),
      ),
    );
  }

  Widget _buildDefaultBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type and participation info
          Row(
            children: [
              Chip(
                label: Text(challenge.type.displayName),
                backgroundColor:
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(challenge.participationType.displayName),
                backgroundColor:
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
              ),
              const Spacer(),
              Icon(
                Icons.people_outline,
                size: 16,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '${challenge.participantCount}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            challenge.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Date info
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(challenge.startDate)} - ${_formatDate(challenge.endDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 16),
              if (challenge.isActive) ...[
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${challenge.daysRemaining} days left',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    Challenge challenge,
    ChallengeParticipation participation,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(participation.selectedTier.displayName),
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getTierColor(participation.selectedTier),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UnityProgressBar(
            progress: participation.percentComplete / 100,
            height: 12,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${participation.currentProgress.toStringAsFixed(0)} ${challenge.goal.effectiveUnit}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${participation.percentComplete.toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                icon: Icons.local_fire_department,
                label: '${participation.currentStreak} day streak',
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.favorite,
                label: '${participation.cheersReceived} cheers',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal
          Text(
            'Goal',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(_getMetricIcon(challenge.goal.metric)),
              title: Text(
                '${challenge.goal.targetValue.toStringAsFixed(0)} ${challenge.goal.effectiveUnit}',
              ),
              subtitle: Text(challenge.goal.type.description),
            ),
          ),
          const SizedBox(height: 24),

          // Difficulty Tiers
          if (challenge.tiers != null) ...[
            Text(
              'Difficulty Tiers',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Same achievement, your pace',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            _TierCard(tier: challenge.tiers!.gentle),
            const SizedBox(height: 8),
            _TierCard(tier: challenge.tiers!.steady),
            const SizedBox(height: 8),
            _TierCard(tier: challenge.tiers!.intense),
            const SizedBox(height: 24),
          ],

          // Milestones
          if (challenge.milestones.isNotEmpty) ...[
            Text(
              'Milestones',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...challenge.milestones.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MilestoneBadge(milestone: m),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context, Challenge challenge) {
    final feedAsync = ref.watch(challengeFeedProvider(widget.challengeId));

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('No activity yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeedPostCard(post: posts[index]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMembersTab(BuildContext context, Challenge challenge) {
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(widget.challengeId));

    return participantsAsync.when(
      data: (participants) {
        if (participants.isEmpty) {
          return const Center(child: Text('No participants yet'));
        }

        // Filter out whisper mode users if leaderboard is enabled
        final visibleParticipants = challenge.hasLeaderboard
            ? participants
                .where((p) => p.showInRankings && !p.whisperModeEnabled)
                .toList()
            : participants;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: visibleParticipants.length,
          itemBuilder: (context, index) {
            final p = visibleParticipants[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
                child: p.avatarUrl == null
                    ? Text(p.effectiveDisplayName[0].toUpperCase())
                    : null,
              ),
              title: Text(p.effectiveDisplayName),
              subtitle: UnityProgressBar(
                progress: p.percentComplete / 100,
                height: 6,
              ),
              trailing: Text('${p.percentComplete.toStringAsFixed(0)}%'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    Challenge challenge,
    ChallengeParticipation? participation,
  ) {
    final theme = Theme.of(context);

    if (participation != null) {
      // User is participating
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showLogProgressSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Log Progress'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () => _showRestDaySheet(context),
                icon: const Icon(Icons.self_improvement),
                tooltip: 'Take Rest Day',
              ),
            ],
          ),
        ),
      );
    }

    // User is not participating - show join button
    if (challenge.isJoinable) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => context.push(
              '/unity/challenge/${widget.challengeId}/join',
            ),
            child: const Text('Join Challenge'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showLogProgressSheet(BuildContext context) {
    // TODO: Implement progress logging bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Log Progress Sheet - Coming Soon'),
      ),
    );
  }

  void _showRestDaySheet(BuildContext context) {
    // TODO: Implement rest day bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Rest Day Sheet - Coming Soon'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  IconData _getMetricIcon(MetricType metric) {
    switch (metric) {
      case MetricType.steps:
        return Icons.directions_walk;
      case MetricType.distance:
        return Icons.straighten;
      case MetricType.workouts:
        return Icons.fitness_center;
      case MetricType.calories:
        return Icons.local_fire_department;
      default:
        return Icons.track_changes;
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({
    required this.tabController,
    required this.hasLeaderboard,
    required this.hasFeed,
  });

  final TabController tabController;
  final bool hasLeaderboard;
  final bool hasFeed;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: [
          const Tab(text: 'Overview'),
          if (hasFeed) const Tab(text: 'Feed'),
          const Tab(text: 'Members'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier});

  final TierConfig tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getColor(tier.tier).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              tier.tier.displayName[0],
              style: TextStyle(
                color: _getColor(tier.tier),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(tier.name),
        subtitle: Text(tier.description),
        trailing: Text(
          '${tier.targetValue.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getColor(DifficultyTier tier) {
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
