import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/navigation/app_navigator.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/route_constants.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/home/presentation/providers/home_nav_provider.dart';
import '../features/home/presentation/providers/dashboard_provider.dart';

// Route imports
import 'auth_routes.dart';
import 'onboarding_routes.dart';
import 'home_routes.dart';
import 'profile_routes.dart';
import 'settings_routes.dart';
import 'challenge_routes.dart';
import 'habits_routes.dart';
import 'ai_routes.dart';
import 'health_routes.dart';
import 'workout_routes.dart';
import 'progress_routes.dart';
import 'nutrition_routes.dart';
import 'mood_energy_routes.dart';
import 'sleep_routes.dart';

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
    redirect: (context, state) => _handleRedirect(
      state: state,
      authState: authState,
      userAsync: userAsync,
    ),
    routes: [
      // Spread all feature routes
      ...authRoutes,
      ...onboardingRoutes,
      ...homeRoutes(scheduleHomeTab),
      ...profileRoutes,
      ...settingsRoutes,
      ...challengeRoutes,
      ...habitsRoutes,
      ...aiRoutes,
      ...healthRoutes,
      ...workoutRoutes,
      ...progressRoutes,
      ...nutritionRoutes,
      ...moodEnergyRoutes,
      ...sleepRoutes,
    ],
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );
});

/// Centralized redirect logic
String? _handleRedirect({
  required GoRouterState state,
  required AsyncValue<User?> authState,
  required AsyncValue userAsync,
}) {
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
}

/// Error page for invalid routes
Widget _buildErrorPage(BuildContext context, GoRouterState state) {
  return Scaffold(
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
  );
}
