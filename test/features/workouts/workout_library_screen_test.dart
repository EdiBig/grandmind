import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinesa/core/providers/shared_preferences_provider.dart';
import 'package:kinesa/features/workouts/presentation/screens/workout_library_screen.dart';
import 'package:kinesa/features/workouts/presentation/providers/workout_library_providers.dart';
import 'package:kinesa/features/workouts/presentation/providers/fitness_profile_provider.dart';
import 'package:kinesa/features/workouts/domain/models/workout_library_entry.dart';
import 'package:kinesa/features/workouts/domain/models/workout.dart';
import 'package:kinesa/core/theme/app_theme.dart';

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  final testEntries = [
    WorkoutLibraryEntry(
      id: '1',
      name: 'Full Body Strength',
      primaryTargets: ['Legs', 'Arms', 'Core'],
      secondaryTargets: ['Back', 'Chest'],
      difficulty: WorkoutDifficulty.intermediate,
      equipment: WorkoutEquipment.dumbbell,
      durationMinutes: 45,
      category: WorkoutCategory.strength,
      instructions: ['Step 1', 'Step 2'],
      commonMistakes: ['Mistake 1'],
      bodyFocuses: [WorkoutBodyFocus.fullBody],
      goals: [WorkoutGoal.strength],
      isBodyweight: false,
      isCompound: true,
      isRecommended: true,
      addedAt: DateTime(2024, 1, 1),
    ),
    WorkoutLibraryEntry(
      id: '2',
      name: 'Quick HIIT Session',
      primaryTargets: ['Full Body'],
      secondaryTargets: ['Cardio'],
      difficulty: WorkoutDifficulty.advanced,
      equipment: WorkoutEquipment.bodyweight,
      durationMinutes: 30,
      category: WorkoutCategory.hiit,
      instructions: ['Step 1', 'Step 2'],
      commonMistakes: ['Mistake 1'],
      bodyFocuses: [WorkoutBodyFocus.fullBody],
      goals: [WorkoutGoal.fatLoss, WorkoutGoal.endurance],
      isBodyweight: true,
      isCompound: true,
      isRecommended: true,
      addedAt: DateTime(2024, 1, 2),
    ),
    WorkoutLibraryEntry(
      id: '3',
      name: 'Morning Yoga Flow',
      primaryTargets: ['Flexibility'],
      secondaryTargets: ['Core', 'Balance'],
      difficulty: WorkoutDifficulty.beginner,
      equipment: WorkoutEquipment.yogaMat,
      durationMinutes: 20,
      category: WorkoutCategory.yoga,
      instructions: ['Step 1', 'Step 2'],
      commonMistakes: ['Mistake 1'],
      bodyFocuses: [WorkoutBodyFocus.fullBody],
      goals: [WorkoutGoal.mobility],
      isBodyweight: true,
      isCompound: false,
      isRecommended: true,
      addedAt: DateTime(2024, 1, 3),
    ),
  ];

  Widget createTestWidget({List<WorkoutLibraryEntry>? entries}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        workoutLibraryFiltersProvider.overrideWith(
          (ref) => WorkoutLibraryFiltersNotifier(mockPrefs),
        ),
        fitnessProfileProvider.overrideWith(
          (ref) => FitnessProfileNotifier(mockPrefs),
        ),
        workoutLibraryProvider.overrideWith(
          (ref) => entries ?? testEntries,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WorkoutLibraryScreen(),
      ),
    );
  }

  group('WorkoutLibraryScreen', () {
    testWidgets('renders workout library screen with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Find Workouts'), findsOneWidget);
    });

    testWidgets('displays workout entries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify at least one workout is displayed (first one should always be visible)
      expect(find.text('Full Body Strength'), findsOneWidget);
    });

    testWidgets('shows workout duration in info chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for at least one duration display
      expect(find.textContaining('min'), findsWidgets);
    });

    testWidgets('shows workout difficulty in info chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify at least one difficulty level is shown
      expect(find.textContaining('Intermediate'), findsWidgets);
    });

    testWidgets('displays filter chips for categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for filter chips
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('shows recommended filter chip', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for Recommended filter chip
      expect(find.text('Recommended'), findsWidgets);
    });

    testWidgets('shows empty state when no workouts available', (tester) async {
      await tester.pumpWidget(createTestWidget(entries: []));
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.textContaining('No workouts match'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('shows workout count', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show "Showing X workouts"
      expect(find.textContaining('Showing'), findsOneWidget);
      expect(find.textContaining('workouts'), findsOneWidget);
    });

    testWidgets('displays browse by focus section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for "Browse by focus" section header
      expect(find.text('Browse by focus'), findsOneWidget);
    });

    testWidgets('has view all button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('search field is present with placeholder', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify search field exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by workout, goal, or equipment'), findsOneWidget);
    });

    testWidgets('filter button is in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for filter (tune) icon button
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('exercise library button is in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for exercise library (fitness_center) icon button
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('workout cards contain info chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for timer icon (used for duration)
      expect(find.byIcon(Icons.timer), findsWidgets);

      // Look for fitness center icon (used for equipment)
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
    });

    testWidgets('can interact with filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a filter chip
      final filterChips = find.byType(FilterChip);
      expect(filterChips, findsWidgets);

      // Tap the first filter chip (Recommended)
      await tester.tap(filterChips.first);
      await tester.pumpAndSettle();

      // Should still render the screen
      expect(find.text('Find Workouts'), findsOneWidget);
    });
  });
}
