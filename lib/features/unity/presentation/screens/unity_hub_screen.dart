import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Main Unity Hub screen - the landing page for Unity feature
class UnityHubScreen extends ConsumerWidget {
  const UnityHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/unity/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeParticipationsProvider);
          ref.invalidate(featuredChallengesProvider);
          ref.invalidate(userCirclesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Quote/Philosophy Banner
            SliverToBoxAdapter(
              child: _buildPhilosophyBanner(context),
            ),

            // Active Challenges Section
            SliverToBoxAdapter(
              child: _buildActiveChallengesSection(context, ref),
            ),

            // My Circles Section
            SliverToBoxAdapter(
              child: _buildCirclesSection(context, ref),
            ),

            // Discover Section
            SliverToBoxAdapter(
              child: _buildDiscoverSection(context, ref),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhilosophyBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress together, at your own pace',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Unity isn't about being the best. It's about being better together.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChallengesSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participationsAsync = ref.watch(activeParticipationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Challenges',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/unity/my-challenges'),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        participationsAsync.when(
          data: (participations) {
            if (participations.isEmpty) {
              return _buildEmptyActiveChallenges(context);
            }

            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: participations.length,
                itemBuilder: (context, index) {
                  final participation = participations[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ActiveChallengeCard(
                      participation: participation,
                      onTap: () => context.push(
                        '/unity/challenge/${participation.challengeId}',
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading challenges: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyActiveChallenges(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No active challenges',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => context.push('/unity/discover'),
              child: const Text('Discover Challenges'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirclesSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circlesAsync = ref.watch(userCirclesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Circles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/unity/my-circles'),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        circlesAsync.when(
          data: (circles) {
            if (circles.isEmpty) {
              return _buildEmptyCircles(context);
            }

            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: circles.length + 1,
                itemBuilder: (context, index) {
                  if (index == circles.length) {
                    return _buildCreateCircleButton(context);
                  }

                  final circle = circles[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: UnityCircleAvatar(
                      circle: circle,
                      onTap: () => context.push('/unity/circle/${circle.id}'),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading circles: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCircles(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCreateCircleButton(context),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Create or join a Circle to connect with friends',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCircleButton(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/unity/create-circle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredAsync = ref.watch(featuredChallengesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/unity/discover'),
                child: const Text('Browse All'),
              ),
            ],
          ),
        ),
        featuredAsync.when(
          data: (challenges) {
            if (challenges.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No featured challenges right now',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: challenges.take(3).length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChallengeCard(
                    challenge: challenge,
                    onTap: () => context.push(
                      '/unity/challenge/${challenge.id}',
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading challenges: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.explore_outlined,
              label: 'Discover',
              onTap: () => context.push('/unity/discover'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.people_outline,
              label: 'Circles',
              onTap: () => context.push('/unity/my-circles'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.emoji_events_outlined,
              label: 'Challenges',
              onTap: () => context.push('/unity/my-challenges'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
