import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/user_saved_workout.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/exercise.dart';
import '../providers/saved_workouts_provider.dart';
import '../utils/workout_share_helper.dart';
import 'workout_logging_screen.dart';

class MyRoutinesScreen extends ConsumerStatefulWidget {
  const MyRoutinesScreen({super.key});

  @override
  ConsumerState<MyRoutinesScreen> createState() => _MyRoutinesScreenState();
}

class _MyRoutinesScreenState extends ConsumerState<MyRoutinesScreen> {
  String _query = '';
  SavedWorkoutSort _sort = SavedWorkoutSort.recentlySaved;
  String? _folderFilter;

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedWorkoutsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
        actions: [
          PopupMenuButton<SavedWorkoutSort>(
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => SavedWorkoutSort.values
                .map(
                  (sort) => PopupMenuItem(
                    value: sort,
                    child: Text(sort.displayName),
                  ),
                )
                .toList(),
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: savedAsync.when(
        data: (saved) => _buildContent(context, saved),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Unable to load routines: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<UserSavedWorkout> saved) {
    if (saved.isEmpty) {
      return _buildEmptyState(context);
    }

    final entriesById = {
      for (final entry in workoutLibraryEntries) entry.id: entry,
    };
    final items = <_RoutineItem>[];
    for (final savedWorkout in saved) {
      final entry = entriesById[savedWorkout.workoutId];
      if (entry != null) {
        items.add(_RoutineItem(entry: entry, saved: savedWorkout));
      }
    }

    final folderOptions = saved
        .map((item) => item.folderName)
        .whereType<String>()
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    var filtered = items;
    if (_folderFilter != null) {
      filtered = filtered
          .where((item) => item.saved.folderName == _folderFilter)
          .toList();
    }

    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        final haystack = [
          item.entry.name,
          item.entry.resolvedPrimaryCategory.displayName,
          item.entry.resolvedSubCategory,
          item.entry.equipment.displayName,
          item.saved.folderName ?? '',
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    _sortItems(filtered);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search saved workouts',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (folderOptions.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _folderFilter == null,
                  onSelected: (_) => setState(() => _folderFilter = null),
                ),
                const SizedBox(width: 8),
                ...folderOptions.map(
                  (folder) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(folder),
                      selected: _folderFilter == folder,
                      onSelected: (_) =>
                          setState(() => _folderFilter = folder),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${filtered.length} workouts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildRoutineCard(context, filtered[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(BuildContext context, _RoutineItem item) {
    final entry = item.entry;
    final saved = item.saved;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              entry.resolvedSubCategory,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTag(context, entry.difficulty.displayName),
                _buildTag(context, '${entry.durationMinutes} min'),
              ],
            ),
            if (saved.folderName != null && saved.folderName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTag(context, saved.folderName!),
            ],
            const SizedBox(height: 8),
            Text(
              'Saved ${_formatTimeAgo(saved.savedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TextButton.icon(
                  onPressed: () => _startWorkout(context, entry),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start'),
                ),
                TextButton.icon(
                  onPressed: () => _removeSavedWorkout(context, saved),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                ),
                TextButton.icon(
                  onPressed: () => _shareRoutine(context, entry),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No routines saved yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save workouts from the library to build routines you can reuse.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _sortItems(List<_RoutineItem> items) {
    switch (_sort) {
      case SavedWorkoutSort.recentlySaved:
        items.sort((a, b) => b.saved.savedAt.compareTo(a.saved.savedAt));
        break;
      case SavedWorkoutSort.name:
        items.sort((a, b) => a.entry.name.compareTo(b.entry.name));
        break;
      case SavedWorkoutSort.duration:
        items.sort(
          (a, b) => a.entry.durationMinutes.compareTo(b.entry.durationMinutes),
        );
        break;
      case SavedWorkoutSort.difficulty:
        items.sort(
          (a, b) => a.entry.difficulty.index.compareTo(b.entry.difficulty.index),
        );
        break;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _startWorkout(BuildContext context, WorkoutLibraryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutLoggingScreen(
          workout: _toWorkout(entry),
        ),
      ),
    );
  }

  Future<void> _removeSavedWorkout(
    BuildContext context,
    UserSavedWorkout saved,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage(context, 'Sign in to manage routines.');
      return;
    }
    try {
      await ref.read(workoutRepositoryProvider).removeSavedWorkout(saved.id);
      _showMessage(context, 'Removed from My Routines.');
    } catch (error) {
      _showMessage(context, 'Try again. ${error.toString()}');
    }
  }

  void _shareRoutine(BuildContext context, WorkoutLibraryEntry entry) {
    WorkoutShareHelper.shareWorkout(entry);
    _showMessage(context, 'Share sheet opened.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Workout _toWorkout(WorkoutLibraryEntry entry) {
    final metrics = ExerciseMetrics(
      sets: entry.recommendedSets,
      reps: entry.recommendedReps,
      duration: entry.recommendedDurationSeconds,
    );
    final exerciseType = entry.recommendedDurationSeconds != null
        ? ExerciseType.duration
        : ExerciseType.reps;

    return Workout(
      id: 'library-${entry.id}',
      name: entry.name,
      description: entry.targetSummary,
      difficulty: entry.difficulty,
      estimatedDuration: entry.durationMinutes,
      category: entry.category,
      exercises: [
        Exercise(
          id: entry.id,
          name: entry.name,
          description: entry.instructions.join(' '),
          type: exerciseType,
          muscleGroups: [
            ...entry.primaryTargets,
            ...entry.secondaryTargets,
          ],
          equipment: entry.equipment.displayName,
          metrics: metrics,
        ),
      ],
      tags: [
        ...entry.goals.map((goal) => goal.displayName),
        if (entry.isBodyweight) 'Bodyweight',
        if (entry.isCompound) 'Compound',
      ],
    );
  }
}

class _RoutineItem {
  const _RoutineItem({required this.entry, required this.saved});

  final WorkoutLibraryEntry entry;
  final UserSavedWorkout saved;
}

enum SavedWorkoutSort {
  recentlySaved,
  name,
  duration,
  difficulty,
}

extension SavedWorkoutSortLabel on SavedWorkoutSort {
  String get displayName {
    switch (this) {
      case SavedWorkoutSort.recentlySaved:
        return 'Recently Saved';
      case SavedWorkoutSort.name:
        return 'Name';
      case SavedWorkoutSort.duration:
        return 'Duration';
      case SavedWorkoutSort.difficulty:
        return 'Difficulty';
    }
  }
}
