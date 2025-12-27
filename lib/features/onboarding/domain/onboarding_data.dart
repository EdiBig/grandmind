/// Onboarding data models and enums for GrandMind

enum FitnessGoal {
  weightLoss('Weight Loss', 'Lose weight and improve body composition'),
  buildMuscle('Build Muscle', 'Gain strength and muscle mass'),
  generalFitness('General Fitness', 'Stay active and healthy'),
  wellness('Wellness', 'Focus on mental health and stress management'),
  buildHabits('Build Habits', 'Develop consistent healthy routines');

  final String displayName;
  final String description;

  const FitnessGoal(this.displayName, this.description);
}

enum FitnessLevel {
  beginner('Beginner', 'New to fitness or returning after a break'),
  intermediate('Intermediate', 'Exercise regularly, comfortable with basics'),
  advanced('Advanced', 'Experienced with structured training');

  final String displayName;
  final String description;

  const FitnessLevel(this.displayName, this.description);
}

enum WeeklyWorkoutFrequency {
  oneToTwo('1-2 times', 1),
  threeToFour('3-4 times', 3),
  fiveToSix('5-6 times', 5),
  everyday('Every day', 7);

  final String displayName;
  final int daysPerWeek;

  const WeeklyWorkoutFrequency(this.displayName, this.daysPerWeek);
}

enum CoachTone {
  friendly('Friendly', 'Supportive and encouraging', '💙'),
  strict('Strict', 'Direct and challenging', '💪'),
  clinical('Clinical', 'Data-driven and objective', '📊');

  final String displayName;
  final String description;
  final String emoji;

  const CoachTone(this.displayName, this.description, this.emoji);
}

class PhysicalLimitation {
  final String id;
  final String name;
  final String description;

  const PhysicalLimitation({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<PhysicalLimitation> commonLimitations = [
    PhysicalLimitation(
      id: 'knee_pain',
      name: 'Knee Pain',
      description: 'Discomfort or pain in the knees',
    ),
    PhysicalLimitation(
      id: 'back_pain',
      name: 'Back Pain',
      description: 'Lower or upper back issues',
    ),
    PhysicalLimitation(
      id: 'shoulder_pain',
      name: 'Shoulder Pain',
      description: 'Shoulder discomfort or limited mobility',
    ),
    PhysicalLimitation(
      id: 'pregnancy',
      name: 'Pregnancy',
      description: 'Currently pregnant',
    ),
    PhysicalLimitation(
      id: 'heart_condition',
      name: 'Heart Condition',
      description: 'Cardiovascular considerations',
    ),
    PhysicalLimitation(
      id: 'none',
      name: 'None',
      description: 'No limitations',
    ),
  ];
}

/// Onboarding data model to be saved to user profile
class OnboardingData {
  final FitnessGoal goal;
  final FitnessLevel fitnessLevel;
  final WeeklyWorkoutFrequency weeklyWorkouts;
  final CoachTone coachTone;
  final List<String> limitations;
  final bool onboardingCompleted;

  const OnboardingData({
    required this.goal,
    required this.fitnessLevel,
    required this.weeklyWorkouts,
    required this.coachTone,
    this.limitations = const [],
    this.onboardingCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'goal': goal.name,
      'fitnessLevel': fitnessLevel.name,
      'weeklyWorkouts': weeklyWorkouts.daysPerWeek,
      'coachTone': coachTone.name,
      'limitations': limitations,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  OnboardingData copyWith({
    FitnessGoal? goal,
    FitnessLevel? fitnessLevel,
    WeeklyWorkoutFrequency? weeklyWorkouts,
    CoachTone? coachTone,
    List<String>? limitations,
    bool? onboardingCompleted,
  }) {
    return OnboardingData(
      goal: goal ?? this.goal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      weeklyWorkouts: weeklyWorkouts ?? this.weeklyWorkouts,
      coachTone: coachTone ?? this.coachTone,
      limitations: limitations ?? this.limitations,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
