/// Route path constants for navigation
class RouteConstants {
  RouteConstants._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Onboarding Routes
  static const String onboarding = '/onboarding';
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingFitnessLevel = '/onboarding/fitness-level';
  static const String onboardingTimeAvailability = '/onboarding/time-availability';
  static const String onboardingLimitations = '/onboarding/limitations';
  static const String onboardingCoachTone = '/onboarding/coach-tone';

  // Main App Routes
  static const String home = '/home';
  static const String workouts = '/workouts';
  static const String workoutDetail = '/workouts/:id';
  static const String workoutPlayer = '/workouts/:id/player';
  static const String habits = '/habits';
  static const String createHabit = '/habits/create';
  static const String editHabit = '/habits/:id/edit';
  static const String habitCalendar = '/habits/calendar';
  static const String habitHistory = '/habits/history';
  static const String habitDetailHistory = '/habits/:id/history';
  static const String unity = '/unity';
  static const String createChallenge = '/unity/create';
  static const String challengeDetail = '/unity/:id';
  static const String challengeRankings = '/unity/:id/rankings';
  static const String challengeFeed = '/unity/:id/feed';
  static const String challengePrivacy = '/unity/privacy';
  static const String challengeModeration = '/unity/:id/moderation';
  static const String blockedUsers = '/unity/blocked-users';
  static const String progress = '/progress';
  static const String progressInsights = '/progress/insights';
  static const String progressDashboard = '/progress/dashboard';
  static const String achievements = '/progress/achievements';
  static const String weeklySummary = '/progress/weekly-summary';
  static const String weightTracking = '/progress/weight';
  static const String measurements = '/progress/measurements';
  static const String goals = '/progress/goals';
  static const String createGoal = '/progress/goals/create';
  static const String progressPhotos = '/progress/photos';
  static const String photoComparison = '/progress/photos/compare';
  static const String personalBests = '/progress/personal-bests';
  static const String activityCalendar = '/progress/calendar';
  static const String streaks = '/progress/streaks';
  static const String plan = '/plan';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String nutrition = '/nutrition';
  static const String logMeal = '/nutrition/log-meal';
  static const String foodSearch = '/nutrition/food-search';
  static const String createCustomFood = '/nutrition/create-custom-food';
  static const String nutritionGoals = '/nutrition/goals';
  static const String nutritionHistory = '/nutrition/history';
  static const String mealDetails = '/nutrition/meals/:id';
  static const String barcodeScanner = '/nutrition/barcode-scanner';

  // Settings Sub-routes
  static const String editProfile = '/settings/edit-profile';
  static const String notifications = '/settings/notifications';
  static const String healthSync = '/settings/health-sync';
  static const String fitnessProfile = '/settings/fitness-profile';
  static const String myRoutines = '/settings/my-routines';
  static const String communityGuidelines = '/settings/community-guidelines';
  static const String privacy = '/settings/privacy';
  static const String dataManagement = '/settings/data-management';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
  static const String termsOfService = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String workoutAdmin = '/settings/workout-admin';
  static const String wgerExercises = '/workouts/exercises';

  // AI Features
  static const String aiCoach = '/ai-coach';
  static const String aiCoachHistory = '/ai-coach/history';
  static const String aiInsights = '/ai-insights';
  static const String aiNutrition = '/ai-nutrition';
  static const String aiRecovery = '/ai-recovery';

  // Quick Actions
  static const String logActivity = '/log-activity';
  static const String logWeight = '/log-weight';
  static const String logHabit = '/log-habit';

  // Health Routes
  static const String healthDetails = '/health/details';
  static const String healthInsights = '/health/insights';

  // Mood & Energy Routes
  static const String logMoodEnergy = '/mood-energy/log';
  static const String moodEnergyHistory = '/mood-energy/history';
  static const String moodEnergyInsights = '/mood-energy/insights';

  // Sleep Routes
  static const String logSleep = '/sleep/log';
  static const String sleepHistory = '/sleep/history';
}
