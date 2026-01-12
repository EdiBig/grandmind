import 'workout_library_entry.dart';

enum FitnessLevel {
  completeBeginner,
  beginner,
  intermediate,
  advanced,
}

extension FitnessLevelLabel on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.completeBeginner:
        return 'Complete Beginner';
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
    }
  }
}

enum FitnessInjury {
  knee,
  back,
  shoulder,
  ankle,
  hip,
  other,
}

extension FitnessInjuryLabel on FitnessInjury {
  String get displayName {
    switch (this) {
      case FitnessInjury.knee:
        return 'Knee pain/injury';
      case FitnessInjury.back:
        return 'Back pain/injury';
      case FitnessInjury.shoulder:
        return 'Shoulder pain/injury';
      case FitnessInjury.ankle:
        return 'Ankle pain/injury';
      case FitnessInjury.hip:
        return 'Hip pain/injury';
      case FitnessInjury.other:
        return 'Other';
    }
  }
}

enum FitnessMedicalCondition {
  heartCondition,
  highBloodPressure,
  diabetes,
  asthma,
  pregnancy,
  postpartum,
  chronicFatigue,
  jointCondition,
  other,
}

extension FitnessMedicalConditionLabel on FitnessMedicalCondition {
  String get displayName {
    switch (this) {
      case FitnessMedicalCondition.heartCondition:
        return 'Heart condition';
      case FitnessMedicalCondition.highBloodPressure:
        return 'High blood pressure';
      case FitnessMedicalCondition.diabetes:
        return 'Diabetes';
      case FitnessMedicalCondition.asthma:
        return 'Asthma';
      case FitnessMedicalCondition.pregnancy:
        return 'Pregnancy';
      case FitnessMedicalCondition.postpartum:
        return 'Postpartum';
      case FitnessMedicalCondition.chronicFatigue:
        return 'Chronic fatigue';
      case FitnessMedicalCondition.jointCondition:
        return 'Joint condition';
      case FitnessMedicalCondition.other:
        return 'Other';
    }
  }
}

enum WorkoutLocation {
  homeSmall,
  homeLarge,
  gym,
  outdoor,
  multiple,
}

extension WorkoutLocationLabel on WorkoutLocation {
  String get displayName {
    switch (this) {
      case WorkoutLocation.homeSmall:
        return 'Home (Small Space)';
      case WorkoutLocation.homeLarge:
        return 'Home (Large Space)';
      case WorkoutLocation.gym:
        return 'Gym';
      case WorkoutLocation.outdoor:
        return 'Outdoor';
      case WorkoutLocation.multiple:
        return 'Multiple Locations';
    }
  }
}

class FitnessProfile {
  const FitnessProfile({
    this.fitnessLevel,
    this.injuries = const {},
    this.medicalConditions = const {},
    this.availableEquipment = const {},
    this.workoutLocation,
    this.preferredDuration,
    this.goals = const {},
    this.energyLevel,
    this.updatedAt,
  });

  final FitnessLevel? fitnessLevel;
  final Set<FitnessInjury> injuries;
  final Set<FitnessMedicalCondition> medicalConditions;
  final Set<WorkoutEquipment> availableEquipment;
  final WorkoutLocation? workoutLocation;
  final WorkoutDurationRange? preferredDuration;
  final Set<WorkoutGoal> goals;
  final int? energyLevel;
  final DateTime? updatedAt;

  bool get isComplete =>
      fitnessLevel != null &&
      availableEquipment.isNotEmpty &&
      preferredDuration != null;

  FitnessProfile copyWith({
    FitnessLevel? fitnessLevel,
    Set<FitnessInjury>? injuries,
    Set<FitnessMedicalCondition>? medicalConditions,
    Set<WorkoutEquipment>? availableEquipment,
    WorkoutLocation? workoutLocation,
    WorkoutDurationRange? preferredDuration,
    Set<WorkoutGoal>? goals,
    int? energyLevel,
    DateTime? updatedAt,
  }) {
    return FitnessProfile(
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      preferredDuration: preferredDuration ?? this.preferredDuration,
      goals: goals ?? this.goals,
      energyLevel: energyLevel ?? this.energyLevel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fitnessLevel': fitnessLevel?.name,
      'injuries': injuries.map((item) => item.name).toList(),
      'medicalConditions': medicalConditions.map((item) => item.name).toList(),
      'availableEquipment': availableEquipment.map((item) => item.name).toList(),
      'workoutLocation': workoutLocation?.name,
      'preferredDuration': preferredDuration?.name,
      'goals': goals.map((item) => item.name).toList(),
      'energyLevel': energyLevel,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FitnessProfile.fromJson(Map<String, dynamic> json) {
    return FitnessProfile(
      fitnessLevel: _decodeEnum(json['fitnessLevel'] as String?, FitnessLevel.values),
      injuries: _decodeEnumSet(json['injuries'], FitnessInjury.values),
      medicalConditions: _decodeEnumSet(
        json['medicalConditions'],
        FitnessMedicalCondition.values,
      ),
      availableEquipment: _decodeEnumSet(
        json['availableEquipment'],
        WorkoutEquipment.values,
      ),
      workoutLocation:
          _decodeEnum(json['workoutLocation'] as String?, WorkoutLocation.values),
      preferredDuration: _decodeEnum(
        json['preferredDuration'] as String?,
        WorkoutDurationRange.values,
      ),
      goals: _decodeEnumSet(json['goals'], WorkoutGoal.values),
      energyLevel: json['energyLevel'] as int?,
      updatedAt: _decodeDate(json['updatedAt'] as String?),
    );
  }
}

T? _decodeEnum<T>(String? value, List<T> values) {
  if (value == null) {
    return null;
  }
  for (final entry in values) {
    if ((entry as Enum).name == value) {
      return entry;
    }
  }
  return null;
}

Set<T> _decodeEnumSet<T>(dynamic raw, List<T> values) {
  if (raw is! List) {
    return {};
  }
  final set = <T>{};
  for (final item in raw) {
    if (item is String) {
      final match = _decodeEnum(item, values);
      if (match != null) {
        set.add(match);
      }
    }
  }
  return set;
}

DateTime? _decodeDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
