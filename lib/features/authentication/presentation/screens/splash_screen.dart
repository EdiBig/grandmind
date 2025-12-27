import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../user/data/services/firestore_service.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) async {
        if (user != null) {
          // Check if user has completed onboarding
          try {
            final firestoreService = ref.read(firestoreServiceProvider);
            final userData = await firestoreService.getUser(user.uid);

            if (userData != null) {
              final hasCompletedOnboarding = userData.onboarding?['completed'] as bool? ?? false;

              if (!mounted) return;

              if (hasCompletedOnboarding) {
                context.go(RouteConstants.home);
              } else {
                context.go(RouteConstants.onboarding);
              }
            } else {
              // User document doesn't exist, go to onboarding
              if (!mounted) return;
              context.go(RouteConstants.onboarding);
            }
          } catch (e) {
            // Error fetching user data, default to onboarding
            if (!mounted) return;
            context.go(RouteConstants.onboarding);
          }
        } else {
          context.go(RouteConstants.login);
        }
      },
      loading: () {
        // If still loading after delay, assume no user and go to login
        context.go(RouteConstants.login);
      },
      error: (_, __) {
        context.go(RouteConstants.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
