import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/workouts/presentation/screens/workout_library_screen.dart';
import 'package:kinesa/features/workouts/presentation/providers/workout_providers.dart';
import 'package:kinesa/features/workouts/domain/models/workout.dart';
import 'package:kinesa/features/workouts/domain/models/exercise.dart';
import 'package:kinesa/core/theme/app_theme.dart';

void main() {
  final testWorkouts = [
    Workout(
      id: '1',
      name: 'Full Body Strength',
      description: 'Build muscle with compound movements',
      difficulty: WorkoutDifficulty.intermediate,
      estimatedDuration: 45,
      category: WorkoutCategory.strength,
      caloriesBurned: 350,
      equipment: 'Dumbbells',
      exercises: [
        Exercise(
          id: '1',
          name: 'Squats',
          description: 'Lower body exercise',
          type: ExerciseType.reps,
          muscleGroups: ['Legs'],
          metrics: ExerciseMetrics(sets: 3, reps: 12, restTime: 60),
        ),
      ],
    ),
    Workout(
      id: '2',
      name: 'HIIT Cardio Blast',
      description: 'High intensity interval training',
      difficulty: WorkoutDifficulty.advanced,
      estimatedDuration: 30,
      category: WorkoutCategory.hiit,
      caloriesBurned: 400,
      exercises: [
        Exercise(
          id: '2',
          name: 'Burpees',
          description: 'Full body exercise',
          type: ExerciseType.duration,
          muscleGroups: ['Full Body'],
          metrics: ExerciseMetrics(sets: 4, duration: 30, restTime: 30),
        ),
      ],
    ),
    Workout(
      id: '3',
      name: 'Morning Yoga Flow',
      description: 'Gentle stretching and flexibility',
      difficulty: WorkoutDifficulty.beginner,
      estimatedDuration: 20,
      category: WorkoutCategory.yoga,
      caloriesBurned: 100,
      exercises: [],
    ),
  ];

  Widget createTestWidget({List<Workout>? workouts}) {
    return ProviderScope(
      overrides: [
        workoutsProvider.overrideWith(
          (ref, filters) => Stream.value(workouts ?? testWorkouts),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WorkoutLibraryScreen(),
      ),
    );
  }

  group('WorkoutLibraryScreen', () {
    testWidgets('renders workout library screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Workouts'), findsWidgets);
    });

    testWidgets('displays list of workouts', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify workouts are displayed
      expect(find.text('Full Body Strength'), findsOneWidget);
      expect(find.text('HIIT Cardio Blast'), findsOneWidget);
      expect(find.text('Morning Yoga Flow'), findsOneWidget);
    });

    testWidgets('shows workout duration', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify duration is shown (45 min, 30 min, 20 min)
      expect(find.textContaining('45'), findsWidgets);
      expect(find.textContaining('min'), findsWidgets);
    });

    testWidgets('shows workout difficulty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify difficulty levels are shown
      expect(find.textContaining('Intermediate'), findsWidgets);
      expect(find.textContaining('Advanced'), findsWidgets);
      expect(find.textContaining('Beginner'), findsWidgets);
    });

    testWidgets('displays workout categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for category chips/tabs
      expect(find.textContaining('Strength'), findsWidgets);
      expect(find.textContaining('HIIT'), findsWidgets);
      expect(find.textContaining('Yoga'), findsWidgets);
    });

    testWidgets('shows loading indicator while fetching workouts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutsProvider.overrideWith(
              (ref, filters) => Stream<List<Workout>>.fromFuture(
                Future.delayed(const Duration(seconds: 10), () => <Workout>[]),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const WorkoutLibraryScreen(),
          ),
        ),
      );
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows empty state when no workouts available', (tester) async {
      await tester.pumpWidget(createTestWidget(workouts: []));
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.textContaining('No workouts'), findsWidgets);
    });

    testWidgets('shows error state when fetch fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutsProvider.overrideWith(
              (ref, filters) => Stream<List<Workout>>.error(Exception('Network error')),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const WorkoutLibraryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('displays calorie burn estimate', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify calories are shown (350, 400, 100)
      expect(find.textContaining('350'), findsWidgets);
    });

    testWidgets('can tap on workout to view details', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap on a workout card
      final workoutCard = find.text('Full Body Strength');
      expect(workoutCard, findsOneWidget);

      // Tapping should not throw
      await tester.tap(workoutCard);
      await tester.pumpAndSettle();
    });

    testWidgets('filter chips are displayed', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for filter options
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('workout cards show exercise count', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show exercise count
      expect(find.textContaining('exercise'), findsWidgets);
    });
  });
}
