// Widget tests for Kinesa app
// See individual feature test files for comprehensive widget tests:
// - test/features/authentication/login_screen_test.dart
// - test/features/home/dashboard_tab_test.dart
// - test/features/workouts/workout_library_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/core/theme/app_theme.dart';

void main() {
  group('App Theme Tests', () {
    testWidgets('light theme applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('dark theme applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('ProviderScope wraps app correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Provider Test')),
            ),
          ),
        ),
      );

      expect(find.text('Provider Test'), findsOneWidget);
    });
  });

  group('Core Widget Tests', () {
    testWidgets('MaterialApp renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            appBar: null,
            body: Center(
              child: Text('Kinesa'),
            ),
          ),
        ),
      );

      expect(find.text('Kinesa'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('navigation works with Navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/second'),
                    child: const Text('Navigate'),
                  ),
                ),
            '/second': (context) => const Scaffold(
                  body: Center(child: Text('Second Screen')),
                ),
          },
        ),
      );

      expect(find.text('Navigate'), findsOneWidget);

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Second Screen'), findsOneWidget);
    });

    testWidgets('form validation works', (tester) async {
      final formKey = GlobalKey<FormState>();
      String? validatorCalled;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      validatorCalled = value;
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState?.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(validatorCalled, '');
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('snackbar displays correctly', (tester) async {
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

    testWidgets('async loading state works', (tester) async {
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
  });
}
