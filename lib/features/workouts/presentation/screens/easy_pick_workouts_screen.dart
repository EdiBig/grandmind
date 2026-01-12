import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinesa/core/providers/shared_preferences_provider.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import '../providers/workout_library_providers.dart';
import '../providers/fitness_profile_provider.dart';
import 'fitness_profile_screen.dart';
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
  static const _recentSearchesKey = 'workout_library_recent_searches';
  List<String> _recentSearches = [];
  bool _didPromptProfile = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    final filters = ref.read(workoutLibraryFiltersProvider);
    _setFilters(filters.copyWith(searchQuery: value));
  }

  void _commitSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _saveRecentSearch(trimmed);
  }

  void _saveRecentSearch(String term) {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _recentSearches.removeWhere(
        (item) => item.toLowerCase() == term.toLowerCase(),
      );
      _recentSearches.insert(0, term);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  void _showFitnessProfilePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get personalized recommendations'),
        content: const Text(
          'Answer 5 quick questions to tailor workouts to your goals and needs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FitnessProfileScreen(),
                ),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _applySearchTerm(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    _updateSearch(term);
    _commitSearch(term);
  }

  List<String> _buildSuggestions(String query) {
    final suggestions = <String>{};
    for (final entry in workoutLibraryEntries) {
      if (entry.name.toLowerCase().contains(query)) {
        suggestions.add(entry.name);
      }
      if (entry.targetSummary.toLowerCase().contains(query)) {
        suggestions.add(entry.name);
      }
      if (entry.equipment.displayName.toLowerCase().contains(query)) {
        suggestions.add(entry.name);
      }
      if (entry.resolvedSubCategory.toLowerCase().contains(query)) {
        suggestions.add(entry.name);
      }
    }
    return suggestions.take(5).toList();
  }

  void _applyCategory(WorkoutLibraryCategory category) {
    const base = WorkoutLibraryFilters();
    _searchController.clear();
    _setFilters(base.copyWith(
      searchQuery: '',
      bodyFocuses: category.bodyFocus == null ? {} : {category.bodyFocus!},
      goals: category.goal == null ? {} : {category.goal!},
      conditionTags:
          category.conditionTag == null ? {} : {category.conditionTag!},
      abilityTags: category.abilityTag == null ? {} : {category.abilityTag!},
      accessibilityTags: category.accessibilityTag == null
          ? {}
          : {category.accessibilityTag!},
      durationRanges:
          category.durationRange == null ? {} : {category.durationRange!},
      equipments: category.equipment == null ? {} : {category.equipment!},
      recommendedOnly: false,
      sort: WorkoutLibrarySort.recommended,
    ));
  }

  void _setFilters(WorkoutLibraryFilters filters) {
    ref.read(workoutLibraryFiltersProvider.notifier).update(filters);
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
    final profile = ref.watch(fitnessProfileProvider);
    final showCategories =
        !filters.hasActiveFilters && filters.searchQuery.trim().isEmpty;        
    if (!profile.isComplete && !_didPromptProfile) {
      _didPromptProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showFitnessProfilePrompt(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Pick Workouts'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          ),
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
          _buildSearchHelpers(filters),
          const SizedBox(height: 16),
          _buildSortRow(context, filters),
          const SizedBox(height: 8),
          _buildRecommendedChip(filters),
          if (filters.recommendedOnly)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Based on your profile and energy today, we filtered these workouts.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
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
          const SizedBox(height: 6),
          Text(
            'Showing ${entries.length} workouts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            _buildEmptyState(context, filters)
          else
            _buildWorkoutResults(context, entries),
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
            onSubmitted: _commitSearch,
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
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            _setFilters(filters.copyWith(sort: value));
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            ref.read(workoutLibraryFiltersProvider.notifier).clearAll();
            _searchController.clear();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildSearchHelpers(WorkoutLibraryFilters filters) {
    if (!_searchFocus.hasFocus) {
      return const SizedBox.shrink();
    }
    final query = filters.searchQuery.trim().toLowerCase();
    final items = query.isEmpty ? _recentSearches : _buildSuggestions(query);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final title = query.isEmpty ? 'Recent searches' : 'Suggestions';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    onPressed: () => _applySearchTerm(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedChip(WorkoutLibraryFilters filters) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Recommended for You'),
          selected: filters.recommendedOnly,
          onSelected: (selected) {
            _setFilters(filters.copyWith(recommendedOnly: selected));
          },
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
    final surfaceContainerHighest = Theme.of(context).colorScheme.surfaceContainerHighest;
    final chips = <Widget>[];
    if (filters.recommendedOnly) {
      chips.add(
        InputChip(
          label: const Text('Recommended for You'),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(recommendedOnly: false));
          },
        ),
      );
    }
    for (final category in filters.primaryCategories) {
      chips.add(
        InputChip(
          label: Text(category.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              primaryCategories:
                  _removeFromSet(filters.primaryCategories, category),
            ));
          },
        ),
      );
    }
    for (final subCategory in filters.subCategories) {
      chips.add(
        InputChip(
          label: Text(subCategory),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              subCategories: _removeFromSet(filters.subCategories, subCategory),
            ));
          },
        ),
      );
    }
    for (final focus in filters.bodyFocuses) {
      chips.add(
        InputChip(
          label: Text(focus.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              bodyFocuses: _removeFromSet(filters.bodyFocuses, focus),
            ));
          },
        ),
      );
    }
    for (final goal in filters.goals) {
      chips.add(
        InputChip(
          label: Text(goal.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              goals: _removeFromSet(filters.goals, goal),
            ));
          },
        ),
      );
    }
    for (final range in filters.durationRanges) {
      chips.add(
        InputChip(
          label: Text(range.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              durationRanges: _removeFromSet(filters.durationRanges, range),    
            ));
          },
        ),
      );
    }
    for (final equipment in filters.equipments) {
      chips.add(
        InputChip(
          label: Text(equipment.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              equipments: _removeFromSet(filters.equipments, equipment),
            ));
          },
        ),
      );
    }
    for (final difficulty in filters.difficulties) {
      chips.add(
        InputChip(
          label: Text(difficulty.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              difficulties: _removeFromSet(filters.difficulties, difficulty),   
            ));
          },
        ),
      );
    }
    for (final tag in filters.conditionTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              conditionTags: _removeFromSet(filters.conditionTags, tag),        
            ));
          },
        ),
      );
    }
    for (final tag in filters.abilityTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              abilityTags: _removeFromSet(filters.abilityTags, tag),
            ));
          },
        ),
      );
    }
    for (final tag in filters.accessibilityTags) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              accessibilityTags:
                  _removeFromSet(filters.accessibilityTags, tag),
            ));
          },
        ),
      );
    }
    for (final intensity in filters.intensities) {
      chips.add(
        InputChip(
          label: Text(intensity.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              intensities: _removeFromSet(filters.intensities, intensity),
            ));
          },
        ),
      );
    }
    for (final tag in filters.healthConsiderations) {
      chips.add(
        InputChip(
          label: Text(tag.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              healthConsiderations:
                  _removeFromSet(filters.healthConsiderations, tag),
            ));
          },
        ),
      );
    }
    for (final space in filters.spaceRequirements) {
      chips.add(
        InputChip(
          label: Text(space.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              spaceRequirements:
                  _removeFromSet(filters.spaceRequirements, space),
            ));
          },
        ),
      );
    }
    for (final noise in filters.noiseLevels) {
      chips.add(
        InputChip(
          label: Text(noise.displayName),
          labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          backgroundColor: surfaceContainerHighest,
          deleteIconColor: onSurface,
          side: BorderSide(color: outline),
          onDeleted: () {
            _setFilters(filters.copyWith(
              noiseLevels: _removeFromSet(filters.noiseLevels, noise),
            ));
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
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
                      .withValues(alpha: 0.1),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
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

  Widget _buildWorkoutCard(
    BuildContext context,
    WorkoutLibraryEntry entry, {
    bool isGrid = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tagMaxWidth = constraints.maxWidth - 32;
        final tagWidgets = [
          _buildTag(
            context,
            entry.resolvedSubCategory,
            Icons.category,
            maxWidth: isGrid ? tagMaxWidth : null,
          ),
          _buildTag(
            context,
            entry.equipment.displayName,
            Icons.handyman,
            maxWidth: isGrid ? tagMaxWidth : null,
          ),
          _buildTag(
            context,
            '${entry.durationMinutes} min',
            Icons.access_time,
            maxWidth: isGrid ? tagMaxWidth : null,
          ),
          _buildTag(
            context,
            entry.difficulty.displayName,
            Icons.bar_chart,
            color: _difficultyColor(entry.difficulty),
            maxWidth: isGrid ? tagMaxWidth : null,
          ),
          _buildTag(
            context,
            entry.resolvedIntensity.displayName,
            Icons.local_fire_department,
            maxWidth: isGrid ? tagMaxWidth : null,
          ),
        ];
        final visibleTags =
            (isGrid ? tagWidgets.take(2) : tagWidgets).toList();
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
              margin: EdgeInsets.only(bottom: isGrid ? 0 : 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
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
                              maxLines: isGrid ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.targetSummary,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              maxLines: isGrid ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!isGrid) const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: visibleTags,
                  ),
                  if (!isGrid) ...[
                    const SizedBox(height: 12),
                    Text(
                      entry.previewLabel ?? 'Quick guide inside',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutResults(
    BuildContext context,
    List<WorkoutLibraryEntry> entries,
  ) {
    if (_isGridView) {
      final width = MediaQuery.of(context).size.width;
      final crossAxisCount = width >= 900
          ? 4
          : width >= 600
              ? 3
              : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          return _buildWorkoutCard(
            context,
            entries[index],
            isGrid: true,
          );
        },
      );
    }
    return Column(
      children: entries
          .map((entry) => _buildWorkoutListTile(context, entry))
          .toList(),
    );
  }

  Widget _buildWorkoutListTile(
    BuildContext context,
    WorkoutLibraryEntry entry,
  ) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            _getEntryIcon(entry),
            color: color,
          ),
        ),
        title: Text(
          entry.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '${entry.resolvedSubCategory} - ${entry.durationMinutes} min - ${entry.difficulty.displayName} - ${entry.resolvedIntensity.displayName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutLibraryDetailScreen(entry: entry),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    String label,
    IconData icon, {
    Color? color,
    double? maxWidth,
  }) {
    final tagColor = color ?? Theme.of(context).colorScheme.primary;
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: tagColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
            ),
          ),
        ],
      ),
    );
    if (maxWidth == null) return tag;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: tag,
    );
  }

  Color _difficultyColor(WorkoutDifficulty difficulty) {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return Colors.green;
      case WorkoutDifficulty.intermediate:
        return Colors.orange;
      case WorkoutDifficulty.advanced:
        return Colors.red;
    }
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    ref.read(workoutLibraryFiltersProvider.notifier).clearAll();
                  },
                ),
                if (filters.recommendedOnly)
                  _buildEmptyActionChip(
                    context,
                    'Recommended',
                    Icons.stars,
                    () {
                      _setFilters(filters.copyWith(recommendedOnly: false));
                    },
                  ),
                if (filters.primaryCategories.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Categories',
                    Icons.category,
                    () {
                      _setFilters(filters.copyWith(primaryCategories: {}));
                    },
                  ),
                if (filters.subCategories.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Sub-categories',
                    Icons.view_list,
                    () {
                      _setFilters(filters.copyWith(subCategories: {}));
                    },
                  ),
                if (filters.bodyFocuses.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Body focus',
                    Icons.fitness_center,
                    () {
                      _setFilters(filters.copyWith(bodyFocuses: {}));
                    },
                  ),
                if (filters.goals.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Goals',
                    Icons.flag,
                    () {
                      _setFilters(filters.copyWith(goals: {}));
                    },
                  ),
                if (filters.conditionTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Conditions',
                    Icons.healing,
                    () {
                      _setFilters(filters.copyWith(conditionTags: {}));
                    },
                  ),
                if (filters.abilityTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Ability',
                    Icons.accessible,
                    () {
                      _setFilters(filters.copyWith(abilityTags: {}));
                    },
                  ),
                if (filters.accessibilityTags.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Accessibility',
                    Icons.accessibility_new,
                    () {
                      _setFilters(filters.copyWith(accessibilityTags: {}));
                    },
                  ),
                if (filters.equipments.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Equipment',
                    Icons.handyman,
                    () {
                      _setFilters(filters.copyWith(equipments: {}));
                    },
                  ),
                if (filters.difficulties.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Difficulty',
                    Icons.bar_chart,
                    () {
                      _setFilters(filters.copyWith(difficulties: {}));
                    },
                  ),
                if (filters.intensities.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Intensity',
                    Icons.local_fire_department,
                    () {
                      _setFilters(filters.copyWith(intensities: {}));
                    },
                  ),
                if (filters.durationRanges.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Time',
                    Icons.timer,
                    () {
                      _setFilters(filters.copyWith(durationRanges: {}));
                    },
                  ),
                if (filters.healthConsiderations.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Health',
                    Icons.healing,
                    () {
                      _setFilters(filters.copyWith(healthConsiderations: {}));
                    },
                  ),
                if (filters.spaceRequirements.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Space',
                    Icons.open_with,
                    () {
                      _setFilters(filters.copyWith(spaceRequirements: {}));
                    },
                  ),
                if (filters.noiseLevels.isNotEmpty)
                  _buildEmptyActionChip(
                    context,
                    'Noise',
                    Icons.volume_up,
                    () {
                      _setFilters(filters.copyWith(noiseLevels: {}));
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
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
        final subCategories = workoutLibraryEntries
            .map((entry) => entry.resolvedSubCategory)
            .toSet()
            .toList()
          ..sort();
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
                  SwitchListTile(
                    title: const Text('Recommended for You'),
                    subtitle: const Text('Personalized based on your profile'),
                    value: filters.recommendedOnly,
                    onChanged: (value) {
                      _setFilters(filters.copyWith(recommendedOnly: value));
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildFilterSection(
                    context,
                    title: 'Category',
                    options: WorkoutLibraryPrimaryCategory.values,
                    selectedValues: filters.primaryCategories,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutLibraryPrimaryCategory>.from(
                        filters.primaryCategories,
                      );
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(primaryCategories: next));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Sub-category',
                    options: subCategories,
                    selectedValues: filters.subCategories,
                    labelBuilder: (value) => value,
                    onToggle: (value, selected) {
                      final next = Set<String>.from(filters.subCategories);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(subCategories: next));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Target Area',
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
                      _setFilters(filters.copyWith(bodyFocuses: next));
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
                      _setFilters(filters.copyWith(goals: next));
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
                      _setFilters(filters.copyWith(conditionTags: next));
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
                      _setFilters(filters.copyWith(abilityTags: next));
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
                      _setFilters(filters.copyWith(durationRanges: next));
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
                      _setFilters(filters.copyWith(equipments: next));
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
                      _setFilters(filters.copyWith(difficulties: next));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Intensity',
                    options: WorkoutIntensity.values,
                    selectedValues: filters.intensities,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutIntensity>.from(filters.intensities);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(intensities: next));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Health Considerations',
                    options: WorkoutHealthConsideration.values,
                    selectedValues: filters.healthConsiderations,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutHealthConsideration>.from(
                        filters.healthConsiderations,
                      );
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(healthConsiderations: next));
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
                      _setFilters(filters.copyWith(accessibilityTags: next));
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    context,
                    title: 'Space Required',
                    options: WorkoutSpaceRequirement.values,
                    selectedValues: filters.spaceRequirements,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutSpaceRequirement>.from(
                        filters.spaceRequirements,
                      );
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(spaceRequirements: next));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    title: 'Noise Level',
                    options: WorkoutNoiseLevel.values,
                    selectedValues: filters.noiseLevels,
                    labelBuilder: (value) => value.displayName,
                    onToggle: (value, selected) {
                      final next = Set<WorkoutNoiseLevel>.from(filters.noiseLevels);
                      if (selected) {
                        next.add(value);
                      } else {
                        next.remove(value);
                      }
                      _setFilters(filters.copyWith(noiseLevels: next));
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(workoutLibraryFiltersProvider.notifier)
                                .clearAll();
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
