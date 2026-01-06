import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/signup_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/goal_selection_screen.dart';
import '../features/onboarding/presentation/screens/fitness_level_screen.dart';
import '../features/onboarding/presentation/screens/time_availability_screen.dart';
import '../features/onboarding/presentation/screens/limitations_screen.dart';
import '../features/onboarding/presentation/screens/coach_tone_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/log_activity_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_enhanced_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/api_key_setup_screen.dart';
import '../features/settings/presentation/screens/data_management_screen.dart';
import '../features/ai/presentation/screens/ai_coach_screen.dart';
import '../features/habits/presentation/screens/create_habit_screen.dart';
import '../features/habits/presentation/screens/habit_insights_screen.dart';
import '../features/habits/data/services/habit_insights_service.dart';
import '../features/health/presentation/screens/health_details_screen.dart';
import '../features/health/presentation/screens/health_sync_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding Routes
      GoRoute(
        path: RouteConstants.onboarding,
        name: 'onboarding',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingGoal,
        name: 'onboardingGoal',
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingFitnessLevel,
        name: 'onboardingFitnessLevel',
        builder: (context, state) => const FitnessLevelScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingTimeAvailability,
        name: 'onboardingTimeAvailability',
        builder: (context, state) => const TimeAvailabilityScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingLimitations,
        name: 'onboardingLimitations',
        builder: (context, state) => const LimitationsScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingCoachTone,
        name: 'onboardingCoachTone',
        builder: (context, state) => const CoachToneScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.logActivity,
        name: 'logActivity',
        builder: (context, state) => const LogActivityScreen(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileEnhancedScreen(),
      ),
      GoRoute(
        path: RouteConstants.apiKeySetup,
        name: 'apiKeySetup',
        builder: (context, state) => const ApiKeySetupScreen(),
      ),
      GoRoute(
        path: RouteConstants.dataManagement,
        name: 'dataManagement',
        builder: (context, state) => const DataManagementScreen(),
      ),

      // AI Features
      GoRoute(
        path: RouteConstants.aiCoach,
        name: 'aiCoach',
        builder: (context, state) => const AICoachScreen(),
      ),

      // Habits Routes
      GoRoute(
        path: RouteConstants.createHabit,
        name: 'createHabit',
        builder: (context, state) => const CreateHabitScreen(),
      ),
      GoRoute(
        path: RouteConstants.editHabit,
        name: 'editHabit',
        builder: (context, state) {
          final habitId = state.pathParameters['id'];
          return CreateHabitScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/habits/insights',
        name: 'habitInsights',
        builder: (context, state) {
          final insights = state.extra as HabitInsights;
          return HabitInsightsScreen(insights: insights);
        },
      ),

      // Health Routes
      GoRoute(
        path: RouteConstants.healthDetails,
        name: 'healthDetails',
        builder: (context, state) => const HealthDetailsScreen(),
      ),
      GoRoute(
        path: RouteConstants.healthSync,
        name: 'healthSync',
        builder: (context, state) => const HealthSyncScreen(),
      ),

      // Notifications Routes
      GoRoute(
        path: RouteConstants.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
});
