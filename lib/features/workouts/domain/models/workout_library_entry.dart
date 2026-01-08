import 'workout.dart';

enum WorkoutBodyFocus {
  fullBody,
  upper,
  lower,
  core,
  arms,
  glutes,
  back,
}

extension WorkoutBodyFocusLabel on WorkoutBodyFocus {
  String get displayName {
    switch (this) {
      case WorkoutBodyFocus.fullBody:
        return 'Full Body';
      case WorkoutBodyFocus.upper:
        return 'Upper';
      case WorkoutBodyFocus.lower:
        return 'Lower';
      case WorkoutBodyFocus.core:
        return 'Core';
      case WorkoutBodyFocus.arms:
        return 'Arms';
      case WorkoutBodyFocus.glutes:
        return 'Glutes';
      case WorkoutBodyFocus.back:
        return 'Back';
    }
  }
}

enum WorkoutGoal {
  fatLoss,
  hypertrophy,
  strength,
  endurance,
  mobility,
  rehab,
}

extension WorkoutGoalLabel on WorkoutGoal {
  String get displayName {
    switch (this) {
      case WorkoutGoal.fatLoss:
        return 'Fat Loss';
      case WorkoutGoal.hypertrophy:
        return 'Hypertrophy';
      case WorkoutGoal.strength:
        return 'Strength';
      case WorkoutGoal.endurance:
        return 'Endurance';
      case WorkoutGoal.mobility:
        return 'Mobility';
      case WorkoutGoal.rehab:
        return 'Rehab';
    }
  }
}

enum WorkoutEquipment {
  bodyweight,
  dumbbell,
  barbell,
  resistanceBand,
  chair,
  gymMachine,
}

extension WorkoutEquipmentLabel on WorkoutEquipment {
  String get displayName {
    switch (this) {
      case WorkoutEquipment.bodyweight:
        return 'Bodyweight';
      case WorkoutEquipment.dumbbell:
        return 'Dumbbell';
      case WorkoutEquipment.barbell:
        return 'Barbell';
      case WorkoutEquipment.resistanceBand:
        return 'Resistance Band';
      case WorkoutEquipment.chair:
        return 'Chair';
      case WorkoutEquipment.gymMachine:
        return 'Gym Machine';
    }
  }
}

enum WorkoutConditionTag {
  adhd,
  arthritis,
  autism,
  jointPain,
  chronicFatigue,
  anxiety,
}

extension WorkoutConditionTagLabel on WorkoutConditionTag {
  String get displayName {
    switch (this) {
      case WorkoutConditionTag.adhd:
        return 'ADHD';
      case WorkoutConditionTag.arthritis:
        return 'Arthritis';
      case WorkoutConditionTag.autism:
        return 'Autism';
      case WorkoutConditionTag.jointPain:
        return 'Joint Pain';
      case WorkoutConditionTag.chronicFatigue:
        return 'Chronic Fatigue';
      case WorkoutConditionTag.anxiety:
        return 'Anxiety';
    }
  }
}

enum WorkoutAbilityTag {
  wheelchairFriendly,
  oneArm,
  oneLeg,
  seated,
}

extension WorkoutAbilityTagLabel on WorkoutAbilityTag {
  String get displayName {
    switch (this) {
      case WorkoutAbilityTag.wheelchairFriendly:
        return 'Wheelchair-Friendly';
      case WorkoutAbilityTag.oneArm:
        return 'One Arm';
      case WorkoutAbilityTag.oneLeg:
        return 'One Leg';
      case WorkoutAbilityTag.seated:
        return 'Seated Exercises';
    }
  }
}

enum WorkoutAccessibilityTag {
  lowImpact,
  noJumping,
  jointFriendly,
  seated,
  wheelchairAccessible,
  oneLimbOption,
  shortAttentionSpan,
}

extension WorkoutAccessibilityTagLabel on WorkoutAccessibilityTag {
  String get displayName {
    switch (this) {
      case WorkoutAccessibilityTag.lowImpact:
        return 'Low impact';
      case WorkoutAccessibilityTag.noJumping:
        return 'No jumping';
      case WorkoutAccessibilityTag.jointFriendly:
        return 'Joint-friendly';
      case WorkoutAccessibilityTag.seated:
        return 'Seated';
      case WorkoutAccessibilityTag.wheelchairAccessible:
        return 'Wheelchair accessible';
      case WorkoutAccessibilityTag.oneLimbOption:
        return 'One-limb option';
      case WorkoutAccessibilityTag.shortAttentionSpan:
        return 'Short attention span';
    }
  }
}

class WorkoutInstructionNotes {
  const WorkoutInstructionNotes({
    this.accessibilityConsiderations,
  });

  final String? accessibilityConsiderations;
}

enum WorkoutDurationRange {
  under15,
  min15to30,
  min30to45,
  min45plus,
}

extension WorkoutDurationRangeLabel on WorkoutDurationRange {
  String get displayName {
    switch (this) {
      case WorkoutDurationRange.under15:
        return '<15 min';
      case WorkoutDurationRange.min15to30:
        return '15-30 min';
      case WorkoutDurationRange.min30to45:
        return '30-45 min';
      case WorkoutDurationRange.min45plus:
        return '45+ min';
    }
  }

  bool contains(int minutes) {
    switch (this) {
      case WorkoutDurationRange.under15:
        return minutes < 15;
      case WorkoutDurationRange.min15to30:
        return minutes >= 15 && minutes < 30;
      case WorkoutDurationRange.min30to45:
        return minutes >= 30 && minutes < 45;
      case WorkoutDurationRange.min45plus:
        return minutes >= 45;
    }
  }
}

enum WorkoutLibrarySort {
  recommended,
  recentlyAdded,
  shortest,
  noEquipment,
}

extension WorkoutLibrarySortLabel on WorkoutLibrarySort {
  String get displayName {
    switch (this) {
      case WorkoutLibrarySort.recommended:
        return 'Recommended';
      case WorkoutLibrarySort.recentlyAdded:
        return 'Recently Added';
      case WorkoutLibrarySort.shortest:
        return 'Shortest';
      case WorkoutLibrarySort.noEquipment:
        return 'No Equipment';
    }
  }
}

class WorkoutLibraryEntry {
  const WorkoutLibraryEntry({
    required this.id,
    required this.name,
    required this.primaryTargets,
    required this.secondaryTargets,
    required this.difficulty,
    required this.equipment,
    required this.durationMinutes,
    required this.instructions,
    required this.commonMistakes,
    required this.bodyFocuses,
    required this.goals,
    required this.category,
    this.abilityTags = const [],
    this.accessibilityTags = const [],
    this.conditionSupportTags = const [],
    this.instructionNotes,
    required this.isBodyweight,
    required this.isCompound,
    required this.isRecommended,
    required this.addedAt,
    this.alternateNames = const [],
    this.variantIds = const [],
    this.previewLabel,
    this.recommendedSets,
    this.recommendedReps,
    this.recommendedDurationSeconds,
  });

  final String id;
  final String name;
  final List<String> primaryTargets;
  final List<String> secondaryTargets;
  final WorkoutDifficulty difficulty;
  final WorkoutEquipment equipment;
  final int durationMinutes;
  final List<String> instructions;
  final List<String> commonMistakes;
  final List<WorkoutBodyFocus> bodyFocuses;
  final List<WorkoutGoal> goals;
  final WorkoutCategory category;
  final List<WorkoutAbilityTag> abilityTags;
  final List<WorkoutAccessibilityTag> accessibilityTags;
  final List<WorkoutConditionTag> conditionSupportTags;
  final WorkoutInstructionNotes? instructionNotes;
  final bool isBodyweight;
  final bool isCompound;
  final bool isRecommended;
  final DateTime addedAt;
  final List<String> alternateNames;
  final List<String> variantIds;
  final String? previewLabel;
  final int? recommendedSets;
  final int? recommendedReps;
  final int? recommendedDurationSeconds;

  String get targetSummary =>
      [...primaryTargets, ...secondaryTargets].join(', ');
}
