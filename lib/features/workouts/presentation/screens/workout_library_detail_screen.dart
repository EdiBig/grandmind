import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/exercise.dart';
import '../providers/workout_library_favorites_provider.dart';
import 'workout_logging_screen.dart';

class WorkoutLibraryDetailScreen extends ConsumerWidget {
  const WorkoutLibraryDetailScreen({super.key, required this.entry});

  final WorkoutLibraryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _categoryColor(context, entry.category);
    final favorites = ref.watch(workoutLibraryFavoritesProvider);
    final isFavorite = favorites.contains(entry.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
        actions: [
          IconButton(
            onPressed: () async {
              await ref
                  .read(workoutLibraryFavoritesProvider.notifier)
                  .toggleFavorite(entry.id);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, color),
          const SizedBox(height: 16),
          _buildTags(context),
          const SizedBox(height: 20),
          _buildTargets(context),
          const SizedBox(height: 16),
          _buildSupportTags(context),
          const SizedBox(height: 16),
          _buildInfoChips(context),
          const SizedBox(height: 20),
          _buildInstructionTiles(context),
          const SizedBox(height: 20),
          _buildActions(context, ref),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WorkoutLoggingScreen(
                    workout: _toWorkout(entry),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _focusIcon(),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.previewLabel ??
                      'Preview the movement and add it to your plan.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(context, entry.equipment.displayName),
        _buildTag(context, entry.difficulty.displayName),
        _buildTag(context, '${entry.durationMinutes} min'),
        if (entry.isCompound) _buildTag(context, 'Compound'),
        if (entry.isBodyweight) _buildTag(context, 'Bodyweight'),
        if (entry.abilityTags.isNotEmpty) _buildTag(context, 'Adapted'),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildTargets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Areas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Primary: ${entry.primaryTargets.join(', ')}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Secondary: ${entry.secondaryTargets.join(', ')}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildInfoChip(
          context,
          Icons.stars,
          entry.goals.map((goal) => goal.displayName).join(', '),
        ),
        if (entry.accessibilityTags.isNotEmpty)
          _buildInfoChip(
            context,
            Icons.accessibility_new,
            entry.accessibilityTags
                .map((tag) => tag.displayName)
                .join(', '),
          ),
        if (entry.alternateNames.isNotEmpty)
          _buildInfoChip(
            context,
            Icons.swap_horiz,
            'Also known as ${entry.alternateNames.join(', ')}',
          ),
      ],
    );
  }

  Widget _buildSupportTags(BuildContext context) {
    if (entry.conditionSupportTags.isEmpty &&
        entry.abilityTags.isEmpty &&
        entry.accessibilityTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessibility & Conditions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...entry.abilityTags
                .map((tag) => _buildTag(context, tag.displayName)),
            ...entry.conditionSupportTags
                .map((tag) => _buildTag(context, tag.displayName)),
            ...entry.accessibilityTags
                .map((tag) => _buildTag(context, tag.displayName)),
          ],
        ),
        if (entry.instructionNotes?.accessibilityConsiderations != null) ...[
          const SizedBox(height: 12),
          Text(
            entry.instructionNotes!.accessibilityConsiderations!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTiles(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text('How to'),
          children: entry.instructions
              .map(
                (step) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(step),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          title: const Text('Common mistakes'),
          children: entry.commonMistakes
              .map(
                (mistake) => ListTile(
                  leading: const Icon(Icons.error, color: Colors.redAccent),
                  title: Text(mistake),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final hasVariants = entry.variantIds.isNotEmpty;
    final isFavorite =
        ref.watch(workoutLibraryFavoritesProvider).contains(entry.id);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref
                  .read(workoutLibraryFavoritesProvider.notifier)
                  .toggleFavorite(entry.id);
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(isFavorite ? 'Favorited' : 'Favorite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasVariants
                ? () => _showVariantsSheet(context)
                : null,
            icon: const Icon(Icons.swap_horizontal_circle_outlined),
            label: const Text('Replace'),
          ),
        ),
      ],
    );
  }

  void _showVariantsSheet(BuildContext context) {
    final variants = _variantEntries();
    if (variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No variants available yet')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Swap Variants',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a variation of ${entry.name}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ...variants.map(
              (variant) => ListTile(
                leading: const Icon(Icons.swap_calls),
                title: Text(variant.name),
                subtitle: Text(
                  variant.targetSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkoutLibraryDetailScreen(entry: variant),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<WorkoutLibraryEntry> _variantEntries() {
    if (entry.variantIds.isEmpty) return [];
    return workoutLibraryEntries
        .where((item) => entry.variantIds.contains(item.id))
        .toList();
  }

  IconData _focusIcon() {
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.core)) {
      return Icons.center_focus_strong;
    }
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.glutes)) {
      return Icons.sports_gymnastics;
    }
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.back)) {
      return Icons.fitness_center;
    }
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.upper)) {
      return Icons.accessibility_new;
    }
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.arms)) {
      return Icons.fitness_center;
    }
    if (entry.bodyFocuses.contains(WorkoutBodyFocus.lower)) {
      return Icons.directions_walk;
    }
    return Icons.directions_run;
  }

  Color _categoryColor(BuildContext context, WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.strength:
        return Theme.of(context).colorScheme.primary;
      case WorkoutCategory.cardio:
        return Theme.of(context).colorScheme.secondary;
      case WorkoutCategory.yoga:
        return Theme.of(context).colorScheme.tertiary;
      case WorkoutCategory.hiit:
        return Colors.orange;
      case WorkoutCategory.flexibility:
        return Colors.teal;
      case WorkoutCategory.sports:
        return Colors.green;
      case WorkoutCategory.other:
        return Colors.grey;
    }
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
