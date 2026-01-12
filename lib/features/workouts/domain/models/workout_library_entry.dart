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
  kettlebell,
  pullUpBar,
  cardioMachine,
  yogaMat,
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
      case WorkoutEquipment.kettlebell:
        return 'Kettlebell';
      case WorkoutEquipment.pullUpBar:
        return 'Pull-up Bar';
      case WorkoutEquipment.cardioMachine:
        return 'Cardio Machine';
      case WorkoutEquipment.yogaMat:
        return 'Yoga Mat';
    }
  }
}

enum WorkoutLibraryPrimaryCategory {
  strengthTraining,
  cardio,
  flexibilityMobility,
  mindBody,
  rehabRecovery,
  specialized,
}

extension WorkoutLibraryPrimaryCategoryLabel on WorkoutLibraryPrimaryCategory {
  String get displayName {
    switch (this) {
      case WorkoutLibraryPrimaryCategory.strengthTraining:
        return 'Strength Training';
      case WorkoutLibraryPrimaryCategory.cardio:
        return 'Cardio';
      case WorkoutLibraryPrimaryCategory.flexibilityMobility:
        return 'Flexibility & Mobility';
      case WorkoutLibraryPrimaryCategory.mindBody:
        return 'Mind-Body';
      case WorkoutLibraryPrimaryCategory.rehabRecovery:
        return 'Rehabilitation & Recovery';
      case WorkoutLibraryPrimaryCategory.specialized:
        return 'Specialized Training';
    }
  }
}

enum WorkoutIntensity {
  low,
  moderate,
  high,
  hiit,
}

extension WorkoutIntensityLabel on WorkoutIntensity {
  String get displayName {
    switch (this) {
      case WorkoutIntensity.low:
        return 'Low';
      case WorkoutIntensity.moderate:
        return 'Moderate';
      case WorkoutIntensity.high:
        return 'High';
      case WorkoutIntensity.hiit:
        return 'HIIT';
    }
  }
}

enum WorkoutSpaceRequirement {
  smallSpace,
  fullRoom,
  outdoor,
}

extension WorkoutSpaceRequirementLabel on WorkoutSpaceRequirement {
  String get displayName {
    switch (this) {
      case WorkoutSpaceRequirement.smallSpace:
        return 'Small Space';
      case WorkoutSpaceRequirement.fullRoom:
        return 'Full Room';
      case WorkoutSpaceRequirement.outdoor:
        return 'Outdoor';
    }
  }
}

enum WorkoutNoiseLevel {
  quiet,
  any,
}

extension WorkoutNoiseLevelLabel on WorkoutNoiseLevel {
  String get displayName {
    switch (this) {
      case WorkoutNoiseLevel.quiet:
        return 'Quiet';
      case WorkoutNoiseLevel.any:
        return 'Any';
    }
  }
}

enum WorkoutHealthConsideration {
  lowImpact,
  pregnancySafe,
  jointFriendly,
  heartConditionSafe,
}

extension WorkoutHealthConsiderationLabel on WorkoutHealthConsideration {
  String get displayName {
    switch (this) {
      case WorkoutHealthConsideration.lowImpact:
        return 'Low Impact';
      case WorkoutHealthConsideration.pregnancySafe:
        return 'Pregnancy Safe';
      case WorkoutHealthConsideration.jointFriendly:
        return 'Joint Friendly';
      case WorkoutHealthConsideration.heartConditionSafe:
        return 'Heart Condition Safe';
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
  under10,
  min10to20,
  min20to30,
  min30to45,
  min45to60,
  min60plus,
}

extension WorkoutDurationRangeLabel on WorkoutDurationRange {
  String get displayName {
    switch (this) {
      case WorkoutDurationRange.under10:
        return '<10 min';
      case WorkoutDurationRange.min10to20:
        return '10-20 min';
      case WorkoutDurationRange.min20to30:
        return '20-30 min';
      case WorkoutDurationRange.min30to45:
        return '30-45 min';
      case WorkoutDurationRange.min45to60:
        return '45-60 min';
      case WorkoutDurationRange.min60plus:
        return '60+ min';
    }
  }

  bool contains(int minutes) {
    switch (this) {
      case WorkoutDurationRange.under10:
        return minutes < 10;
      case WorkoutDurationRange.min10to20:
        return minutes >= 10 && minutes < 20;
      case WorkoutDurationRange.min20to30:
        return minutes >= 20 && minutes < 30;
      case WorkoutDurationRange.min30to45:
        return minutes >= 30 && minutes < 45;
      case WorkoutDurationRange.min45to60:
        return minutes >= 45 && minutes < 60;
      case WorkoutDurationRange.min60plus:
        return minutes >= 60;
    }
  }
}

enum WorkoutLibrarySort {
  recommended,
  recentlyAdded,
  shortest,
  longest,
  alphabetical,
  reverseAlphabetical,
  difficultyEasy,
  difficultyHard,
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
      case WorkoutLibrarySort.longest:
        return 'Longest';
      case WorkoutLibrarySort.alphabetical:
        return 'A-Z';
      case WorkoutLibrarySort.reverseAlphabetical:
        return 'Z-A';
      case WorkoutLibrarySort.difficultyEasy:
        return 'Beginner -> Advanced';
      case WorkoutLibrarySort.difficultyHard:
        return 'Advanced -> Beginner';
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
    this.primaryCategory,
    this.subCategory = 'General',
    this.intensity = WorkoutIntensity.moderate,
    this.equipmentOptions = const [],
    this.healthConsiderations = const [],
    this.spaceRequirement = WorkoutSpaceRequirement.smallSpace,
    this.noiseLevel = WorkoutNoiseLevel.any,
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
  final WorkoutLibraryPrimaryCategory? primaryCategory;
  final String subCategory;
  final WorkoutIntensity intensity;
  final List<WorkoutEquipment> equipmentOptions;
  final List<WorkoutHealthConsideration> healthConsiderations;
  final WorkoutSpaceRequirement spaceRequirement;
  final WorkoutNoiseLevel noiseLevel;
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

  WorkoutLibraryPrimaryCategory get resolvedPrimaryCategory {
    if (primaryCategory != null) {
      return primaryCategory!;
    }
    switch (category) {
      case WorkoutCategory.strength:
        return WorkoutLibraryPrimaryCategory.strengthTraining;
      case WorkoutCategory.cardio:
      case WorkoutCategory.hiit:
        return WorkoutLibraryPrimaryCategory.cardio;
      case WorkoutCategory.flexibility:
      case WorkoutCategory.yoga:
        return WorkoutLibraryPrimaryCategory.flexibilityMobility;
      case WorkoutCategory.sports:
        return WorkoutLibraryPrimaryCategory.specialized;
      case WorkoutCategory.other:
        return WorkoutLibraryPrimaryCategory.specialized;
    }
  }

  List<WorkoutEquipment> get resolvedEquipmentOptions =>
      equipmentOptions.isNotEmpty ? equipmentOptions : [equipment];

  WorkoutIntensity get resolvedIntensity {
    if (intensity != WorkoutIntensity.moderate) {
      return intensity;
    }
    if (category == WorkoutCategory.hiit) {
      return WorkoutIntensity.hiit;
    }
    if (difficulty == WorkoutDifficulty.advanced || durationMinutes >= 45) {
      return WorkoutIntensity.high;
    }
    if (difficulty == WorkoutDifficulty.beginner && durationMinutes <= 15) {
      return WorkoutIntensity.low;
    }
    return intensity;
  }

  List<WorkoutHealthConsideration> get resolvedHealthConsiderations {
    final resolved = <WorkoutHealthConsideration>{
      ...healthConsiderations,
    };
    if (accessibilityTags.contains(WorkoutAccessibilityTag.lowImpact) ||
        accessibilityTags.contains(WorkoutAccessibilityTag.noJumping)) {
      resolved.add(WorkoutHealthConsideration.lowImpact);
    }
    if (accessibilityTags.contains(WorkoutAccessibilityTag.jointFriendly) ||
        conditionSupportTags.contains(WorkoutConditionTag.arthritis) ||
        conditionSupportTags.contains(WorkoutConditionTag.jointPain)) {
      resolved.add(WorkoutHealthConsideration.jointFriendly);
    }
    return resolved.toList();
  }

  String get resolvedSubCategory {
    if (subCategory.trim().isNotEmpty && subCategory != 'General') {
      return subCategory;
    }
    if (category == WorkoutCategory.strength) {
      if (bodyFocuses.contains(WorkoutBodyFocus.lower) ||
          bodyFocuses.contains(WorkoutBodyFocus.glutes)) {
        return 'Lower Body';
      }
      if (bodyFocuses.contains(WorkoutBodyFocus.core)) {
        return 'Core & Abs';
      }
      if (bodyFocuses.contains(WorkoutBodyFocus.back)) {
        return 'Upper Body Pull';
      }
      if (bodyFocuses.contains(WorkoutBodyFocus.upper) ||
          bodyFocuses.contains(WorkoutBodyFocus.arms)) {
        return 'Upper Body Push';
      }
      return 'Full Body Strength';
    }
    if (category == WorkoutCategory.cardio || category == WorkoutCategory.hiit) {
      return 'Cardio';
    }
    if (category == WorkoutCategory.yoga) {
      return 'Yoga';
    }
    if (category == WorkoutCategory.flexibility) {
      return 'Mobility & Stretching';
    }
    if (category == WorkoutCategory.sports) {
      return 'Sports';
    }
    return 'General';
  }

  String get targetSummary =>
      [...primaryTargets, ...secondaryTargets].join(', ');
}
