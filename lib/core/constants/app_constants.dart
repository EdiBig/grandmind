/// Application-wide constants including strings, dimensions, and other values
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Kinesa';
  static const String appTagline = 'Your Holistic Wellness Companion';

  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;

  // Goal Types
  static const String goalWeightLoss = 'weight_loss';
  static const String goalMuscleGain = 'muscle_gain';
  static const String goalFitness = 'fitness';
  static const String goalWellness = 'wellness';

  // Fitness Levels
  static const String fitnessBeginner = 'beginner';
  static const String fitnessIntermediate = 'intermediate';
  static const String fitnessAdvanced = 'advanced';

  // Coach Tones
  static const String coachToneFriendly = 'friendly';
  static const String coachToneSerious = 'serious';

  // Workout Types
  static const String workoutStrength = 'strength';
  static const String workoutCardio = 'cardio';
  static const String workoutFlexibility = 'flexibility';
  static const String workoutBodyweight = 'bodyweight';

  // Activity Types
  static const String activityWorkout = 'workout';
  static const String activityRun = 'run';
  static const String activityWalk = 'walk';
  static const String activityCycling = 'cycling';
  static const String activityGym = 'gym';

  // Notification Channels
  static const String notificationChannelDaily = 'daily_reminders';
  static const String notificationChannelWorkout = 'workout_alerts';
  static const String notificationChannelAchievements = 'achievements';

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  // Timeouts & Debounce
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Limits
  static const int maxProfilePictureSize = 5242880; // 5MB
  static const int minPasswordLength = 8;
  static const int maxWeightKg = 300;
  static const int minWeightKg = 30;
  static const int maxHeightCm = 250;
  static const int minHeightCm = 100;

  // Health Data
  static const int maxWaterCups = 20;
  static const int maxSleepHours = 24;
  static const int maxMoodRating = 5;
  static const int minMoodRating = 1;
  static const int maxEffortRating = 10;
  static const int minEffortRating = 1;

  // Streak & Gamification
  static const int streakDaysForBadge = 7;
  static const int inactivityDaysThreshold = 3;
}
