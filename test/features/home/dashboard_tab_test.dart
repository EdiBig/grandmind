import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kinesa/features/home/presentation/screens/dashboard_tab.dart';
import 'package:kinesa/features/home/presentation/providers/dashboard_provider.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';
import 'package:kinesa/core/theme/app_theme.dart';

// Mocks
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';
}

void main() {
  final testUser = UserModel(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: DateTime.now(),
  );

  final testSnapshot = DashboardSnapshot(
    completedHabits: 2,
    totalHabits: 5,
    stepsToday: 5000,
    stepsGoal: 10000,
    waterGlasses: 4,
    waterGoal: 8,
    todaysMeals: [],
    nextWorkout: null,
    weightTrend: null,
    moodLog: null,
    energyLevel: null,
    sleepHours: 7.5,
    caloriesBurned: 250,
  );

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => AsyncValue.data(testUser)),
        dashboardSnapshotProvider.overrideWith(
          (ref) => AsyncValue.data(testSnapshot),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: DashboardTab(),
        ),
      ),
    );
  }

  group('DashboardTab', () {
    testWidgets('renders dashboard with user greeting', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify greeting appears (with time-based greeting)
      expect(
        find.textContaining('Test User'),
        findsWidgets,
      );
    });

    testWidgets('shows habits progress card', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for habits section
      expect(find.textContaining('Habits'), findsWidgets);
    });

    testWidgets('displays steps progress', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify steps are shown
      expect(find.textContaining('5,000'), findsWidgets);
    });

    testWidgets('shows water intake tracker', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for water/hydration section
      expect(find.textContaining('Water'), findsWidgets);
    });

    testWidgets('displays quick action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for quick action buttons (Log Activity, etc.)
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('shows loading state while fetching data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const AsyncValue.loading()),
            dashboardSnapshotProvider.overrideWith(
              (ref) => const AsyncValue.loading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: DashboardTab(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Should show loading indicator or skeleton
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
      );
    });

    testWidgets('shows error state when data fetch fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => AsyncValue.error(Exception('Test error'), StackTrace.current),
            ),
            dashboardSnapshotProvider.overrideWith(
              (ref) => AsyncValue.error(Exception('Test error'), StackTrace.current),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: DashboardTab(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error message or retry button
      expect(
        find.byIcon(Icons.error_outline),
        findsWidgets,
      );
    });

    testWidgets('displays sleep hours when available', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify sleep data is shown
      expect(find.textContaining('7'), findsWidgets); // 7.5 hours
    });

    testWidgets('shows calories burned stat', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify calories are shown
      expect(find.textContaining('250'), findsWidgets);
    });

    testWidgets('renders without crashing when user is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            dashboardSnapshotProvider.overrideWith(
              (ref) => AsyncValue.data(testSnapshot),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: DashboardTab(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(DashboardTab), findsOneWidget);
    });

    testWidgets('habit completion progress is visible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for progress indicators (2/5 habits)
      expect(find.textContaining('2'), findsWidgets);
      expect(find.textContaining('5'), findsWidgets);
    });
  });
}
