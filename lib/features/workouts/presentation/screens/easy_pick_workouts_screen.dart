import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import '../providers/workout_library_providers.dart';
import 'workout_library_detail_screen.dart';

class EasyPickWorkoutsScreen extends ConsumerStatefulWidget {
  const EasyPickWorkoutsScreen({super.key});

  @override
  ConsumerState<EasyPickWorkoutsScreen> createState() =>
      _EasyPickWorkoutsScreenState();
}

class _EasyPickWorkoutsScreenState
    extends ConsumerState<EasyPickWorkoutsScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    final filters = ref.read(workoutLibraryFiltersProvider);
    ref.read(workoutLibraryFiltersProvider.notifier).state =
        filters.copyWith(searchQuery: value);
  }

  void _applyCategory(WorkoutLibraryCategory category) {
    final filters = ref.read(workoutLibraryFiltersProvider);
    ref.read(workoutLibraryFiltersProvider.notifier).state = filters.copyWith(
      bodyFocuses: _addToSet(filters.bodyFocuses, category.bodyFocus),
      goals: _addToSet(filters.goals, category.goal),
      conditionTags: _addToSet(filters.conditionTags, category.conditionTag),
      abilityTags: _addToSet(filters.abilityTags, category.abilityTag),
      accessibilityTags:
          _addToSet(filters.accessibilityTags, category.accessibilityTag),
      durationRanges:
          _addToSet(filters.durationRanges, category.durationRange),
      equipments: _addToSet(filters.equipments, category.equipment),
    );
  }

  Set<T> _addToSet<T>(Set<T> current, T? value) {
    if (value == null) return current;
    final next = Set<T>.from(current);
    next.add(value);
    return next;
  }

  Set<T> _removeFromSet<T>(Set<T> current, T value) {
    final next = Set<T>.from(current);
    next.remove(value);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(workoutLibraryFiltersProvider);
    final entries = ref.watch(workoutLibraryProvider);
    final showCategories =
        !filters.hasActiveFilters && filters.searchQuery.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Pick Workouts'),
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchRow(context, filters),
          const SizedBox(height: 16),
          _buildSortRow(context, filters),
          if (filters.hasActiveFilters) ...[
            const SizedBox(height: 12),
            _buildActiveFilterChips(context, filters),
          ],
          if (showCategories) ...[
            const SizedBox(height: 20),
            _buildCategoriesSection(context),
          ],
          const SizedBox(height: 24),
          Text(
            showCategories ? 'Recommended Picks' : 'Workout Results',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _buildEmptyState(context, filters)
          else
            ...entries.map((entry) => _buildWorkoutCard(context, entry)),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context, WorkoutLibraryFilters filters) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: 'Search glutes, dumbbell, mobility...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filters.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _updateSearch('');
                        _searchFocus.unfocus();
                      },
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showFilterSheet(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSortRow(BuildContext context, WorkoutLibraryFilters filters) {
    return Row(
      children: [
        Text(
          'Sort by',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<WorkoutLibrarySort>(
          onSelected: (value) {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(sort: value);
          },
          itemBuilder: (context) => WorkoutLibrarySort.values
              .map(
                (sort) => PopupMenuItem(
                  value: sort,
                  child: Text(sort.displayName),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  filters.sort.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                const WorkoutLibraryFilters();
            _searchController.clear();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildActiveFilterChips(
    BuildContext context,
    WorkoutLibraryFilters filters,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
    final chips = <Widget>[];
    for (final focus in filters.bodyFocuses) {
      chips.add(
        InputChip(
          label: Text(focus.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              bodyFocuses: _removeFromSet(filters.bodyFocuses, focus),
            );
          },
        ),
      );
    }
    for (final goal in filters.goals) {
      chips.add(
        InputChip(
          label: Text(goal.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              goals: _removeFromSet(filters.goals, goal),
            );
          },
        ),
      );
    }
    for (final range in filters.durationRanges) {
      chips.add(
        InputChip(
          label: Text(range.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              durationRanges: _removeFromSet(filters.durationRanges, range),
            );
          },
        ),
      );
    }
    for (final equipment in filters.equipments) {
      chips.add(
        InputChip(
          label: Text(equipment.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              equipments: _removeFromSet(filters.equipments, equipment),
            );
          },
        ),
      );
    }
    for (final difficulty in filters.difficulties) {
      chips.add(
        InputChip(
          label: Text(difficulty.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              difficulties: _removeFromSet(filters.difficulties, difficulty),
            );
          },
        ),
      );
    }
    for (final tag in filters.conditionTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              conditionTags: _removeFromSet(filters.conditionTags, tag),
            );
          },
        ),
      );
    }
    for (final tag in filters.abilityTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              abilityTags: _removeFromSet(filters.abilityTags, tag),
            );
          },
        ),
      );
    }
    for (final tag in filters.accessibilityTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceVariant,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            ref.read(workoutLibraryFiltersProvider.notifier).state =
                filters.copyWith(
              accessibilityTags:
                  _removeFromSet(filters.accessibilityTags, tag),
            );
          },
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: WorkoutLibraryCategoryGroup.values.map((group) {
        final categories = workoutLibraryCategories
            .where((category) => category.group == group)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories
                  .map((category) => _buildCategoryCard(context, category))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WorkoutLibraryCategory category,
  ) {
    return Semantics(
      label: '${category.title} category',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _applyCategory(category);
        },
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                category.subcategories,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.suggestedLevel.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutLibraryEntry entry) {
    return Semantics(
      label: 'Workout ${entry.name}',
      button: true,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutLibraryDetailScreen(entry: entry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getEntryIcon(entry),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.targetSummary,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(
                    context,
                    entry.equipment.displayName,
                    Icons.handyman,
                  ),
                  _buildTag(
                    context,
                    '${entry.durationMinutes} min',
                    Icons.access_time,
                  ),
                  _buildTag(
                    context,
                    entry.difficulty.displayName,
                    Icons.bar_chart,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.previewLabel ?? 'Quick guide inside',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getEntryIcon(WorkoutLibraryEntry entry) {
    final focus = entry.bodyFocuses.isEmpty ? null : entry.bodyFocuses.first;
    switch (focus) {
      case WorkoutBodyFocus.fullBody:
        return Icons.directions_run;
      case WorkoutBodyFocus.upper:
        return Icons.accessibility_new;
      case WorkoutBodyFocus.lower:
        return Icons.directions_walk;
      case WorkoutBodyFocus.core:
        return Icons.center_focus_strong;
      case WorkoutBodyFocus.arms:
        return Icons.fitness_center;
      case WorkoutBodyFocus.glutes:
        return Icons.sports_gymnastics;
      case WorkoutBodyFocus.back:
        return Icons.fitness_center;
      case null:
        return Icons.fitness_center;
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    WorkoutLibraryFilters filters,
  ) {
    final hasFilters = filters.hasActiveFilters;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No workouts found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try removing one filter or clear all filters.'
                : 'Try adjusting filters or searching another term.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildEmptyActionChip(
                  context,
                  'Clear all filters',
                  Icons.refresh,
                  () {
                    ref.read(workoutLibraryFiltersProvider.notifier).state =
                        const WorkoutLibraryFilters();
                  },
                ),
                if (filters.bodyFocuses.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Body focus',
                    Icons.fitness_center,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(bodyFocuses: {});
                    },
                  ),
                if (filters.goals.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Goals',
                    Icons.flag,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(goals: {});
                    },
                  ),
                if (filters.conditionTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Conditions',
                    Icons.healing,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(conditionTags: {});
                    },
                  ),
                if (filters.abilityTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Ability',
                    Icons.accessible,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(abilityTags: {});
                    },
                  ),
                if (filters.accessibilityTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Accessibility',
                    Icons.accessibility_new,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(accessibilityTags: {});
                    },
                  ),
                if (filters.equipments.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Equipment',
                    Icons.handyman,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(equipments: {});
                    },
                  ),
                if (filters.difficulties.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Difficulty',
                    Icons.bar_chart,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(difficulties: {});
                    },
                  ),
                if (filters.durationRanges.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Time',
                    Icons.timer,
                    () {
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(durationRanges: {});
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      ),
      onPressed: onTap,
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final filters = ref.watch(workoutLibraryFiltersProvider);
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Workouts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Body Part',
                    options: WorkoutBodyFocus.values,
                    selectedValues: filters.bodyFocuses,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutBodyFocus>.from(
                        filters.bodyFocuses,
                      );
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(bodyFocuses: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Goal',
                    options: WorkoutGoal.values,
                    selectedValues: filters.goals,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutGoal>.from(filters.goals);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(goals: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Condition',
                    options: WorkoutConditionTag.values,
                    selectedValues: filters.conditionTags,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next =
                          Set<WorkoutConditionTag>.from(filters.conditionTags);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(conditionTags: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Ability',
                    options: WorkoutAbilityTag.values,
                    selectedValues: filters.abilityTags,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next =
                          Set<WorkoutAbilityTag>.from(filters.abilityTags);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(abilityTags: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Time',
                    options: WorkoutDurationRange.values,
                    selectedValues: filters.durationRanges,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next =
                          Set<WorkoutDurationRange>.from(filters.durationRanges);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(durationRanges: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Equipment',
                    options: WorkoutEquipment.values,
                    selectedValues: filters.equipments,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next =
                          Set<WorkoutEquipment>.from(filters.equipments);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(equipments: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Difficulty',
                    options: WorkoutDifficulty.values,
                    selectedValues: filters.difficulties,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next =
                          Set<WorkoutDifficulty>.from(filters.difficulties);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(difficulties: next);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Accessibility Tags',
                    options: WorkoutAccessibilityTag.values,
                    selectedValues: filters.accessibilityTags,
                    labelBuilder: (value) => value.displayName,
                    infoIcon: Tooltip(
                      message:
                          'Accessibility tags highlight adaptations like seated or low impact.',
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onToggle: (value, selected) {
                      final next = Set<WorkoutAccessibilityTag>.from(
                        filters.accessibilityTags,
                      );
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      ref.read(workoutLibraryFiltersProvider.notifier).state =
                          filters.copyWith(accessibilityTags: next);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(workoutLibraryFiltersProvider.notifier)
                                .state = const WorkoutLibraryFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.6,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required Set<T> selectedValues,
    required String Function(T) labelBuilder,
    required void Function(T, bool) onToggle,
    Widget? infoIcon,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (infoIcon != null) ...[
              const SizedBox(width: 6),
              infoIcon,
            ],
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(labelBuilder(option)),
              selected: isSelected,
              onSelected: (selected) => onToggle(option, selected),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : onSurface,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? primary : outline,
                width: 1.4,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
