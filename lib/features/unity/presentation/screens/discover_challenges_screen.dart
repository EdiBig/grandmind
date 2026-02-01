import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Provider for search query
final _searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for selected category filter
final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Provider for filtered challenges
final _filteredChallengesProvider =
    Provider<AsyncValue<List<Challenge>>>((ref) {
  final activeChallenges = ref.watch(activeChallengesProvider);
  final searchQuery = ref.watch(_searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(_selectedCategoryProvider);

  return activeChallenges.whenData((challenges) {
    return challenges.where((challenge) {
      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final matchesName =
            challenge.name.toLowerCase().contains(searchQuery);
        final matchesDescription =
            challenge.description.toLowerCase().contains(searchQuery);
        if (!matchesName && !matchesDescription) return false;
      }

      // Filter by category
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        if (challenge.category != selectedCategory) return false;
      }

      return true;
    }).toList();
  });
});

/// Discover challenges screen with search and filters
class DiscoverChallengesScreen extends ConsumerStatefulWidget {
  const DiscoverChallengesScreen({super.key});

  @override
  ConsumerState<DiscoverChallengesScreen> createState() =>
      _DiscoverChallengesScreenState();
}

class _DiscoverChallengesScreenState
    extends ConsumerState<DiscoverChallengesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredChallengesAsync = ref.watch(featuredChallengesProvider);
    final filteredChallengesAsync = ref.watch(_filteredChallengesProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Challenges'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeChallengesProvider);
          ref.invalidate(featuredChallengesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search challenges...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(_searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                  ),
                  onChanged: (value) {
                    ref.read(_searchQueryProvider.notifier).state = value;
                  },
                ),
              ),
            ),

            // Category filters
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: selectedCategory == null,
                      onTap: () {
                        ref.read(_selectedCategoryProvider.notifier).state = null;
                      },
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Fitness',
                      isSelected: selectedCategory == 'fitness',
                      onTap: () {
                        ref.read(_selectedCategoryProvider.notifier).state =
                            'fitness';
                      },
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Wellness',
                      isSelected: selectedCategory == 'wellness',
                      onTap: () {
                        ref.read(_selectedCategoryProvider.notifier).state =
                            'wellness';
                      },
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Mindfulness',
                      isSelected: selectedCategory == 'mindfulness',
                      onTap: () {
                        ref.read(_selectedCategoryProvider.notifier).state =
                            'mindfulness';
                      },
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Nutrition',
                      isSelected: selectedCategory == 'nutrition',
                      onTap: () {
                        ref.read(_selectedCategoryProvider.notifier).state =
                            'nutrition';
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            // Featured challenges section
            SliverToBoxAdapter(
              child: _buildFeaturedSection(context, featuredChallengesAsync),
            ),

            // All challenges header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'All Challenges',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Challenges grid
            filteredChallengesAsync.when(
              data: (challenges) {
                if (challenges.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No challenges found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final challenge = challenges[index];
                        return _GridChallengeCard(
                          challenge: challenge,
                          onTap: () => context.push(
                            '/unity/challenge/${challenge.id}',
                          ),
                        );
                      },
                      childCount: challenges.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    AsyncValue<List<Challenge>> featuredAsync,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.star, size: 20, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Featured',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        featuredAsync.when(
          data: (challenges) {
            if (challenges.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 280,
                      child: _FeaturedChallengeCard(
                        challenge: challenge,
                        onTap: () => context.push(
                          '/unity/challenge/${challenge.id}',
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading featured challenges'),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}

class _FeaturedChallengeCard extends StatelessWidget {
  const _FeaturedChallengeCard({
    required this.challenge,
    required this.onTap,
  });

  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (challenge.imageUrl != null)
              Image.network(
                challenge.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultBackground(context),
              )
            else
              _buildDefaultBackground(context),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.participantCount} participants',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
}

class _GridChallengeCard extends StatelessWidget {
  const _GridChallengeCard({
    required this.challenge,
    required this.onTap,
  });

  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: challenge.imageUrl != null
                  ? Image.network(
                      challenge.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _buildDefaultImage(context),
                    )
                  : _buildDefaultImage(context),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.participantCount}',
                          style: theme.textTheme.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          '${challenge.daysRemaining}d',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.emoji_events,
          size: 32,
          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
        ),
      ),
    );
  }
}
