/// Route path constants for navigation
class RouteConstants {
  RouteConstants._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

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
  static const String progress = '/progress';
  static const String progressInsights = '/progress/insights';
  static const String progressDashboard = '/progress/dashboard';
  static const String achievements = '/progress/achievements';
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
  static const String privacy = '/settings/privacy';
  static const String dataManagement = '/settings/data-management';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
  static const String termsOfService = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String apiKeySetup = '/settings/api-key-setup';

  // AI Features
  static const String aiCoach = '/ai-coach';
  static const String aiInsights = '/ai-insights';
  static const String aiNutrition = '/ai-nutrition';
  static const String aiRecovery = '/ai-recovery';

  // Quick Actions
  static const String logActivity = '/log-activity';
  static const String logWeight = '/log-weight';
  static const String logHabit = '/log-habit';

  // Health Routes
  static const String healthDetails = '/health/details';
}
