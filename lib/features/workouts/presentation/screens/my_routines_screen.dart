import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/user_saved_workout.dart';
import '../../domain/models/workout.dart';
import '../providers/saved_workouts_provider.dart';
import '../providers/workout_providers.dart';
import '../utils/workout_share_helper.dart';
import 'workout_detail_screen.dart';
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
    final templatesAsync = ref.watch(userWorkoutTemplatesProvider);
    final saved = savedAsync.value ?? const <UserSavedWorkout>[];
    final workoutIds = saved.map((item) => item.workoutId).toList();
    final detailsAsync = workoutIds.isEmpty
        ? const AsyncValue<Map<String, Workout>>.data({})
        : ref.watch(workoutsByIdsProvider(workoutIds));
    final workoutsById = detailsAsync.value ?? const <String, Workout>{};
    final templates = templatesAsync.value ?? const <Workout>[];
    final hasError = savedAsync.hasError ||
        templatesAsync.hasError ||
        detailsAsync.hasError;
    final isLoading = savedAsync.isLoading ||
        templatesAsync.isLoading ||
        detailsAsync.isLoading;

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
            icon: Icon(Icons.sort),
          ),
        ],
      ),
      body: hasError
          ? Center(
              child: Text(
                'Unable to load routines: '
                '${savedAsync.error ?? detailsAsync.error ?? templatesAsync.error}',
              ),
            )
          : Stack(
              children: [
                _buildContent(
                  context,
                  saved,
                  workoutsById,
                  templates,
                ),
                if (isLoading)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<UserSavedWorkout> saved,
    Map<String, Workout> workoutsById,
    List<Workout> templates,
  ) {
    final items = saved
        .map(
          (savedWorkout) => _RoutineItem(
            workout: workoutsById[savedWorkout.workoutId],
            saved: savedWorkout,
          ),
        )
        .toList();

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
        final workout = item.workout;
        final haystack = [
          workout?.name ?? '',
          workout?.category.displayName ?? '',
          workout?.difficulty.displayName ?? '',
          workout?.equipment ?? '',
          item.saved.folderName ?? '',
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    _sortItems(filtered);

    final filteredTemplates = _filterTemplates(templates, query);

    if (filtered.isEmpty && filteredTemplates.isEmpty) {
      return _buildEmptyState(context);
    }

    final totalCount = filtered.length + filteredTemplates.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
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
              'Showing $totalCount workouts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              if (filtered.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Saved routines',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildRoutineCard(context, filtered[index]);
                  },
                ),
              ],
              if (filteredTemplates.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'My templates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredTemplates.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildTemplateCard(context, filteredTemplates[index]);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(BuildContext context, _RoutineItem item) {
    final workout = item.workout;
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
              workout?.name ?? 'Workout unavailable',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              workout?.category.displayName ?? 'Unknown category',
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
                _buildTag(
                  context,
                  workout?.difficulty.displayName ?? 'Unknown',
                ),
                _buildTag(
                  context,
                  workout != null
                      ? '${workout.estimatedDuration} min'
                      : '-- min',
                ),
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
            Row(
              children: [
                TextButton.icon(
                  onPressed: workout == null
                      ? null
                      : () => _startWorkout(context, workout),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<_RoutineAction>(
                  onSelected: (action) =>
                      _handleRoutineAction(context, action, saved, workout),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _RoutineAction.remove,
                      child: Text('Remove'),
                    ),
                    const PopupMenuItem(
                      value: _RoutineAction.share,
                      child: Text('Share'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, Workout workout) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              workout.category.displayName,
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
                _buildTag(context, workout.difficulty.displayName),
                _buildTag(context, '${workout.estimatedDuration} min'),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _startWorkout(context, workout),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<_TemplateAction>(
                  onSelected: (action) =>
                      _handleTemplateAction(context, action, workout),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _TemplateAction.open,
                      child: Text('Open'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
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
        items.sort((a, b) {
          final nameA = a.workout?.name ?? '';
          final nameB = b.workout?.name ?? '';
          return nameA.compareTo(nameB);
        });
        break;
      case SavedWorkoutSort.duration:
        items.sort(
          (a, b) => (a.workout?.estimatedDuration ?? 0)
              .compareTo(b.workout?.estimatedDuration ?? 0),
        );
        break;
      case SavedWorkoutSort.difficulty:
        items.sort(
          (a, b) => (a.workout?.difficulty.index ?? 0)
              .compareTo(b.workout?.difficulty.index ?? 0),
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

  void _startWorkout(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutLoggingScreen(
          workout: workout,
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
      if (!context.mounted) return;
      _showMessage(context, 'Removed from My Routines.');
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Try again. ${error.toString()}');
    }
  }

  void _shareRoutine(BuildContext context, Workout workout) {
    WorkoutShareHelper.shareWorkoutFromTemplate(workout);
    _showMessage(context, 'Share sheet opened.');
  }

  void _openTemplate(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
      ),
    );
  }

  void _handleRoutineAction(
    BuildContext context,
    _RoutineAction action,
    UserSavedWorkout saved,
    Workout? workout,
  ) {
    switch (action) {
      case _RoutineAction.remove:
        _removeSavedWorkout(context, saved);
        break;
      case _RoutineAction.share:
        if (workout == null) {
          _showMessage(context, 'Workout unavailable.');
          return;
        }
        _shareRoutine(context, workout);
        break;
    }
  }

  void _handleTemplateAction(
    BuildContext context,
    _TemplateAction action,
    Workout workout,
  ) {
    switch (action) {
      case _TemplateAction.open:
        _openTemplate(context, workout);
        break;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Workout> _filterTemplates(List<Workout> templates, String query) {
    if (templates.isEmpty) return [];
    if (query.isEmpty) return templates;
    return templates.where((workout) {
      final haystack = [
        workout.name,
        workout.category.displayName,
        workout.difficulty.displayName,
        workout.equipment ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

}

enum _RoutineAction { remove, share }

enum _TemplateAction { open }

class _RoutineItem {
  const _RoutineItem({required this.workout, required this.saved});

  final Workout? workout;
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
