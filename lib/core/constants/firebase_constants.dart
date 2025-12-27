/// Firebase collection and field name constants
class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String exercisesCollection = 'exercises';
  static const String plansCollection = 'plans';
  static const String activityLogsCollection = 'activityLogs';
  static const String habitLogsCollection = 'habitLogs';
  static const String weightEntriesCollection = 'weightEntries';
  static const String healthMetricsCollection = 'healthMetrics';

  // User Fields
  static const String userUid = 'uid';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userProfilePictureUrl = 'profilePictureUrl';
  static const String userAge = 'age';
  static const String userGender = 'gender';
  static const String userHeight = 'height';
  static const String userCurrentWeight = 'currentWeight';
  static const String userGoalWeight = 'goalWeight';
  static const String userGoalType = 'goalType';
  static const String userFitnessLevel = 'fitnessLevel';
  static const String userCurrentPlanId = 'currentPlanId';
  static const String userCoachTone = 'coachTone';
  static const String userCreatedAt = 'createdAt';
  static const String userUpdatedAt = 'updatedAt';

  // Timestamp Fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String recordedAt = 'recordedAt';
  static const String loggedAt = 'loggedAt';
  static const String date = 'date';

  // Storage Paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String workoutVideosPath = 'workout_videos';
  static const String exerciseGifsPath = 'exercise_gifs';
}
