/// User context model for building AI prompts
/// Aggregates all relevant user data for context-aware responses
class UserContext {
  // User Profile
  final String userId;
  final String? displayName;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? coachTone;

  // Physical Profile
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;

  // Preferences & Limitations
  final List<String> physicalLimitations;
  final List<String> preferredWorkoutTypes;
  final int? preferredWorkoutDuration;
  final int? weeklyWorkoutFrequency;

  // Recent Activity
  final DateTime? lastWorkoutDate;
  final int daysSinceLastWorkout;
  final List<RecentWorkout> recentWorkouts;
  final String? recentPerformanceSummary;

  // Health Data
  final double? todaySteps;
  final double? lastNightSleepHours;
  final double? averageSleepHours;
  final int? currentEnergyLevel;

  // Mood & Habits
  final int? currentMood;
  final double? habitCompletionRate;
  final int? currentStreak;

  // Contextual Info
  final DateTime timestamp;
  final String? timeOfDay; // morning, afternoon, evening
  final String? dayOfWeek;

  UserContext({
    required this.userId,
    this.displayName,
    this.fitnessGoal,
    this.fitnessLevel,
    this.coachTone,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.physicalLimitations = const [],
    this.preferredWorkoutTypes = const [],
    this.preferredWorkoutDuration,
    this.weeklyWorkoutFrequency,
    this.lastWorkoutDate,
    this.daysSinceLastWorkout = 0,
    this.recentWorkouts = const [],
    this.recentPerformanceSummary,
    this.todaySteps,
    this.lastNightSleepHours,
    this.averageSleepHours,
    this.currentEnergyLevel,
    this.currentMood,
    this.habitCompletionRate,
    this.currentStreak,
    DateTime? timestamp,
    this.timeOfDay,
    this.dayOfWeek,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get greeting based on time of day
  String get greeting {
    final hour = timestamp.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Check if user is a beginner
  bool get isBeginner => fitnessLevel?.toLowerCase() == 'beginner';

  /// Check if user is advanced
  bool get isAdvanced => fitnessLevel?.toLowerCase() == 'advanced';

  /// Check if user worked out recently (within 24 hours)
  bool get workedOutRecently => daysSinceLastWorkout <= 1;

  /// Get BMI if height and weight are available
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'underweight';
    if (bmiValue < 25) return 'normal weight';
    if (bmiValue < 30) return 'overweight';
    return 'obese';
  }

  /// Format context as a readable summary
  String toSummary() {
    final buffer = StringBuffer();

    // Personal info
    if (displayName != null) {
      buffer.writeln('Name: $displayName');
    }
    if (age != null) {
      buffer.writeln('Age: $age years');
    }
    if (gender != null) {
      buffer.writeln('Gender: $gender');
    }

    // Physical profile
    if (height != null && weight != null) {
      buffer.writeln('Height: ${height!.toStringAsFixed(0)}cm');
      buffer.writeln('Weight: ${weight!.toStringAsFixed(1)}kg');
      if (bmi != null) {
        buffer.writeln('BMI: ${bmi!.toStringAsFixed(1)} ($bmiCategory)');
      }
    }

    // Fitness profile
    if (fitnessGoal != null) {
      buffer.writeln('Goal: $fitnessGoal');
    }
    if (fitnessLevel != null) {
      buffer.writeln('Fitness Level: $fitnessLevel');
    }
    if (weeklyWorkoutFrequency != null) {
      buffer.writeln('Workout Frequency: $weeklyWorkoutFrequency times/week');
    }

    // Limitations
    if (physicalLimitations.isNotEmpty) {
      buffer.writeln('Physical Limitations: ${physicalLimitations.join(", ")}');
    }

    // Recent activity
    if (lastWorkoutDate != null) {
      buffer.writeln('Last Workout: $daysSinceLastWorkout day(s) ago');
    }
    if (recentPerformanceSummary != null) {
      buffer.writeln('Recent Performance: $recentPerformanceSummary');
    }

    // Health data
    if (lastNightSleepHours != null) {
      buffer.writeln('Sleep Last Night: ${lastNightSleepHours!.toStringAsFixed(1)} hours');
    }
    if (todaySteps != null) {
      buffer.writeln('Steps Today: ${todaySteps!.toStringAsFixed(0)}');
    }
    if (currentEnergyLevel != null) {
      buffer.writeln('Energy Level: $currentEnergyLevel/5');
    }

    // Mood & habits
    if (currentMood != null) {
      buffer.writeln('Current Mood: $currentMood/5');
    }
    if (habitCompletionRate != null) {
      buffer.writeln('Habit Completion: ${(habitCompletionRate! * 100).toStringAsFixed(0)}%');
    }
    if (currentStreak != null && currentStreak! > 0) {
      buffer.writeln('Current Streak: $currentStreak days');
    }

    return buffer.toString();
  }
}

/// Recent workout summary for context
class RecentWorkout {
  final String workoutName;
  final DateTime date;
  final int durationMinutes;
  final int? perceivedEffort; // 1-10 RPE scale
  final String? notes;

  const RecentWorkout({
    required this.workoutName,
    required this.date,
    required this.durationMinutes,
    this.perceivedEffort,
    this.notes,
  });

  String toSummary() {
    final buffer = StringBuffer();
    buffer.write(workoutName);
    buffer.write(' (${durationMinutes}min');
    if (perceivedEffort != null) {
      buffer.write(', RPE: $perceivedEffort/10');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Helper class to build UserContext from various data sources
class UserContextBuilder {
  String? userId;
  String? displayName;
  String? fitnessGoal;
  String? fitnessLevel;
  String? coachTone;
  double? height;
  double? weight;
  int? age;
  String? gender;
  List<String> physicalLimitations = [];
  List<String> preferredWorkoutTypes = [];
  int? preferredWorkoutDuration;
  int? weeklyWorkoutFrequency;
  DateTime? lastWorkoutDate;
  int daysSinceLastWorkout = 0;
  List<RecentWorkout> recentWorkouts = [];
  String? recentPerformanceSummary;
  double? todaySteps;
  double? lastNightSleepHours;
  double? averageSleepHours;
  int? currentEnergyLevel;
  int? currentMood;
  double? habitCompletionRate;
  int? currentStreak;
  DateTime? timestamp;
  String? timeOfDay;
  String? dayOfWeek;

  UserContextBuilder();

  /// Build the UserContext
  UserContext build() {
    if (userId == null) {
      throw ArgumentError('userId is required');
    }

    // Calculate time of day if not provided
    final now = timestamp ?? DateTime.now();
    final hour = now.hour;
    timeOfDay ??= hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');

    // Calculate day of week if not provided
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    dayOfWeek ??= days[now.weekday - 1];

    return UserContext(
      userId: userId!,
      displayName: displayName,
      fitnessGoal: fitnessGoal,
      fitnessLevel: fitnessLevel,
      coachTone: coachTone,
      height: height,
      weight: weight,
      age: age,
      gender: gender,
      physicalLimitations: physicalLimitations,
      preferredWorkoutTypes: preferredWorkoutTypes,
      preferredWorkoutDuration: preferredWorkoutDuration,
      weeklyWorkoutFrequency: weeklyWorkoutFrequency,
      lastWorkoutDate: lastWorkoutDate,
      daysSinceLastWorkout: daysSinceLastWorkout,
      recentWorkouts: recentWorkouts,
      recentPerformanceSummary: recentPerformanceSummary,
      todaySteps: todaySteps,
      lastNightSleepHours: lastNightSleepHours,
      averageSleepHours: averageSleepHours,
      currentEnergyLevel: currentEnergyLevel,
      currentMood: currentMood,
      habitCompletionRate: habitCompletionRate,
      currentStreak: currentStreak,
      timestamp: timestamp,
      timeOfDay: timeOfDay,
      dayOfWeek: dayOfWeek,
    );
  }
}
