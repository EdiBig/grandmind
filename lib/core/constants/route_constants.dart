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
  static const String progress = '/progress';
  static const String plan = '/plan';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Settings Sub-routes
  static const String editProfile = '/settings/edit-profile';
  static const String notifications = '/settings/notifications';
  static const String healthSync = '/settings/health-sync';
  static const String privacy = '/settings/privacy';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
  static const String termsOfService = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy-policy';

  // Quick Actions
  static const String logActivity = '/log-activity';
  static const String logWeight = '/log-weight';
  static const String logHabit = '/log-habit';
}
