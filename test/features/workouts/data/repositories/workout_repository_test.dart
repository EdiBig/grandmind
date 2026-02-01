import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/workouts/domain/models/workout.dart';
import 'package:kinesa/features/workouts/domain/models/workout_log.dart';
import 'package:kinesa/features/workouts/domain/models/exercise.dart';
import '../../../../helpers/test_fixtures.dart';

/// Note: WorkoutRepository uses FirebaseFirestore.instance internally,
/// making it difficult to inject a fake Firestore for true unit tests.
///
/// These tests focus on:
/// 1. Testing model serialization/deserialization
/// 2. Testing enum behavior and display names
/// 3. Documenting expected repository behavior

void main() {
  group('WorkoutRepository Model Tests', () {
    group('Workout Model', () {
      test('creates workout with required fields', () {
        final workout = createTestWorkout(
          name: 'Morning HIIT',
          description: 'High intensity interval training',
          category: WorkoutCategory.hiit,
          difficulty: WorkoutDifficulty.intermediate,
        );

        expect(workout.name, equals('Morning HIIT'));
        expect(workout.description, equals('High intensity interval training'));
        expect(workout.category, equals(WorkoutCategory.hiit));
        expect(workout.difficulty, equals(WorkoutDifficulty.intermediate));
      });

      test('workout has exercises list', () {
        final workout = createTestWorkout();

        expect(workout.exercises, isNotEmpty);
        expect(workout.exercises.first.name, isNotEmpty);
      });

      test('workout serializes to JSON', () {
        final workout = createTestWorkout();
        final json = workout.toJson();

        expect(json['name'], equals('Full Body Workout'));
        expect(json['category'], equals('strength'));
        expect(json['difficulty'], equals('intermediate'));
        expect(json['exercises'], isA<List>());
      });

      test('workout deserializes from JSON', () {
        final json = {
          'id': 'workout-123',
          'name': 'Leg Day',
          'description': 'Focus on lower body strength',
          'category': 'strength',
          'difficulty': 'advanced',
          'estimatedDuration': 60,
          'exercises': [],
          'caloriesBurned': 400,
          'tags': ['legs', 'strength'],
        };

        final workout = Workout.fromJson(json);

        expect(workout.name, equals('Leg Day'));
        expect(workout.category, equals(WorkoutCategory.strength));
        expect(workout.difficulty, equals(WorkoutDifficulty.advanced));
        expect(workout.estimatedDuration, equals(60));
        expect(workout.caloriesBurned, equals(400));
      });

      test('workout with optional fields', () {
        final workout = createTestWorkout(
          equipment: 'Dumbbells, Resistance Bands',
          tags: ['home', 'no-gym'],
        );

        expect(workout.equipment, equals('Dumbbells, Resistance Bands'));
        expect(workout.tags, contains('home'));
        expect(workout.tags, contains('no-gym'));
      });
    });

    group('WorkoutDifficulty Enum', () {
      test('has correct display names', () {
        expect(
            WorkoutDifficulty.beginner.displayName, equals('Beginner'));
        expect(
            WorkoutDifficulty.intermediate.displayName, equals('Intermediate'));
        expect(WorkoutDifficulty.advanced.displayName, equals('Advanced'));
      });

      test('has correct descriptions', () {
        expect(WorkoutDifficulty.beginner.description,
            contains('new to exercise'));
        expect(WorkoutDifficulty.intermediate.description,
            contains('6+ months'));
        expect(
            WorkoutDifficulty.advanced.description, contains('2+ years'));
      });

      test('all values are represented', () {
        expect(WorkoutDifficulty.values.length, equals(3));
      });
    });

    group('WorkoutCategory Enum', () {
      test('has correct display names', () {
        expect(WorkoutCategory.strength.displayName, equals('Strength'));
        expect(WorkoutCategory.cardio.displayName, equals('Cardio'));
        expect(WorkoutCategory.flexibility.displayName, equals('Flexibility'));
        expect(WorkoutCategory.hiit.displayName, equals('HIIT'));
        expect(WorkoutCategory.yoga.displayName, equals('Yoga'));
        expect(WorkoutCategory.sports.displayName, equals('Sports'));
        expect(WorkoutCategory.other.displayName, equals('Other'));
      });

      test('all values are represented', () {
        expect(WorkoutCategory.values.length, equals(7));
      });
    });

    group('Exercise Model', () {
      test('creates exercise with required fields', () {
        final exercise = createTestExercise(
          name: 'Squats',
          description: 'Lower body compound movement',
          type: ExerciseType.reps,
        );

        expect(exercise.name, equals('Squats'));
        expect(exercise.description, equals('Lower body compound movement'));
        expect(exercise.type, equals(ExerciseType.reps));
      });

      test('exercise with muscle groups', () {
        final exercise = createTestExercise(
          muscleGroups: ['Quadriceps', 'Glutes', 'Hamstrings'],
        );

        expect(exercise.muscleGroups, contains('Quadriceps'));
        expect(exercise.muscleGroups, contains('Glutes'));
        expect(exercise.muscleGroups?.length, equals(3));
      });

      test('exercise with metrics', () {
        final exercise = createTestExercise(
          metrics: ExerciseMetrics(
            sets: 4,
            reps: 10,
            weight: 50,
            restTime: 90,
          ),
        );

        expect(exercise.metrics?.sets, equals(4));
        expect(exercise.metrics?.reps, equals(10));
        expect(exercise.metrics?.weight, equals(50));
        expect(exercise.metrics?.restTime, equals(90));
      });

      test('exercise serializes to JSON', () {
        final exercise = createTestExercise();
        final json = exercise.toJson();

        expect(json['name'], equals('Push Ups'));
        expect(json['type'], equals('reps'));
      });

      test('exercise deserializes from JSON', () {
        final json = {
          'id': 'ex-123',
          'name': 'Bench Press',
          'description': 'Chest compound exercise',
          'type': 'reps',
          'muscleGroups': ['Chest', 'Triceps', 'Shoulders'],
          'equipment': 'Barbell, Bench',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.name, equals('Bench Press'));
        expect(exercise.type, equals(ExerciseType.reps));
        expect(exercise.muscleGroups, contains('Chest'));
      });
    });

    group('ExerciseType Enum', () {
      test('has correct display names', () {
        expect(ExerciseType.reps.displayName, equals('Reps'));
        expect(ExerciseType.duration.displayName, equals('Duration'));
        expect(ExerciseType.distance.displayName, equals('Distance'));
      });

      test('all values are represented', () {
        expect(ExerciseType.values.length, equals(3));
      });
    });

    group('ExerciseMetrics Model', () {
      test('creates metrics with all fields', () {
        final metrics = ExerciseMetrics(
          sets: 3,
          reps: 12,
          weight: 25,
          duration: 60,
          distance: 5.0,
          restTime: 45,
        );

        expect(metrics.sets, equals(3));
        expect(metrics.reps, equals(12));
        expect(metrics.weight, equals(25));
        expect(metrics.duration, equals(60));
        expect(metrics.distance, equals(5.0));
        expect(metrics.restTime, equals(45));
      });

      test('metrics serializes to JSON', () {
        final metrics = ExerciseMetrics(sets: 3, reps: 10);
        final json = metrics.toJson();

        expect(json['sets'], equals(3));
        expect(json['reps'], equals(10));
      });
    });

    group('WorkoutLog Model', () {
      test('creates workout log with required fields', () {
        final log = createTestWorkoutLog(
          workoutName: 'Upper Body Strength',
          duration: 45,
          caloriesBurned: 300,
        );

        expect(log.workoutName, equals('Upper Body Strength'));
        expect(log.duration, equals(45));
        expect(log.caloriesBurned, equals(300));
        expect(log.exercises, isNotEmpty);
      });

      test('workout log has user and workout reference', () {
        final log = createTestWorkoutLog();

        expect(log.userId, equals(testUserId));
        expect(log.workoutId, equals('workout-123'));
      });

      test('workout log serializes to JSON', () {
        final log = createTestWorkoutLog();
        final json = log.toJson();

        expect(json['userId'], equals(testUserId));
        expect(json['workoutId'], isNotNull);
        expect(json['workoutName'], isNotEmpty);
        expect(json['duration'], isA<int>());
        expect(json['exercises'], isA<List>());
      });

      test('workout log with notes', () {
        final log = createTestWorkoutLog(
          notes: 'Felt strong today, increased weight on squats',
        );

        expect(log.notes, contains('strong'));
        expect(log.notes, contains('squats'));
      });

      test('workout log with category and difficulty', () {
        final log = createTestWorkoutLog(
          category: WorkoutCategory.strength,
        );

        expect(log.category, equals(WorkoutCategory.strength));
      });
    });

    group('ExerciseLog Model', () {
      test('creates exercise log with required fields', () {
        final exerciseLog = createTestExerciseLog(
          exerciseName: 'Deadlift',
          type: ExerciseType.reps,
        );

        expect(exerciseLog.exerciseName, equals('Deadlift'));
        expect(exerciseLog.type, equals(ExerciseType.reps));
        expect(exerciseLog.sets, isNotEmpty);
      });

      test('exercise log serializes to JSON', () {
        final exerciseLog = createTestExerciseLog();
        final json = exerciseLog.toJson();

        expect(json['exerciseId'], isNotNull);
        expect(json['exerciseName'], isNotEmpty);
        expect(json['type'], isNotNull);
        expect(json['sets'], isA<List>());
      });
    });

    group('SetLog Model', () {
      test('creates set log for reps', () {
        final setLog = createTestSetLog(
          setNumber: 1,
          reps: 12,
          weight: 50,
        );

        expect(setLog.setNumber, equals(1));
        expect(setLog.reps, equals(12));
        expect(setLog.weight, equals(50));
      });

      test('creates set log for duration', () {
        final setLog = SetLog(
          setNumber: 1,
          duration: 60,
        );

        expect(setLog.setNumber, equals(1));
        expect(setLog.duration, equals(60));
        expect(setLog.reps, isNull);
      });

      test('creates set log for distance', () {
        final setLog = SetLog(
          setNumber: 1,
          distance: 5.0,
        );

        expect(setLog.setNumber, equals(1));
        expect(setLog.distance, equals(5.0));
      });

      test('set log serializes to JSON', () {
        final setLog = createTestSetLog();
        final json = setLog.toJson();

        expect(json['setNumber'], isA<int>());
      });
    });
  });

  group('Test Fixtures', () {
    test('createTestWorkout creates valid workout', () {
      final workout = createTestWorkout();

      expect(workout.id, isNotEmpty);
      expect(workout.name, isNotEmpty);
      expect(workout.exercises, isNotEmpty);
    });

    test('createTestExercise creates valid exercise', () {
      final exercise = createTestExercise();

      expect(exercise.id, isNotEmpty);
      expect(exercise.name, isNotEmpty);
      expect(exercise.type, isNotNull);
    });

    test('createTestWorkoutLog creates valid workout log', () {
      final log = createTestWorkoutLog();

      expect(log.id, isNotEmpty);
      expect(log.userId, equals(testUserId));
      expect(log.workoutId, isNotEmpty);
      expect(log.exercises, isNotEmpty);
    });

    test('createTestExerciseLog creates valid exercise log', () {
      final exerciseLog = createTestExerciseLog();

      expect(exerciseLog.exerciseId, isNotEmpty);
      expect(exerciseLog.exerciseName, isNotEmpty);
      expect(exerciseLog.sets, isNotEmpty);
    });

    test('createTestSetLog creates valid set log', () {
      final setLog = createTestSetLog();

      expect(setLog.setNumber, greaterThan(0));
    });
  });
}
