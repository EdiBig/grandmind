import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/goal_selection_screen.dart';
import '../features/onboarding/presentation/screens/fitness_level_screen.dart';
import '../features/onboarding/presentation/screens/time_availability_screen.dart';
import '../features/onboarding/presentation/screens/limitations_screen.dart';
import '../features/onboarding/presentation/screens/coach_tone_screen.dart';

/// Onboarding flow routes
List<GoRoute> onboardingRoutes = [
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
];
