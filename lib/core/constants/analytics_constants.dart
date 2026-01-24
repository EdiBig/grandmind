/// Analytics event names and parameter constants
/// Based on CLAUDE.md analytics events specification

class AnalyticsEvents {
  // Onboarding
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingCompleted = 'onboarding_completed';

  // Authentication
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String passwordReset = 'password_reset_requested';

  // Core Actions
  static const String workoutLogged = 'workout_logged';
  static const String workoutStarted = 'workout_started';
  static const String workoutCompleted = 'workout_completed';
  static const String habitCompleted = 'habit_completed';
  static const String habitCreated = 'habit_created';
  static const String habitDeleted = 'habit_deleted';
  static const String moodLogged = 'mood_logged';
  static const String weightLogged = 'weight_logged';
  static const String healthSynced = 'health_synced';

  // Engagement
  static const String streakAchieved = 'streak_achieved';
  static const String streakBroken = 'streak_broken';
  static const String weeklySummaryViewed = 'weekly_summary_viewed';
  static const String personalBestAchieved = 'personal_best_achieved';
  static const String achievementUnlocked = 'achievement_unlocked';

  // AI Features
  static const String aiCoachMessageSent = 'ai_coach_message_sent';
  static const String aiCoachResponseReceived = 'ai_coach_response_received';
  static const String aiInsightViewed = 'ai_insight_viewed';

  // Navigation
  static const String screenView = 'screen_view';
  static const String tabChanged = 'tab_changed';

  // Monetisation
  static const String paywallViewed = 'paywall_viewed';
  static const String subscriptionStarted = 'subscription_started';
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String trialStarted = 'trial_started';

  // Errors
  static const String errorOccurred = 'error_occurred';
}

class AnalyticsParams {
  // Common
  static const String userId = 'user_id';
  static const String timestamp = 'timestamp';
  static const String source = 'source';

  // Onboarding
  static const String step = 'step';
  static const String stepName = 'step_name';
  static const String goalType = 'goal_type';
  static const String fitnessLevel = 'fitness_level';
  static const String coachTone = 'coach_tone';

  // Workouts
  static const String workoutType = 'workout_type';
  static const String workoutId = 'workout_id';
  static const String duration = 'duration';
  static const String durationMinutes = 'duration_minutes';
  static const String hasExercises = 'has_exercises';
  static const String exerciseCount = 'exercise_count';
  static const String caloriesBurned = 'calories_burned';
  static const String perceivedEffort = 'perceived_effort';

  // Habits
  static const String habitId = 'habit_id';
  static const String habitName = 'habit_name';
  static const String habitCategory = 'habit_category';

  // Mood/Energy
  static const String energyLevel = 'energy_level';
  static const String moodRating = 'mood_rating';

  // Health
  static const String healthSource = 'health_source';
  static const String dataType = 'data_type';
  static const String recordCount = 'record_count';

  // Streaks & Achievements
  static const String streakLength = 'streak_length';
  static const String streakType = 'streak_type';
  static const String metric = 'metric';
  static const String achievementId = 'achievement_id';
  static const String achievementName = 'achievement_name';

  // AI
  static const String messageLength = 'message_length';
  static const String responseTime = 'response_time';
  static const String tokensUsed = 'tokens_used';
  static const String fromCache = 'from_cache';

  // Navigation
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String tabName = 'tab_name';
  static const String previousTab = 'previous_tab';

  // Monetisation
  static const String trigger = 'trigger';
  static const String plan = 'plan';
  static const String price = 'price';
  static const String currency = 'currency';

  // Errors
  static const String errorType = 'error_type';
  static const String errorMessage = 'error_message';
  static const String stackTrace = 'stack_trace';
}

class AnalyticsUserProperties {
  static const String subscriptionTier = 'subscription_tier';
  static const String goalType = 'goal_type';
  static const String fitnessLevel = 'fitness_level';
  static const String coachTone = 'coach_tone';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String accountCreatedAt = 'account_created_at';
  static const String weeklyWorkoutGoal = 'weekly_workout_goal';
  static const String hasHealthConnected = 'has_health_connected';
}
