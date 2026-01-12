import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinesa/core/providers/shared_preferences_provider.dart';
import '../../data/workout_library_data.dart';
import '../../domain/models/fitness_profile.dart';
import '../../domain/models/workout_library_entry.dart';
import '../../domain/models/workout.dart';
import 'fitness_profile_provider.dart';

final workoutLibraryFiltersProvider =
    StateNotifierProvider<WorkoutLibraryFiltersNotifier, WorkoutLibraryFilters>(
        (ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorkoutLibraryFiltersNotifier(prefs);
});

class WorkoutLibraryFiltersNotifier extends StateNotifier<WorkoutLibraryFilters> {
  WorkoutLibraryFiltersNotifier(this._prefs)
      : super(_loadFromPrefs(_prefs));

  static const _prefsKey = 'workout_library_filters_v1';
  final SharedPreferences _prefs;

  void update(WorkoutLibraryFilters next) {
    state = next;
    _save(next);
  }

  void clearAll() {
    update(const WorkoutLibraryFilters());
  }

  void _save(WorkoutLibraryFilters filters) {
    final data = {
      'searchQuery': filters.searchQuery,
      'bodyFocuses': _encodeEnumSet(filters.bodyFocuses),
      'goals': _encodeEnumSet(filters.goals),
      'durationRanges': _encodeEnumSet(filters.durationRanges),
      'equipments': _encodeEnumSet(filters.equipments),
      'difficulties': _encodeEnumSet(filters.difficulties),
      'conditionTags': _encodeEnumSet(filters.conditionTags),
      'abilityTags': _encodeEnumSet(filters.abilityTags),
      'accessibilityTags': _encodeEnumSet(filters.accessibilityTags),
      'primaryCategories': _encodeEnumSet(filters.primaryCategories),
      'intensities': _encodeEnumSet(filters.intensities),
      'healthConsiderations': _encodeEnumSet(filters.healthConsiderations),
      'spaceRequirements': _encodeEnumSet(filters.spaceRequirements),
      'noiseLevels': _encodeEnumSet(filters.noiseLevels),
      'subCategories': filters.subCategories.toList(),
      'recommendedOnly': filters.recommendedOnly,
      'sort': filters.sort.name,
    };
    _prefs.setString(_prefsKey, jsonEncode(data));
  }

  static WorkoutLibraryFilters _loadFromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return const WorkoutLibraryFilters();
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return WorkoutLibraryFilters(
        searchQuery: data['searchQuery'] as String? ?? '',
        bodyFocuses: _decodeEnumSet(
          data['bodyFocuses'] as List<dynamic>?,
          WorkoutBodyFocus.values,
        ),
        goals: _decodeEnumSet(
          data['goals'] as List<dynamic>?,
          WorkoutGoal.values,
        ),
        durationRanges: _decodeEnumSet(
          data['durationRanges'] as List<dynamic>?,
          WorkoutDurationRange.values,
        ),
        equipments: _decodeEnumSet(
          data['equipments'] as List<dynamic>?,
          WorkoutEquipment.values,
        ),
        difficulties: _decodeEnumSet(
          data['difficulties'] as List<dynamic>?,
          WorkoutDifficulty.values,
        ),
        conditionTags: _decodeEnumSet(
          data['conditionTags'] as List<dynamic>?,
          WorkoutConditionTag.values,
        ),
        abilityTags: _decodeEnumSet(
          data['abilityTags'] as List<dynamic>?,
          WorkoutAbilityTag.values,
        ),
        accessibilityTags: _decodeEnumSet(
          data['accessibilityTags'] as List<dynamic>?,
          WorkoutAccessibilityTag.values,
        ),
        primaryCategories: _decodeEnumSet(
          data['primaryCategories'] as List<dynamic>?,
          WorkoutLibraryPrimaryCategory.values,
        ),
        intensities: _decodeEnumSet(
          data['intensities'] as List<dynamic>?,
          WorkoutIntensity.values,
        ),
        healthConsiderations: _decodeEnumSet(
          data['healthConsiderations'] as List<dynamic>?,
          WorkoutHealthConsideration.values,
        ),
        spaceRequirements: _decodeEnumSet(
          data['spaceRequirements'] as List<dynamic>?,
          WorkoutSpaceRequirement.values,
        ),
        noiseLevels: _decodeEnumSet(
          data['noiseLevels'] as List<dynamic>?,
          WorkoutNoiseLevel.values,
        ),
        subCategories: (data['subCategories'] as List<dynamic>?)
                ?.whereType<String>()
                .toSet() ??
            {},
        recommendedOnly: data['recommendedOnly'] as bool? ?? false,
        sort: _decodeSort(data['sort'] as String?),
      );
    } catch (_) {
      return const WorkoutLibraryFilters();
    }
  }
}

List<String> _encodeEnumSet<T extends Enum>(Set<T> values) =>
    values.map((value) => value.name).toList();

Set<T> _decodeEnumSet<T>(List<dynamic>? values, List<T> all) {
  if (values == null) {
    return {};
  }
  final set = <T>{};
  for (final item in values) {
    if (item is String) {
      final match = _enumByName(all, item);
      if (match != null) {
        set.add(match);
      }
    }
  }
  return set;
}

T? _enumByName<T>(List<T> values, String name) {
  for (final value in values) {
    final enumValue = value as Enum;
    if (enumValue.name == name) {
      return value;
    }
  }
  return null;
}

WorkoutLibrarySort _decodeSort(String? value) {
  for (final sort in WorkoutLibrarySort.values) {
    if (sort.name == value) {
      return sort;
    }
  }
  return WorkoutLibrarySort.recommended;
}

final workoutLibraryProvider = Provider<List<WorkoutLibraryEntry>>((ref) {
  final filters = ref.watch(workoutLibraryFiltersProvider);
  final profile = ref.watch(fitnessProfileProvider);
  final query = filters.searchQuery.trim().toLowerCase();
  var entries = workoutLibraryEntries.where((entry) {
    if (filters.recommendedOnly && !_matchesRecommendation(entry, profile)) {
      return false;
    }
    if (filters.primaryCategories.isNotEmpty &&
        !filters.primaryCategories.contains(entry.resolvedPrimaryCategory)) {
      return false;
    }
    if (filters.subCategories.isNotEmpty &&
        !filters.subCategories.contains(entry.resolvedSubCategory)) {
      return false;
    }
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
        entry.resolvedEquipmentOptions
            .where((equipment) => filters.equipments.contains(equipment))
            .isEmpty) {
      return false;
    }
    if (filters.difficulties.isNotEmpty &&
        !filters.difficulties.contains(entry.difficulty)) {
      return false;
    }
    if (filters.intensities.isNotEmpty &&
        !filters.intensities.contains(entry.resolvedIntensity)) {
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
    if (filters.healthConsiderations.isNotEmpty &&
        entry.resolvedHealthConsiderations
            .where((tag) => filters.healthConsiderations.contains(tag))
            .isEmpty) {
      return false;
    }
    if (filters.spaceRequirements.isNotEmpty &&
        !filters.spaceRequirements.contains(entry.spaceRequirement)) {
      return false;
    }
    if (filters.noiseLevels.isNotEmpty &&
        !filters.noiseLevels.contains(entry.noiseLevel)) {
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
      entry.resolvedPrimaryCategory.displayName,
      entry.resolvedSubCategory,
      entry.resolvedIntensity.displayName,
      ...entry.goals.map((goal) => goal.displayName),
      ...entry.bodyFocuses.map((focus) => focus.displayName),
      ...entry.conditionSupportTags.map((tag) => tag.displayName),
      ...entry.abilityTags.map((tag) => tag.displayName),
      ...entry.accessibilityTags.map((tag) => tag.displayName),
      ...entry.resolvedHealthConsiderations.map((tag) => tag.displayName),
      ...entry.resolvedEquipmentOptions.map((equipment) => equipment.displayName),
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
    case WorkoutLibrarySort.longest:
      entries.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
      break;
    case WorkoutLibrarySort.alphabetical:
      entries.sort((a, b) => a.name.compareTo(b.name));
      break;
    case WorkoutLibrarySort.reverseAlphabetical:
      entries.sort((a, b) => b.name.compareTo(a.name));
      break;
    case WorkoutLibrarySort.difficultyEasy:
      entries.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
      break;
    case WorkoutLibrarySort.difficultyHard:
      entries.sort((a, b) => b.difficulty.index.compareTo(a.difficulty.index));
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
    this.primaryCategories = const {},
    this.subCategories = const {},
    this.bodyFocuses = const {},
    this.goals = const {},
    this.durationRanges = const {},
    this.equipments = const {},
    this.difficulties = const {},
    this.intensities = const {},
    this.conditionTags = const {},
    this.abilityTags = const {},
    this.accessibilityTags = const {},
    this.healthConsiderations = const {},
    this.spaceRequirements = const {},
    this.noiseLevels = const {},
    this.recommendedOnly = false,
    this.sort = WorkoutLibrarySort.recommended,
  });

  final String searchQuery;
  final Set<WorkoutLibraryPrimaryCategory> primaryCategories;
  final Set<String> subCategories;
  final Set<WorkoutBodyFocus> bodyFocuses;
  final Set<WorkoutGoal> goals;
  final Set<WorkoutDurationRange> durationRanges;
  final Set<WorkoutEquipment> equipments;
  final Set<WorkoutDifficulty> difficulties;
  final Set<WorkoutIntensity> intensities;
  final Set<WorkoutConditionTag> conditionTags;
  final Set<WorkoutAbilityTag> abilityTags;
  final Set<WorkoutAccessibilityTag> accessibilityTags;
  final Set<WorkoutHealthConsideration> healthConsiderations;
  final Set<WorkoutSpaceRequirement> spaceRequirements;
  final Set<WorkoutNoiseLevel> noiseLevels;
  final bool recommendedOnly;
  final WorkoutLibrarySort sort;

  WorkoutLibraryFilters copyWith({
    String? searchQuery,
    Set<WorkoutLibraryPrimaryCategory>? primaryCategories,
    Set<String>? subCategories,
    Set<WorkoutBodyFocus>? bodyFocuses,
    Set<WorkoutGoal>? goals,
    Set<WorkoutDurationRange>? durationRanges,
    Set<WorkoutEquipment>? equipments,
    Set<WorkoutDifficulty>? difficulties,
    Set<WorkoutIntensity>? intensities,
    Set<WorkoutConditionTag>? conditionTags,
    Set<WorkoutAbilityTag>? abilityTags,
    Set<WorkoutAccessibilityTag>? accessibilityTags,
    Set<WorkoutHealthConsideration>? healthConsiderations,
    Set<WorkoutSpaceRequirement>? spaceRequirements,
    Set<WorkoutNoiseLevel>? noiseLevels,
    bool? recommendedOnly,
    WorkoutLibrarySort? sort,
  }) {
    return WorkoutLibraryFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      primaryCategories: primaryCategories ?? this.primaryCategories,
      subCategories: subCategories ?? this.subCategories,
      bodyFocuses: bodyFocuses ?? this.bodyFocuses,
      goals: goals ?? this.goals,
      durationRanges: durationRanges ?? this.durationRanges,
      equipments: equipments ?? this.equipments,
      difficulties: difficulties ?? this.difficulties,
      intensities: intensities ?? this.intensities,
      conditionTags: conditionTags ?? this.conditionTags,
      abilityTags: abilityTags ?? this.abilityTags,
      accessibilityTags: accessibilityTags ?? this.accessibilityTags,
      healthConsiderations: healthConsiderations ?? this.healthConsiderations,
      spaceRequirements: spaceRequirements ?? this.spaceRequirements,
      noiseLevels: noiseLevels ?? this.noiseLevels,
      recommendedOnly: recommendedOnly ?? this.recommendedOnly,
      sort: sort ?? this.sort,
    );
  }

  WorkoutLibraryFilters clearAll() {
    return const WorkoutLibraryFilters();
  }

  bool get hasActiveFilters =>
      primaryCategories.isNotEmpty ||
      subCategories.isNotEmpty ||
      bodyFocuses.isNotEmpty ||
      goals.isNotEmpty ||
      durationRanges.isNotEmpty ||
      equipments.isNotEmpty ||
      difficulties.isNotEmpty ||
      intensities.isNotEmpty ||
      conditionTags.isNotEmpty ||
      abilityTags.isNotEmpty ||
      accessibilityTags.isNotEmpty ||
      healthConsiderations.isNotEmpty ||
      spaceRequirements.isNotEmpty ||
      noiseLevels.isNotEmpty ||
      recommendedOnly;
}

bool _matchesRecommendation(WorkoutLibraryEntry entry, FitnessProfile profile) {
  if (!profile.isComplete) {
    return entry.isRecommended;
  }

  if (profile.availableEquipment.isEmpty) {
    if (!entry.isBodyweight) {
      return false;
    }
  } else {
    final equipmentMatch = entry.resolvedEquipmentOptions
            .where((equipment) => profile.availableEquipment.contains(equipment))
            .isNotEmpty ||
        entry.isBodyweight;
    if (!equipmentMatch) {
      return false;
    }
  }

  if (profile.fitnessLevel != null) {
    final maxDifficulty = _difficultyIndexForLevel(profile.fitnessLevel!);
    if (entry.difficulty.index > maxDifficulty) {
      return false;
    }
  }

  if (profile.preferredDuration != null &&
      !profile.preferredDuration!.contains(entry.durationMinutes)) {
    return false;
  }

  if (profile.goals.isNotEmpty &&
      entry.goals.where((goal) => profile.goals.contains(goal)).isEmpty) {
    return false;
  }

  if (profile.energyLevel != null) {
    final energy = profile.energyLevel!;
    if (energy <= 2) {
      if (entry.resolvedIntensity == WorkoutIntensity.hiit ||
          entry.resolvedIntensity == WorkoutIntensity.high ||
          entry.durationMinutes > 30) {
        return false;
      }
    }
    if (energy >= 4 && entry.resolvedIntensity == WorkoutIntensity.low) {
      return false;
    }
  }

  if (profile.injuries.isNotEmpty) {
    final needsLowImpact = profile.injuries.any((injury) =>
        injury == FitnessInjury.knee ||
        injury == FitnessInjury.ankle ||
        injury == FitnessInjury.hip ||
        injury == FitnessInjury.back);
    if (needsLowImpact &&
        entry.resolvedHealthConsiderations
            .where((tag) =>
                tag == WorkoutHealthConsideration.lowImpact ||
                tag == WorkoutHealthConsideration.jointFriendly)
            .isEmpty) {
      return false;
    }
  }

  if (profile.medicalConditions.isNotEmpty) {
    if (profile.medicalConditions
            .contains(FitnessMedicalCondition.heartCondition) &&
        entry.resolvedIntensity == WorkoutIntensity.hiit) {
      return false;
    }
    if (profile.medicalConditions
            .contains(FitnessMedicalCondition.chronicFatigue) &&
        (entry.resolvedIntensity == WorkoutIntensity.high ||
            entry.resolvedIntensity == WorkoutIntensity.hiit ||
            entry.durationMinutes > 30)) {
      return false;
    }
    if (profile.medicalConditions
            .contains(FitnessMedicalCondition.jointCondition) &&
        entry.resolvedHealthConsiderations
            .where((tag) =>
                tag == WorkoutHealthConsideration.jointFriendly ||
                tag == WorkoutHealthConsideration.lowImpact)
            .isEmpty) {
      return false;
    }
    if (profile.medicalConditions
            .contains(FitnessMedicalCondition.pregnancy) ||
        profile.medicalConditions.contains(FitnessMedicalCondition.postpartum)) {
      final pregnancySafe = entry.resolvedHealthConsiderations
          .contains(WorkoutHealthConsideration.pregnancySafe);
      final gentleCategory = entry.category == WorkoutCategory.yoga ||
          entry.category == WorkoutCategory.flexibility;
      if (!pregnancySafe && !gentleCategory) {
        return false;
      }
    }
  }

  return true;
}

int _difficultyIndexForLevel(FitnessLevel level) {
  switch (level) {
    case FitnessLevel.completeBeginner:
    case FitnessLevel.beginner:
      return WorkoutDifficulty.beginner.index;
    case FitnessLevel.intermediate:
      return WorkoutDifficulty.intermediate.index;
    case FitnessLevel.advanced:
      return WorkoutDifficulty.advanced.index;
  }
}
