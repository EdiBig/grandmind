import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kinesa/features/authentication/presentation/screens/login_screen.dart';
import 'package:kinesa/features/authentication/presentation/providers/auth_provider.dart';
import 'package:kinesa/core/theme/app_theme.dart';

// Mocks
class MockAuthController extends StateNotifier<AuthState>
    with Mock
    implements AuthController {
  MockAuthController() : super(AuthState.initial());
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';
}

void main() {
  late MockAuthController mockAuthController;

  setUp(() {
    mockAuthController = MockAuthController();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith((ref) => mockAuthController),
        authStateProvider.overrideWith((ref) => const AsyncValue.data(null)),
        appleSignInEnabledProvider.overrideWith((ref) => const AsyncValue.data(false)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders login screen with all elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify title text
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue your journey'), findsOneWidget);

      // Verify form fields exist
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password

      // Verify email field
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

      // Verify sign in button
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

      // Verify forgot password link
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Verify sign up link
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap sign in without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field (second TextFormField)
      final passwordField = find.byType(TextFormField).at(1);
      final textFormField = tester.widget<TextFormField>(passwordField);

      // Verify obscureText is true
      expect(textFormField.obscureText, isTrue);
    });

    testWidgets('can toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the visibility toggle icon button
      final visibilityToggle = find.byIcon(Icons.visibility_off);
      expect(visibilityToggle, findsOneWidget);

      // Tap to show password
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Icon should change to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('displays Google sign-in button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for Google sign-in button
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows loading indicator when signing in', (tester) async {
      // Set up loading state
      mockAuthController.state = AuthState(status: AuthStatus.loading);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('sign up link exists', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify sign up navigation element exists
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('forgot password link exists', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify forgot password link exists
      final forgotPasswordLink = find.text('Forgot Password?');
      expect(forgotPasswordLink, findsOneWidget);
    });
  });
}
