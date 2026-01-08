import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';

final workoutLibraryFiltersProvider =
    StateProvider<WorkoutLibraryFilters>((ref) {
  return const WorkoutLibraryFilters();
});

final workoutLibraryProvider = Provider<List<WorkoutLibraryEntry>>((ref) {
  final filters = ref.watch(workoutLibraryFiltersProvider);
  final query = filters.searchQuery.trim().toLowerCase();
  var entries = workoutLibraryEntries.where((entry) {
    if (filters.bodyFocuses.isNotEmpty &&
        entry.bodyFocuses
            .where((focus) => filters.bodyFocuses.contains(focus))
            .isEmpty) {
      return false;
    }
    if (filters.goals.isNotEmpty &&
        entry.goals.where((goal) => filters.goals.contains(goal)).isEmpty) {
      return false;
    }
    if (filters.durationRanges.isNotEmpty &&
        filters.durationRanges
            .where((range) => range.contains(entry.durationMinutes))
            .isEmpty) {
      return false;
    }
    if (filters.equipments.isNotEmpty &&
        !filters.equipments.contains(entry.equipment)) {
      return false;
    }
    if (filters.difficulties.isNotEmpty &&
        !filters.difficulties.contains(entry.difficulty)) {
      return false;
    }
    if (filters.conditionTags.isNotEmpty &&
        entry.conditionSupportTags
            .where((tag) => filters.conditionTags.contains(tag))
            .isEmpty) {
      return false;
    }
    if (filters.abilityTags.isNotEmpty &&
        entry.abilityTags
            .where((tag) => filters.abilityTags.contains(tag))
            .isEmpty) {
      return false;
    }
    if (filters.accessibilityTags.isNotEmpty &&
        entry.accessibilityTags
            .where((tag) => filters.accessibilityTags.contains(tag))
            .isEmpty) {
      return false;
    }
    if (query.isEmpty) {
      return true;
    }
    final haystack = [
      entry.name,
      entry.targetSummary,
      entry.equipment.displayName,
      entry.difficulty.displayName,
      ...entry.goals.map((goal) => goal.displayName),
      ...entry.bodyFocuses.map((focus) => focus.displayName),
      ...entry.conditionSupportTags.map((tag) => tag.displayName),
      ...entry.abilityTags.map((tag) => tag.displayName),
      ...entry.accessibilityTags.map((tag) => tag.displayName),
      ...entry.alternateNames,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }).toList();

  switch (filters.sort) {
    case WorkoutLibrarySort.recommended:
      entries.sort((a, b) {
        final recommended =
            (b.isRecommended ? 1 : 0).compareTo(a.isRecommended ? 1 : 0);
        if (recommended != 0) return recommended;
        return b.addedAt.compareTo(a.addedAt);
      });
      break;
    case WorkoutLibrarySort.recentlyAdded:
      entries.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      break;
    case WorkoutLibrarySort.shortest:
      entries.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
      break;
    case WorkoutLibrarySort.noEquipment:
      entries.sort((a, b) {
        final equipment =
            (a.isBodyweight ? 0 : 1).compareTo(b.isBodyweight ? 0 : 1);
        if (equipment != 0) return equipment;
        return a.durationMinutes.compareTo(b.durationMinutes);
      });
      break;
  }

  return entries;
});

class WorkoutLibraryFilters {
  const WorkoutLibraryFilters({
    this.searchQuery = '',
    this.bodyFocuses = const {},
    this.goals = const {},
    this.durationRanges = const {},
    this.equipments = const {},
    this.difficulties = const {},
    this.conditionTags = const {},
    this.abilityTags = const {},
    this.accessibilityTags = const {},
    this.sort = WorkoutLibrarySort.recommended,
  });

  final String searchQuery;
  final Set<WorkoutBodyFocus> bodyFocuses;
  final Set<WorkoutGoal> goals;
  final Set<WorkoutDurationRange> durationRanges;
  final Set<WorkoutEquipment> equipments;
  final Set<WorkoutDifficulty> difficulties;
  final Set<WorkoutConditionTag> conditionTags;
  final Set<WorkoutAbilityTag> abilityTags;
  final Set<WorkoutAccessibilityTag> accessibilityTags;
  final WorkoutLibrarySort sort;

  WorkoutLibraryFilters copyWith({
    String? searchQuery,
    Set<WorkoutBodyFocus>? bodyFocuses,
    Set<WorkoutGoal>? goals,
    Set<WorkoutDurationRange>? durationRanges,
    Set<WorkoutEquipment>? equipments,
    Set<WorkoutDifficulty>? difficulties,
    Set<WorkoutConditionTag>? conditionTags,
    Set<WorkoutAbilityTag>? abilityTags,
    Set<WorkoutAccessibilityTag>? accessibilityTags,
    WorkoutLibrarySort? sort,
  }) {
    return WorkoutLibraryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      bodyFocuses: bodyFocuses ?? this.bodyFocuses,
      goals: goals ?? this.goals,
      durationRanges: durationRanges ?? this.durationRanges,
      equipments: equipments ?? this.equipments,
      difficulties: difficulties ?? this.difficulties,
      conditionTags: conditionTags ?? this.conditionTags,
      abilityTags: abilityTags ?? this.abilityTags,
      accessibilityTags: accessibilityTags ?? this.accessibilityTags,
      sort: sort ?? this.sort,
    );
  }

  WorkoutLibraryFilters clearAll() {
    return const WorkoutLibraryFilters();
  }

  bool get hasActiveFilters =>
      bodyFocuses.isNotEmpty ||
      goals.isNotEmpty ||
      durationRanges.isNotEmpty ||
      equipments.isNotEmpty ||
      difficulties.isNotEmpty ||
      conditionTags.isNotEmpty ||
      abilityTags.isNotEmpty ||
      accessibilityTags.isNotEmpty;
}
