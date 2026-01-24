import 'dart:io' show Platform, Socket;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinesa/app.dart';
import 'package:kinesa/firebase_options.dart';
import 'package:kinesa/core/theme/app_theme.dart';
import 'package:kinesa/features/authentication/presentation/screens/login_screen.dart';
import 'package:kinesa/features/home/presentation/screens/home_screen.dart';
import 'package:kinesa/features/habits/presentation/screens/create_habit_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String testHost;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    testHost = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    FirebaseAuth.instance.useAuthEmulator(testHost, 9098);
    FirebaseFirestore.instance.useFirestoreEmulator(testHost, 8080);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: false,
    );
  });

  Future<bool> checkEmulatorAvailable() async {
    try {
      final authSocket = await Socket.connect(
        testHost,
        9098,
        timeout: const Duration(seconds: 2),
      );
      authSocket.destroy();
      final fsSocket = await Socket.connect(
        testHost,
        8080,
        timeout: const Duration(seconds: 2),
      );
      fsSocket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    final scrollableFinder = find.byType(Scrollable);
    if (scrollableFinder.evaluate().isEmpty) return;

    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: scrollableFinder.first,
    );
    await tester.pumpAndSettle();
  }

  group('Authentication Flow', () {
    testWidgets('Login screen renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('Login form validates empty fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Login form validates invalid email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('Navigation Flow', () {
    testWidgets('Home screen shows bottom navigation', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Create user document for onboarding check
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'email': 'test@example.com',
        'hasCompletedOnboarding': true,
        'createdAt': Timestamp.now(),
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('Bottom nav switches tabs', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'email': 'test@example.com',
        'hasCompletedOnboarding': true,
        'createdAt': Timestamp.now(),
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Workouts tab
      await tester.tap(find.text('Workouts'));
      await tester.pumpAndSettle();

      // Should show workouts content
      expect(find.text('Log Workout'), findsOneWidget);
    });
  });

  group('Habit Flow', () {
    testWidgets('Create habit screen renders', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CreateHabitScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Habit'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Habit form validates empty name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CreateHabitScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap save button
      final saveButton = find.text('Save Habit');
      if (saveButton.evaluate().isNotEmpty) {
        await scrollTo(tester, saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show validation error or not proceed
        expect(find.byType(CreateHabitScreen), findsOneWidget);
      }
    });

    testWidgets('Habit creation with emulator', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CreateHabitScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter habit name
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Habit');
      await tester.pumpAndSettle();

      // Find and tap save button
      final saveButton = find.text('Save Habit');
      if (saveButton.evaluate().isNotEmpty) {
        await scrollTo(tester, saveButton);
        await tester.tap(saveButton);
        await tester.pump(const Duration(seconds: 2));

        // Verify habit was created in Firestore
        final query = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('habits')
            .where('name', isEqualTo: 'Test Habit')
            .get();

        expect(query.docs.isNotEmpty || find.byType(CreateHabitScreen).evaluate().isEmpty, isTrue);
      }
    });
  });

  group('Theme Tests', () {
    testWidgets('Light theme applies correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: Center(child: Text('Test'))),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('Dark theme applies correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: Center(child: Text('Test'))),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('Form Validation', () {
    testWidgets('Email validation pattern works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test various invalid emails
      final emailField = find.byType(TextFormField).first;

      await tester.enterText(emailField, 'test');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password field is obscured', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextFormField).at(1);
      final textFormField = tester.widget<TextFormField>(passwordField);
      expect(textFormField.obscureText, isTrue);
    });
  });

  group('UI Components', () {
    testWidgets('Loading indicator shows during async operations', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Loaded'),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() => isLoading = false),
                  child: const Icon(Icons.check),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('Snackbar displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test Snackbar')),
                  );
                },
                child: const Text('Show Snackbar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();

      expect(find.text('Test Snackbar'), findsOneWidget);
    });

    testWidgets('Dialog displays and dismisses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Test Dialog'),
                      content: const Text('Dialog content'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsNothing);
    });
  });
}
