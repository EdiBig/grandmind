import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/navigation/app_navigator.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/route_constants.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/signup_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/authentication/presentation/screens/reset_password_screen.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/goal_selection_screen.dart';
import '../features/onboarding/presentation/screens/fitness_level_screen.dart';
import '../features/onboarding/presentation/screens/time_availability_screen.dart';
import '../features/onboarding/presentation/screens/limitations_screen.dart';
import '../features/onboarding/presentation/screens/coach_tone_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/providers/home_nav_provider.dart';
import '../features/home/presentation/screens/log_activity_screen.dart';
import '../features/home/presentation/screens/achievements_screen.dart';
import '../features/home/presentation/providers/dashboard_provider.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_enhanced_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/data_management_screen.dart';
import '../features/settings/presentation/screens/privacy_screen.dart';
import '../features/settings/presentation/screens/help_center_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/terms_screen.dart';
import '../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../features/settings/presentation/screens/community_guidelines_screen.dart';
import '../features/ai/presentation/screens/ai_coach_screen.dart';
import '../features/ai/presentation/screens/ai_conversation_history_screen.dart';
import '../features/habits/presentation/screens/create_habit_screen.dart';
import '../features/habits/presentation/screens/habit_insights_screen.dart';
import '../features/habits/presentation/screens/habit_calendar_screen.dart';
import '../features/habits/presentation/screens/habit_history_screen.dart';
import '../features/habits/data/services/habit_insights_service.dart';
import '../features/health/presentation/screens/health_details_screen.dart';
import '../features/health/presentation/screens/health_sync_screen.dart';
import '../features/health/presentation/screens/health_insights_screen.dart';
import '../features/workouts/presentation/screens/fitness_profile_screen.dart';
import '../features/workouts/presentation/screens/my_routines_screen.dart';
import '../features/workouts/presentation/screens/workout_admin_screen.dart';
import '../features/workouts/presentation/screens/wger_exercises_screen.dart';
import '../features/challenges/presentation/screens/create_challenge_screen.dart';
import '../features/challenges/presentation/screens/challenge_detail_screen.dart';
import '../features/challenges/presentation/screens/challenge_rankings_screen.dart';
import '../features/challenges/presentation/screens/challenge_activity_feed_screen.dart';
import '../features/challenges/presentation/screens/challenge_privacy_settings_screen.dart';
import '../features/challenges/presentation/screens/challenge_moderation_screen.dart';
import '../features/challenges/presentation/screens/blocked_users_screen.dart';
import '../features/progress/presentation/screens/progress_insights_screen.dart';
import '../features/progress/presentation/screens/progress_dashboard_screen.dart';
import '../features/progress/presentation/screens/weekly_summary_screen.dart';
import '../features/progress/presentation/screens/weight_tracking_screen.dart';
import '../features/progress/presentation/screens/measurements_screen.dart';
import '../features/progress/presentation/screens/goals_screen.dart';
import '../features/progress/presentation/screens/create_goal_screen.dart';
import '../features/progress/presentation/screens/progress_photos_screen.dart';
import '../features/progress/presentation/screens/progress_comparison_screen.dart';
import '../features/progress/presentation/screens/activity_calendar_screen.dart';
import '../features/progress/presentation/screens/personal_bests_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/nutrition/presentation/screens/log_meal_screen.dart';
import '../features/nutrition/presentation/screens/food_search_screen.dart';
import '../features/nutrition/presentation/screens/create_custom_food_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_goals_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_history_screen.dart';
import '../features/nutrition/presentation/screens/meal_details_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_insights_screen.dart';
import '../features/nutrition/presentation/screens/barcode_scanner_screen.dart';
import '../features/mood_energy/presentation/screens/log_mood_energy_screen.dart';
import '../features/mood_energy/presentation/screens/mood_energy_history_screen.dart';
import '../features/mood_energy/presentation/screens/mood_energy_insights_screen.dart';
import '../features/mood_energy/data/services/mood_energy_insights_service.dart';
import '../features/mood_energy/domain/models/energy_log.dart';
import '../features/sleep/presentation/screens/log_sleep_screen.dart';
import '../features/sleep/domain/models/sleep_log.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  final basePath = Uri.base.path.isEmpty ? RouteConstants.splash : Uri.base.path;
  final initialLocation = kIsWeb
      ? '$basePath${Uri.base.hasQuery ? '?${Uri.base.query}' : ''}'
      : RouteConstants.splash;
  void scheduleHomeTab(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(selectedIndexProvider) != index) {
        ref.read(selectedIndexProvider.notifier).state = index;
      }
    });
  }

  final authState = ref.watch(authStateProvider);
  final userAsync = ref.watch(currentUserProvider);
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, __) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == RouteConstants.login ||
          location == RouteConstants.signup ||
          location == RouteConstants.forgotPassword ||
          location == RouteConstants.resetPassword;
      final isOnboardingRoute = location == RouteConstants.onboarding ||
          location.startsWith('${RouteConstants.onboarding}/');

      if (authState.isLoading) {
        return null;
      }

      final firebaseUser = authState.asData?.value;
      if (firebaseUser == null ||
          firebaseUser.isAnonymous ||
          ((firebaseUser.email == null || firebaseUser.email!.trim().isEmpty) &&
              (firebaseUser.phoneNumber == null ||
                  firebaseUser.phoneNumber!.trim().isEmpty))) {
        return isAuthRoute ? null : RouteConstants.login;
      }

      if (userAsync.isLoading) {
        return null;
      }

      // Also wait if we have a Firebase user but no Firestore doc yet
      if (userAsync.asData?.value == null && !userAsync.hasError) {
        return null; // Still loading user document
      }

      final hasCompletedOnboarding =
          userAsync.asData?.value?.hasCompletedOnboarding ?? false;

      if (!hasCompletedOnboarding && !isOnboardingRoute) {
        return RouteConstants.onboarding;
      }

      if (hasCompletedOnboarding && isOnboardingRoute) {
        return RouteConstants.home;
      }

      if (isAuthRoute) {
        return RouteConstants.home;
      }

      return null;
    },
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
      GoRoute(
        path: RouteConstants.resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final code = state.uri.queryParameters['oobCode'];
          return ResetPasswordScreen(oobCode: code);
        },
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
        builder: (context, state) {
          scheduleHomeTab(0);
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.workouts,
        name: 'workouts',
        builder: (context, state) {
          scheduleHomeTab(1);
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.unity,
        name: 'unity',
        builder: (context, state) {
          scheduleHomeTab(2);
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.createChallenge,
        name: 'createChallenge',
        builder: (context, state) => const CreateChallengeScreen(),
      ),
      GoRoute(
        path: RouteConstants.challengeDetail,
        name: 'challengeDetail',
        builder: (context, state) {
          final challengeId = state.pathParameters['id'] ?? '';
          return ChallengeDetailScreen(challengeId: challengeId);
        },
      ),
      GoRoute(
        path: RouteConstants.challengeRankings,
        name: 'challengeRankings',
        builder: (context, state) {
          final challengeId = state.pathParameters['id'] ?? '';
          return ChallengeRankingsScreen(challengeId: challengeId);
        },
      ),
      GoRoute(
        path: RouteConstants.challengeFeed,
        name: 'challengeFeed',
        builder: (context, state) {
          final challengeId = state.pathParameters['id'] ?? '';
          return ChallengeActivityFeedScreen(challengeId: challengeId);
        },
      ),
      GoRoute(
        path: RouteConstants.challengePrivacy,
        name: 'challengePrivacy',
        builder: (context, state) => const ChallengePrivacySettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.challengeModeration,
        name: 'challengeModeration',
        builder: (context, state) {
          final challengeId = state.pathParameters['id'] ?? '';
          final challengeName = state.extra as String? ?? 'Challenge';
          return ChallengeModerationScreen(
            challengeId: challengeId,
            challengeName: challengeName,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.blockedUsers,
        name: 'blockedUsers',
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: RouteConstants.habits,
        name: 'habits',
        builder: (context, state) {
          scheduleHomeTab(3);
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.progress,
        name: 'progress',
        builder: (context, state) {
          scheduleHomeTab(4);
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: RouteConstants.nutrition,
        name: 'nutrition',
        builder: (context, state) {
          scheduleHomeTab(5);
          return const HomeScreen();
        },
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
        path: RouteConstants.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RouteConstants.healthSync,
        name: 'healthSync',
        builder: (context, state) => const HealthSyncScreen(),
      ),
      GoRoute(
        path: RouteConstants.fitnessProfile,
        name: 'fitnessProfile',
        builder: (context, state) => const FitnessProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.myRoutines,
        name: 'myRoutines',
        builder: (context, state) => const MyRoutinesScreen(),
      ),
      GoRoute(
        path: RouteConstants.workoutAdmin,
        name: 'workoutAdmin',
        builder: (context, state) => const WorkoutAdminScreen(),
      ),
      GoRoute(
        path: RouteConstants.wgerExercises,
        name: 'wgerExercises',
        builder: (context, state) => const WgerExercisesScreen(),
      ),
      GoRoute(
        path: RouteConstants.dataManagement,
        name: 'dataManagement',
        builder: (context, state) => const DataManagementScreen(),
      ),
      GoRoute(
        path: RouteConstants.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: RouteConstants.communityGuidelines,
        name: 'communityGuidelines',
        builder: (context, state) => const CommunityGuidelinesScreen(),
      ),
      GoRoute(
        path: RouteConstants.help,
        name: 'help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: RouteConstants.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteConstants.termsOfService,
        name: 'termsOfService',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: RouteConstants.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // AI Features
      GoRoute(
        path: RouteConstants.aiCoach,
        name: 'aiCoach',
        builder: (context, state) => const AICoachScreen(),
      ),
      GoRoute(
        path: RouteConstants.aiCoachHistory,
        name: 'aiCoachHistory',
        builder: (context, state) => const AIConversationHistoryScreen(),
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
      GoRoute(
        path: RouteConstants.habitCalendar,
        name: 'habitCalendar',
        builder: (context, state) {
          final habitId = state.extra as String?;
          return HabitCalendarScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: RouteConstants.habitHistory,
        name: 'habitHistory',
        builder: (context, state) {
          final selectedDate = state.extra as DateTime?;
          return HabitHistoryScreen(selectedDate: selectedDate);
        },
      ),
      GoRoute(
        path: RouteConstants.habitDetailHistory,
        name: 'habitDetailHistory',
        builder: (context, state) {
          final habitId = state.pathParameters['id'] ?? '';
          return HabitHistoryScreen(habitId: habitId);
        },
      ),

      // Mood & Energy Routes
      GoRoute(
        path: RouteConstants.logMoodEnergy,
        name: 'logMoodEnergy',
        builder: (context, state) {
          final existingLog = state.extra as EnergyLog?;
          return LogMoodEnergyScreen(existingLog: existingLog);
        },
      ),
      GoRoute(
        path: RouteConstants.moodEnergyHistory,
        name: 'moodEnergyHistory',
        builder: (context, state) => const MoodEnergyHistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.moodEnergyInsights,
        name: 'moodEnergyInsights',
        builder: (context, state) {
          final insights = state.extra as MoodEnergyInsights;
          return MoodEnergyInsightsScreen(insights: insights);
        },
      ),

      // Sleep Routes
      GoRoute(
        path: RouteConstants.logSleep,
        name: 'logSleep',
        builder: (context, state) {
          final existingLog = state.extra as SleepLog?;
          return LogSleepScreen(existingLog: existingLog);
        },
      ),

      // Health Routes
      GoRoute(
        path: RouteConstants.healthDetails,
        name: 'healthDetails',
        builder: (context, state) => const HealthDetailsScreen(),
      ),
      GoRoute(
        path: RouteConstants.healthInsights,
        name: 'healthInsights',
        builder: (context, state) => const HealthInsightsScreen(),
      ),
      // Progress Routes
      GoRoute(
        path: RouteConstants.progressInsights,
        name: 'progressInsights',
        builder: (context, state) => const ProgressInsightsScreen(),
      ),
      GoRoute(
        path: RouteConstants.progressDashboard,
        name: 'progressDashboard',
        builder: (context, state) => const ProgressDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: RouteConstants.weeklySummary,
        name: 'weeklySummary',
        builder: (context, state) => const WeeklySummaryScreen(),
      ),
      GoRoute(
        path: RouteConstants.weightTracking,
        name: 'weightTracking',
        builder: (context, state) => const WeightTrackingScreen(),
      ),
      GoRoute(
        path: RouteConstants.measurements,
        name: 'measurements',
        builder: (context, state) => const MeasurementsScreen(),
      ),
      GoRoute(
        path: RouteConstants.goals,
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: RouteConstants.createGoal,
        name: 'createGoal',
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: RouteConstants.progressPhotos,
        name: 'progressPhotos',
        builder: (context, state) => const ProgressPhotosScreen(),
      ),
      GoRoute(
        path: RouteConstants.photoComparison,
        name: 'photoComparison',
        builder: (context, state) => const ProgressComparisonScreen(),
      ),
      GoRoute(
        path: RouteConstants.activityCalendar,
        name: 'activityCalendar',
        builder: (context, state) => const ActivityCalendarScreen(),
      ),
      GoRoute(
        path: RouteConstants.personalBests,
        name: 'personalBests',
        builder: (context, state) => const PersonalBestsScreen(),
      ),

      // Nutrition Routes
      GoRoute(
        path: RouteConstants.logMeal,
        name: 'logMeal',
        builder: (context, state) {
          final args = state.extra as LogMealArgs?;
          return LogMealScreen(
            mealId: args?.mealId,
            initialMealType: args?.initialMealType,
          );
        },
      ),
      GoRoute(
        path: RouteConstants.foodSearch,
        name: 'foodSearch',
        builder: (context, state) {
          final isSelection = state.extra as bool? ?? false;
          return FoodSearchScreen(isSelection: isSelection);
        },
      ),
      GoRoute(
        path: RouteConstants.createCustomFood,
        name: 'createCustomFood',
        builder: (context, state) => const CreateCustomFoodScreen(),
      ),
      GoRoute(
        path: RouteConstants.nutritionGoals,
        name: 'nutritionGoals',
        builder: (context, state) => const NutritionGoalsScreen(),
      ),
      GoRoute(
        path: RouteConstants.nutritionHistory,
        name: 'nutritionHistory',
        builder: (context, state) => const NutritionHistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.mealDetails,
        name: 'mealDetails',
        builder: (context, state) {
          final mealId = state.pathParameters['id'] ?? '';
          return MealDetailsScreen(mealId: mealId);
        },
      ),
      GoRoute(
        path: RouteConstants.aiInsights,
        name: 'aiInsights',
        builder: (context, state) => const NutritionInsightsScreen(),
      ),
      GoRoute(
        path: RouteConstants.barcodeScanner,
        name: 'barcodeScanner',
        builder: (context, state) => const BarcodeScannerScreen(),
      ),

      // Notifications Routes
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
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
