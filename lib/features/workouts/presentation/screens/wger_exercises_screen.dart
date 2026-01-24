import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/workout.dart';
import '../providers/wger_workouts_provider.dart';

class WgerExercisesScreen extends ConsumerStatefulWidget {
  const WgerExercisesScreen({super.key});

  @override
  ConsumerState<WgerExercisesScreen> createState() => _WgerExercisesScreenState();
}

class _WgerExercisesScreenState extends ConsumerState<WgerExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  WorkoutCategory? _selectedCategory;
  WorkoutDifficulty? _selectedDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(wgerWorkoutsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter
                      FilterChip(
                        label: Text(_selectedCategory?.displayName ?? 'All Categories'),
                        selected: _selectedCategory != null,
                        onSelected: (_) => _showCategoryPicker(),
                      ),
                      const SizedBox(width: 8),
                      // Difficulty filter
                      FilterChip(
                        label: Text(_selectedDifficulty?.displayName ?? 'All Levels'),
                        selected: _selectedDifficulty != null,
                        onSelected: (_) => _showDifficultyPicker(),
                      ),
                      if (_selectedCategory != null || _selectedDifficulty != null) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('Clear'),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _selectedDifficulty = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: workoutsAsync.when(
              data: (workouts) {
                final filtered = _filterWorkouts(workouts);

                if (filtered.isEmpty) {
                  return _buildEmptyState(theme, workouts.isEmpty);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} exercises',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Powered by wger.de',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final workout = filtered[index];
                          return _ExerciseCard(
                            workout: workout,
                            onTap: () => _showExerciseDetails(workout),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error loading exercises'),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Workout> _filterWorkouts(List<Workout> workouts) {
    return workouts.where((workout) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final searchText = [
          workout.name,
          workout.description,
          ...?workout.tags,
        ].join(' ').toLowerCase();
        if (!searchText.contains(query)) return false;
      }

      // Category filter
      if (_selectedCategory != null && workout.category != _selectedCategory) {
        return false;
      }

      // Difficulty filter
      if (_selectedDifficulty != null && workout.difficulty != _selectedDifficulty) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState(ThemeData theme, bool noExercisesAtAll) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              noExercisesAtAll ? Icons.cloud_download : Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              noExercisesAtAll
                  ? 'No exercises synced yet'
                  : 'No exercises match your search',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noExercisesAtAll
                  ? 'Go to Settings → Admin Tools to sync exercises'
                  : 'Try adjusting your filters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Categories'),
              trailing: _selectedCategory == null ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
              },
            ),
            ...WorkoutCategory.values.map((category) => ListTile(
              title: Text(category.displayName),
              trailing: _selectedCategory == category ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _selectedCategory = category);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Levels'),
              trailing: _selectedDifficulty == null ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _selectedDifficulty = null);
                Navigator.pop(context);
              },
            ),
            ...WorkoutDifficulty.values.map((difficulty) => ListTile(
              title: Text(difficulty.displayName),
              trailing: _selectedDifficulty == difficulty ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _selectedDifficulty = difficulty);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetails(Workout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ExerciseDetailSheet(
          workout: workout,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _ExerciseCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(workout.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      workout.category.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(workout.category),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (workout.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  workout.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.fitness_center,
                    label: workout.difficulty.displayName,
                  ),
                  if (workout.equipment != null && workout.equipment!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.build,
                      label: workout.equipment!,
                    ),
                  if (workout.exercises.isNotEmpty &&
                      (workout.exercises.first.muscleGroups?.isNotEmpty ?? false))
                    _InfoChip(
                      icon: Icons.accessibility_new,
                      label: workout.exercises.first.muscleGroups!.take(2).join(', '),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return AppColors.workoutStrength;
      case WorkoutCategory.cardio:
        return AppColors.workoutCardio;
      case WorkoutCategory.flexibility:
        return AppColors.workoutFlexibility;
      case WorkoutCategory.yoga:
        return AppColors.info;
      case WorkoutCategory.hiit:
        return AppColors.warning;
      case WorkoutCategory.sports:
        return AppColors.success;
      case WorkoutCategory.other:
        return AppColors.grey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  final Workout workout;
  final ScrollController scrollController;

  const _ExerciseDetailSheet({
    required this.workout,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = workout.exercises.isNotEmpty ? workout.exercises.first : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Title
                Text(
                  workout.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Category badge
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(workout.category.displayName),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                    Chip(
                      label: Text(workout.difficulty.displayName),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                if (workout.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Muscles
                if (exercise != null && (exercise.muscleGroups?.isNotEmpty ?? false)) ...[
                  Text(
                    'Target Muscles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercise.muscleGroups!.map((muscle) => Chip(
                      label: Text(muscle),
                      avatar: const Icon(Icons.accessibility_new, size: 16),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Equipment
                if (workout.equipment != null && workout.equipment!.isNotEmpty) ...[
                  Text(
                    'Equipment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(workout.equipment!),
                    avatar: const Icon(Icons.fitness_center, size: 16),
                  ),
                  const SizedBox(height: 24),
                ],
                // Source attribution
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exercise data from wger.de - Open Source Workout Manager',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
