import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import '../providers/workout_library_providers.dart';
import 'workout_library_detail_screen.dart';

class WorkoutLibraryScreen extends ConsumerStatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  ConsumerState<WorkoutLibraryScreen> createState() =>
      _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends ConsumerState<WorkoutLibraryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(workoutLibraryFiltersProvider);
    _searchController = TextEditingController(text: filters.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(workoutLibraryFiltersProvider);
    final entries = ref.watch(workoutLibraryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Workouts'),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteConstants.wgerExercises),
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Exercise Library',
          ),
          IconButton(
            onPressed: () => _showFilterSheet(context, filters),
            icon: const Icon(Icons.tune),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => _updateFilters(
                      filters.copyWith(searchQuery: value),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by workout, goal, or equipment',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                _updateFilters(
                                  filters.copyWith(searchQuery: ''),
                                );
                              },
                            ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(
                          'Recommended',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        selected: filters.recommendedOnly,
                        selectedColor:
                            colorScheme.primary.withValues(alpha: 0.18),
                        onSelected: (selected) => _updateFilters(
                          filters.copyWith(recommendedOnly: selected),
                        ),
                      ),
                      ...WorkoutLibraryPrimaryCategory.values.map((category) {
                        final selected =
                            filters.primaryCategories.contains(category);
                        return FilterChip(
                          label: Text(
                            category.displayName,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          selected: selected,
                          selectedColor:
                              colorScheme.primary.withValues(alpha: 0.18),
                          onSelected: (_) => _updateFilters(
                            filters.copyWith(
                              primaryCategories: _toggleSet(
                                filters.primaryCategories,
                                category,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Browse by focus',
                    actionLabel: 'View all',
                    onTap: () => _showFilterSheet(context, filters),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: workoutLibraryCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = workoutLibraryCategories[index];
                        return _CategoryCard(
                          category: category,
                          onTap: () {
                            var next = filters;
                            if (category.bodyFocus != null) {
                              next = next.copyWith(
                                bodyFocuses: {
                                  category.bodyFocus!,
                                },
                              );
                            }
                            if (category.goal != null) {
                              next = next.copyWith(
                                goals: {category.goal!},
                              );
                            }
                            if (category.conditionTag != null) {
                              next = next.copyWith(
                                conditionTags: {category.conditionTag!},
                              );
                            }
                            if (category.abilityTag != null) {
                              next = next.copyWith(
                                abilityTags: {category.abilityTag!},
                              );
                            }
                            if (category.accessibilityTag != null) {
                              next = next.copyWith(
                                accessibilityTags: {category.accessibilityTag!},
                              );
                            }
                            if (category.durationRange != null) {
                              next = next.copyWith(
                                durationRanges: {category.durationRange!},
                              );
                            }
                            if (category.equipment != null) {
                              next = next.copyWith(
                                equipments: {category.equipment!},
                              );
                            }
                            _updateFilters(next);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Showing ${entries.length} workouts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const Spacer(),
                      DropdownButton<WorkoutLibrarySort>(
                        value: filters.sort,
                        underline: const SizedBox.shrink(),
                        items: WorkoutLibrarySort.values
                            .map(
                              (sort) => DropdownMenuItem(
                                value: sort,
                                child: Text(sort.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateFilters(filters.copyWith(sort: value));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _EmptyState(
                  onReset: () {
                    _searchController.clear();
                    _updateFilters(const WorkoutLibraryFilters());
                  },
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = entries[index];
                  return _WorkoutLibraryCard(
                    entry: entry,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkoutLibraryDetailScreen(entry: entry),
                        ),
                      );
                    },
                  );
                },
                childCount: entries.length,
              ),
            ),
        ],
      ),
    );
  }

  void _updateFilters(WorkoutLibraryFilters next) {
    ref.read(workoutLibraryFiltersProvider.notifier).update(next);
  }

  void _showFilterSheet(BuildContext context, WorkoutLibraryFilters filters) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        filters: filters,
        onApply: _updateFilters,
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.filters, required this.onApply});

  final WorkoutLibraryFilters filters;
  final ValueChanged<WorkoutLibraryFilters> onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late WorkoutLibraryFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _filters = const WorkoutLibraryFilters());
                  },
                  child: const Text('Clear all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterGroup<WorkoutEquipment>(
                      title: 'Equipment',
                      options: WorkoutEquipment.values,
                      selected: _filters.equipments,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          equipments: _toggleSet(_filters.equipments, item),
                        ),
                      ),
                    ),
                    _FilterGroup<WorkoutDurationRange>(
                      title: 'Duration',
                      options: WorkoutDurationRange.values,
                      selected: _filters.durationRanges,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          durationRanges:
                              _toggleSet(_filters.durationRanges, item),
                        ),
                      ),
                    ),
                    _FilterGroup<WorkoutDifficulty>(
                      title: 'Difficulty',
                      options: WorkoutDifficulty.values,
                      selected: _filters.difficulties,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          difficulties:
                              _toggleSet(_filters.difficulties, item),
                        ),
                      ),
                    ),
                    _FilterGroup<WorkoutIntensity>(
                      title: 'Intensity',
                      options: WorkoutIntensity.values,
                      selected: _filters.intensities,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          intensities: _toggleSet(_filters.intensities, item),
                        ),
                      ),
                    ),
                    _FilterGroup<WorkoutGoal>(
                      title: 'Goals',
                      options: WorkoutGoal.values,
                      selected: _filters.goals,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          goals: _toggleSet(_filters.goals, item),
                        ),
                      ),
                    ),
                    _FilterGroup<WorkoutBodyFocus>(
                      title: 'Body focus',
                      options: WorkoutBodyFocus.values,
                      selected: _filters.bodyFocuses,
                      labelBuilder: (item) => item.displayName,
                      onToggle: (item) => _update(
                        _filters.copyWith(
                          bodyFocuses:
                              _toggleSet(_filters.bodyFocuses, item),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Recommended for you',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Switch(
                            value: _filters.recommendedOnly,
                            onChanged: (value) => _update(
                              _filters.copyWith(recommendedOnly: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _update(WorkoutLibraryFilters next) {
    setState(() => _filters = next);
  }
}

class _FilterGroup<T> extends StatelessWidget {
  const _FilterGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onToggle,
  });

  final String title;
  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((item) {
              final isSelected = selected.contains(item);
              return FilterChip(
                label: Text(
                  labelBuilder(item),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                selected: isSelected,
                selectedColor:
                    colorScheme.primary.withValues(alpha: 0.18),
                onSelected: (_) => onToggle(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final WorkoutLibraryCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(
                category.icon,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                category.subcategories,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutLibraryCard extends StatelessWidget {
  const _WorkoutLibraryCard({required this.entry, required this.onTap});

  final WorkoutLibraryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (entry.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recommended',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.targetSummary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.timer,
                    label: '${entry.durationMinutes} min',
                  ),
                  _InfoChip(
                    icon: Icons.local_fire_department,
                    label: entry.resolvedIntensity.displayName,
                  ),
                  _InfoChip(
                    icon: Icons.fitness_center,
                    label: entry.difficulty.displayName,
                  ),
                  _InfoChip(
                    icon: Icons.build,
                    label: entry.equipment.displayName,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.search_off,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'No workouts match these filters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Try clearing filters or searching for a different keyword.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onReset,
          child: const Text('Clear filters'),
        ),
      ],
    );
  }
}

Set<T> _toggleSet<T>(Set<T> current, T item) {
  final next = current.toSet();
  if (next.contains(item)) {
    next.remove(item);
  } else {
    next.add(item);
  }
  return next;
}
