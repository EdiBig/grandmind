import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/progress_providers.dart';
import '../widgets/personal_best_card.dart';

class PersonalBestsScreen extends ConsumerStatefulWidget {
  const PersonalBestsScreen({super.key});

  @override
  ConsumerState<PersonalBestsScreen> createState() =>
      _PersonalBestsScreenState();
}

class _PersonalBestsScreenState extends ConsumerState<PersonalBestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PersonalBestCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(personalBestsSummaryProvider);
    final allPRsAsync = ref.watch(allPersonalBestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Records'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All PRs'),
            Tab(text: 'By Category'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All PRs Tab
          _buildAllPRsTab(context, allPRsAsync, summaryAsync),

          // By Category Tab
          _buildByCategoryTab(context, allPRsAsync, summaryAsync),
        ],
      ),
    );
  }

  Widget _buildAllPRsTab(
    BuildContext context,
    AsyncValue<List<PersonalBest>> allPRsAsync,
    AsyncValue<PersonalBestsSummary> summaryAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(personalBestsSummaryProvider);
        ref.invalidate(allPersonalBestsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          summaryAsync.when(
            data: (summary) => _buildSummaryHeader(context, summary),
            loading: () => const _SkeletonSummaryCard(),
            error: (_, __) => _buildErrorCard(
              context,
              'Unable to load summary',
              () => ref.invalidate(personalBestsSummaryProvider),
            ),
          ),
          const SizedBox(height: 24),

          // Recent PRs
          Text(
            'All Personal Records',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          allPRsAsync.when(
            data: (prs) {
              if (prs.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: prs
                    .map((pr) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PersonalBestCard(pr: pr),
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => _buildErrorCard(
              context,
              'Unable to load personal records',
              () => ref.invalidate(allPersonalBestsProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByCategoryTab(
    BuildContext context,
    AsyncValue<List<PersonalBest>> allPRsAsync,
    AsyncValue<PersonalBestsSummary> summaryAsync,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return allPRsAsync.when(
      data: (prs) {
        // Group PRs by category
        final grouped = <PersonalBestCategory, List<PersonalBest>>{};
        for (final pr in prs) {
          grouped.putIfAbsent(pr.category, () => []).add(pr);
        }

        if (prs.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(context, null, 'All'),
                  ...PersonalBestCategory.values.map((cat) {
                    final count = grouped[cat]?.length ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    return _buildCategoryChip(
                      context,
                      cat,
                      '${cat.displayName} ($count)',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filtered PRs
            ...(_selectedCategory == null ? grouped.entries : grouped.entries.where((e) => e.key == _selectedCategory))
                .map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(entry.key),
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entry.value.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((pr) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCompactPRCard(context, pr),
                            )),
                        const SizedBox(height: 8),
                      ],
                    )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: _buildErrorCard(
          context,
          'Unable to load personal records',
          () => ref.invalidate(allPersonalBestsProvider),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    PersonalBestCategory? category,
    String label,
  ) {
    final isSelected = _selectedCategory == category;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    PersonalBestsSummary summary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Records',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatWhite(
                  context,
                  '${summary.totalPRCount}',
                  'Total PRs',
                  Icons.star,
                ),
              ),
              Expanded(
                child: _buildSummaryStatWhite(
                  context,
                  '${summary.monthlyPRCount}',
                  'This Month',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildSummaryStatWhite(
                  context,
                  '${summary.allTimeBests.length}',
                  'Categories',
                  Icons.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatWhite(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPRCard(BuildContext context, PersonalBest pr) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy').format(pr.achievedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pr.value.toStringAsFixed(1)} ${pr.unit}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
              ),
              if (pr.previousValue != null)
                Text(
                  '+${pr.improvementPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Personal Records Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts and track your progress to start setting personal records!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(PersonalBestCategory category) {
    switch (category) {
      case PersonalBestCategory.weight:
        return Icons.monitor_weight;
      case PersonalBestCategory.workout:
        return Icons.fitness_center;
      case PersonalBestCategory.strength:
        return Icons.sports_gymnastics;
      case PersonalBestCategory.cardio:
        return Icons.directions_run;
      case PersonalBestCategory.streak:
        return Icons.local_fire_department;
      case PersonalBestCategory.habit:
        return Icons.check_circle;
    }
  }
}

class _SkeletonSummaryCard extends StatelessWidget {
  const _SkeletonSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
