import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../user/data/services/firestore_service.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minDelayComplete = false;
  bool _hasNavigated = false;
  ProviderSubscription<AsyncValue<User?>>? _authSubscription;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((_) {
      _minDelayComplete = true;
      _tryNavigate(ref.read(authStateProvider));
    });

    _authSubscription =
        ref.listenManual<AsyncValue<User?>>(authStateProvider, (previous, next) {
      _tryNavigate(next);
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  Future<void> _tryNavigate(AsyncValue<User?> authState) async {
    if (!mounted || _hasNavigated || !_minDelayComplete) return;

    authState.when(
      data: (user) async {
        if (_hasNavigated || !mounted) return;
        if (user == null) {
          _hasNavigated = true;
          context.go(RouteConstants.login);
          return;
        }

        if (user.isAnonymous ||
            ((user.email == null || user.email!.trim().isEmpty) &&
                (user.phoneNumber == null ||
                    user.phoneNumber!.trim().isEmpty))) {
          _hasNavigated = true;
          context.go(RouteConstants.login);
          return;
        }

        _hasNavigated = true;

        // Check if user has completed onboarding
        try {
          final firestoreService = ref.read(firestoreServiceProvider);
          var userData = await firestoreService.getUser(user.uid);
          userData ??= await ref
              .read(authRepositoryProvider)
              .ensureUserProfile(user);

          if (!mounted) return;

          final hasCompletedOnboarding = userData.hasCompletedOnboarding;

          if (hasCompletedOnboarding) {
            context.go(RouteConstants.home);
          } else {
            context.go(RouteConstants.onboarding);
          }
        } catch (e) {
          if (!mounted) return;
          context.go(RouteConstants.login);
        }
      },
      loading: () {},
      error: (_, __) {
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;
        context.go(RouteConstants.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<AppGradients>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: gradients.primary,
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.self_improvement,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
