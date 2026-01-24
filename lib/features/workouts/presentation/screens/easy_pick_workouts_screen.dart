import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/workout.dart';
import '../providers/workout_providers.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/services/algolia_search_service.dart';
import 'workout_detail_screen.dart';
import 'create_workout_template_screen.dart';
import 'workout_logging_screen.dart';

class EasyPickWorkoutsScreen extends ConsumerStatefulWidget {
  const EasyPickWorkoutsScreen({super.key});

  @override
  ConsumerState<EasyPickWorkoutsScreen> createState() =>
      _EasyPickWorkoutsScreenState();
}

class _EasyPickWorkoutsScreenState extends ConsumerState<EasyPickWorkoutsScreen> {
  final _searchController = TextEditingController();
  EasyPickSort _sort = EasyPickSort.recommended;
  String _query = '';
  WorkoutDifficulty? _difficultyFilter;
  String? _equipmentFilter;
  bool _includeTemplates = true;
  bool _includeUserWorkouts = true;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Easy Pick Workouts'),
          actions: [
            PopupMenuButton<EasyPickSort>(
              onSelected: (value) => setState(() => _sort = value),
              itemBuilder: (context) => EasyPickSort.values
                  .map(
                    (sort) => PopupMenuItem(
                      value: sort,
                      child: Text(sort.displayName),
                    ),
                  )
                  .toList(),
              icon: Icon(Icons.sort),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Quick Picks'),
              Tab(text: 'My Workouts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkoutsTab(context, ref, isMyWorkoutsTab: false),
            _buildWorkoutsTab(context, ref, isMyWorkoutsTab: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutsTab(
    BuildContext context,
    WidgetRef ref, {
    required bool isMyWorkoutsTab,
  }) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (isMyWorkoutsTab && userId == null) {
      return Center(
        child: Text(
          'Sign in to view your workouts.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final includeTemplates = isMyWorkoutsTab ? false : _includeTemplates;
    final includeUserWorkouts = isMyWorkoutsTab ? true : _includeUserWorkouts;
    final createdBy = isMyWorkoutsTab ? userId : null;
    final hasFilters = _difficultyFilter != null ||
        (_equipmentFilter?.isNotEmpty ?? false) ||
        includeTemplates != includeUserWorkouts ||
        createdBy != null;
    final useAlgolia = AlgoliaConfig.isValid &&
        (_query.trim().isNotEmpty || hasFilters);
    final workoutsAsync = useAlgolia
        ? ref.watch(
            workoutsSearchProvider(
              WorkoutSearchRequest(
                query: _query,
                difficulty: _difficultyFilter,
                equipment: _equipmentFilter,
                includeTemplates: includeTemplates,
                includeUserWorkouts: includeUserWorkouts,
                createdBy: createdBy,
              ),
            ),
          )
        : _buildFallbackWorkouts(
            ref,
            userId: userId,
            includeTemplates: includeTemplates,
            includeUserWorkouts: includeUserWorkouts,
          );
    final favoritesAsync = ref.watch(workoutFavoritesProvider);

    return workoutsAsync.when(
      data: (workouts) {
        final favorites = favoritesAsync.maybeWhen(
          data: (items) => items,
          orElse: () => <String>{},
        );
        final filtered = _applyFilters(
          workouts,
          favorites: favorites,
          applyClientFilters: !useAlgolia,
          includeTemplates: includeTemplates,
          includeUserWorkouts: includeUserWorkouts,
          createdBy: createdBy,
        );
        final equipmentOptions = _collectEquipmentOptions(workouts);
        final favoriteWorkouts = filtered
            .where((workout) => favorites.contains(workout.id))
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSearchField(context),
            const SizedBox(height: 12),
            _buildFilterRow(
              context,
              equipmentOptions,
              isMyWorkoutsTab: isMyWorkoutsTab,
            ),
            const SizedBox(height: 12),
            Text(
              'Showing ${filtered.length} workouts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            if (!isMyWorkoutsTab &&
                _query.trim().isEmpty &&
                favoriteWorkouts.isNotEmpty) ...[
              _buildFavoritesSection(context, favoriteWorkouts, favorites),
              const SizedBox(height: 20),
            ],
            if (filtered.isEmpty)
              isMyWorkoutsTab
                  ? _buildMyWorkoutsEmptyState(context)
                  : _buildEmptyState(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildWorkoutCard(
                  context,
                  filtered[index],
                  favorites,
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading workouts: $error'),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search workouts',
        prefixIcon: Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No workouts found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyWorkoutsEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No personal workouts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a template and keep it here for quick access.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const CreateWorkoutTemplateScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, size: 18),
                    label: const Text('Create Workout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (context) => WorkoutLoggingScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: const Text('Log Workout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    Workout workout,
    Set<String> favorites,
  ) {
    final color = _getCategoryColor(context, workout.category);
    final icon = _getCategoryIcon(workout.category);
    final isFavorite = favorites.contains(workout.id);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 56, color: AppColors.white),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.white,
                  ),
                  onPressed: () => _toggleFavorite(workout),
                  tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.access_time,
                      '${workout.estimatedDuration} min',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      Icons.bar_chart,
                      workout.difficulty.displayName,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkoutDetailScreen(workoutId: workout.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Start Workout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  List<Workout> _applyFilters(
    List<Workout> workouts, {
    required Set<String> favorites,
    required bool applyClientFilters,
    required bool includeTemplates,
    required bool includeUserWorkouts,
    required String? createdBy,
  }) {
    final query = _query.trim().toLowerCase();
    var filtered = workouts.where((workout) {
      if (_favoritesOnly && !favorites.contains(workout.id)) {
        return false;
      }
      if (!applyClientFilters) {
        return true;
      }
      if (createdBy != null && workout.createdBy != createdBy) {
        return false;
      }
      if (!includeTemplates && workout.createdBy == null) {
        return false;
      }
      if (!includeUserWorkouts && workout.createdBy != null) {
        return false;
      }
      if (_difficultyFilter != null &&
          workout.difficulty != _difficultyFilter) {
        return false;
      }
      if (_equipmentFilter != null && _equipmentFilter!.isNotEmpty) {
        final equipment = workout.equipment?.toLowerCase() ?? '';
        if (!equipment.contains(_equipmentFilter!.toLowerCase())) {
          return false;
        }
      }
      if (query.isNotEmpty) {
        final tags = workout.tags ?? const <String>[];
        final haystack = [
          workout.name,
          workout.description,
          workout.difficulty.displayName,
          workout.category.displayName,
          workout.equipment ?? '',
          ...tags,
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }
      return true;
    }).toList();

    switch (_sort) {
      case EasyPickSort.recommended:
        filtered.sort((a, b) {
          final aScore = a.difficulty.index;
          final bScore = b.difficulty.index;
          return aScore.compareTo(bScore);
        });
        break;
      case EasyPickSort.shortest:
        filtered.sort(
            (a, b) => a.estimatedDuration.compareTo(b.estimatedDuration));
        break;
      case EasyPickSort.longest:
        filtered.sort(
            (a, b) => b.estimatedDuration.compareTo(a.estimatedDuration));
        break;
      case EasyPickSort.alphabetical:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case EasyPickSort.difficultyEasy:
        filtered.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
        break;
      case EasyPickSort.difficultyHard:
        filtered.sort((a, b) => b.difficulty.index.compareTo(a.difficulty.index));
        break;
    }
    return filtered;
  }

  Widget _buildFavoritesSection(
    BuildContext context,
    List<Workout> favoritesList,
    Set<String> favorites,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorites',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favoritesList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 200,
              child: _buildWorkoutCard(
                context,
                favoritesList[index],
                favorites,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(
    BuildContext context,
    List<String> equipmentOptions, {
    required bool isMyWorkoutsTab,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: Text(
            _difficultyFilter == null
                ? 'Difficulty: All'
                : 'Difficulty: ${_difficultyFilter!.displayName}',
          ),
          selected: _difficultyFilter != null,
          onSelected: (_) => _showDifficultySheet(context),
        ),
        FilterChip(
          label: Text(
            _equipmentFilter == null || _equipmentFilter!.isEmpty
                ? 'Equipment: All'
                : 'Equipment: $_equipmentFilter',
          ),
          selected: _equipmentFilter != null && _equipmentFilter!.isNotEmpty,
          onSelected: (_) => _showEquipmentSheet(context, equipmentOptions),
        ),
        if (!isMyWorkoutsTab) ...[
          FilterChip(
            label: const Text('Favorites'),
            selected: _favoritesOnly,
            onSelected: (value) => setState(() => _favoritesOnly = value),
          ),
          FilterChip(
            label: const Text('Templates'),
            selected: _includeTemplates,
            onSelected: (value) => setState(() => _includeTemplates = value),
          ),
          FilterChip(
            label: const Text('My Workouts'),
            selected: _includeUserWorkouts,
            onSelected: (value) => setState(() => _includeUserWorkouts = value),
          ),
        ],
      ],
    );
  }

  Future<void> _showDifficultySheet(BuildContext context) async {
    final selected = await showModalBottomSheet<WorkoutDifficulty?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const ListTile(
            title: Text('Difficulty'),
          ),
          ListTile(
            title: const Text('All'),
            onTap: () => Navigator.pop(context, null),
          ),
          ...WorkoutDifficulty.values.map(
            (difficulty) => ListTile(
              title: Text(difficulty.displayName),
              onTap: () => Navigator.pop(context, difficulty),
            ),
          ),
        ],
      ),
    );
    if (selected == null) {
      setState(() => _difficultyFilter = null);
      return;
    }
    setState(() => _difficultyFilter = selected);
  }

  Future<void> _showEquipmentSheet(
    BuildContext context,
    List<String> equipmentOptions,
  ) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const ListTile(
            title: Text('Equipment'),
          ),
          ListTile(
            title: const Text('All'),
            onTap: () => Navigator.pop(context, null),
          ),
          ...equipmentOptions.map(
            (equipment) => ListTile(
              title: Text(equipment),
              onTap: () {
                Navigator.pop(context, equipment);
              },
            ),
          ),
        ],
      ),
    );
    if (selected == null) {
      setState(() => _equipmentFilter = null);
      return;
    }
    setState(() => _equipmentFilter = selected);
  }

  List<String> _collectEquipmentOptions(List<Workout> workouts) {
    final options = <String>{};
    for (final workout in workouts) {
      final equipment = workout.equipment?.trim();
      if (equipment != null && equipment.isNotEmpty) {
        options.add(equipment);
      }
    }
    final list = options.toList()..sort();
    return list;
  }

  Future<void> _toggleFavorite(Workout workout) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final repository = ref.read(workoutRepositoryProvider);
    await repository.toggleWorkoutFavorite(userId, workout);
  }

  Color _getCategoryColor(BuildContext context, WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Theme.of(context).colorScheme.primary;
      case WorkoutCategory.cardio:
        return Theme.of(context).colorScheme.secondary;
      case WorkoutCategory.yoga:
        return Theme.of(context).colorScheme.tertiary;
      case WorkoutCategory.hiit:
        return AppColors.warning;
      case WorkoutCategory.flexibility:
        return AppColors.workoutFlexibility;
      case WorkoutCategory.sports:
        return AppColors.success;
      case WorkoutCategory.other:
        return AppColors.grey;
    }
  }

  IconData _getCategoryIcon(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Icons.fitness_center;
      case WorkoutCategory.cardio:
        return Icons.directions_run;
      case WorkoutCategory.yoga:
        return Icons.self_improvement;
      case WorkoutCategory.hiit:
        return Icons.local_fire_department;
      case WorkoutCategory.flexibility:
        return Icons.accessibility_new;
      case WorkoutCategory.sports:
        return Icons.sports_basketball;
      case WorkoutCategory.other:
        return Icons.local_activity;
    }
  }

  AsyncValue<List<Workout>> _buildFallbackWorkouts(
    WidgetRef ref, {
    required String? userId,
    required bool includeTemplates,
    required bool includeUserWorkouts,
  }) {
    if (!includeTemplates && !includeUserWorkouts) {
      return const AsyncValue.data([]);
    }

    if (!includeUserWorkouts || userId == null) {
      return ref.watch(workoutsProvider(const WorkoutFilters()));
    }

    if (!includeTemplates) {
      return ref.watch(userWorkoutTemplatesProvider);
    }

    final templatesAsync = ref.watch(workoutsProvider(const WorkoutFilters()));
    final userAsync = ref.watch(userWorkoutTemplatesProvider);
    return _mergeWorkoutStreams(templatesAsync, userAsync);
  }

  AsyncValue<List<Workout>> _mergeWorkoutStreams(
    AsyncValue<List<Workout>> templatesAsync,
    AsyncValue<List<Workout>> userAsync,
  ) {
    return templatesAsync.when(
      data: (templates) => userAsync.when(
        data: (userWorkouts) =>
            AsyncValue.data([...templates, ...userWorkouts]),
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      ),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }
}

enum EasyPickSort {
  recommended,
  shortest,
  longest,
  alphabetical,
  difficultyEasy,
  difficultyHard,
}

extension EasyPickSortLabel on EasyPickSort {
  String get displayName {
    switch (this) {
      case EasyPickSort.recommended:
        return 'Recommended';
      case EasyPickSort.shortest:
        return 'Shortest';
      case EasyPickSort.longest:
        return 'Longest';
      case EasyPickSort.alphabetical:
        return 'Alphabetical';
      case EasyPickSort.difficultyEasy:
        return 'Easy first';
      case EasyPickSort.difficultyHard:
        return 'Hard first';
    }
  }
}
