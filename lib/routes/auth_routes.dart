import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/signup_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/authentication/presentation/screens/reset_password_screen.dart';

/// Authentication related routes
List<GoRoute> authRoutes = [
  GoRoute(
    path: RouteConstants.splash,
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
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
];
