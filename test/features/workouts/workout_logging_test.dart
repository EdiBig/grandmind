import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/workouts/domain/models/exercise.dart';

/// Test exercise type detection logic
void main() {
  group('Exercise Type Detection', () {
    ExerciseType detectExerciseType(String exerciseName) {
      final nameLower = exerciseName.toLowerCase();

      // Duration-based exercises
      const durationExercises = [
        'plank', 'hold', 'stretch', 'yoga', 'pose', 'meditation',
        'wall sit', 'dead hang', 'isometric', 'static',
      ];
      for (final keyword in durationExercises) {
        if (nameLower.contains(keyword)) {
          return ExerciseType.duration;
        }
      }

      // Distance-based exercises
      const distanceExercises = [
        'running', 'run', 'cycling', 'bike', 'swimming', 'swim',
        'rowing', 'row', 'walking', 'walk', 'sprint', 'jog',
        'hiking', 'hike', 'marathon', 'lap',
      ];
      for (final keyword in distanceExercises) {
        if (nameLower.contains(keyword)) {
          return ExerciseType.distance;
        }
      }

      // Default to reps for strength/other exercises
      return ExerciseType.reps;
    }

    test('detects reps-based exercises', () {
      expect(detectExerciseType('Push-ups'), ExerciseType.reps);
      expect(detectExerciseType('Squats'), ExerciseType.reps);
      expect(detectExerciseType('Bench Press'), ExerciseType.reps);
      expect(detectExerciseType('Bicep Curls'), ExerciseType.reps);
      expect(detectExerciseType('Deadlifts'), ExerciseType.reps);
    });

    test('detects duration-based exercises', () {
      expect(detectExerciseType('Plank'), ExerciseType.duration);
      expect(detectExerciseType('Plank Hold'), ExerciseType.duration);
      expect(detectExerciseType('Yoga'), ExerciseType.duration);
      expect(detectExerciseType('Warrior Pose'), ExerciseType.duration);
      expect(detectExerciseType('Wall Sit'), ExerciseType.duration);
      expect(detectExerciseType('Hamstring Stretch'), ExerciseType.duration);
      expect(detectExerciseType('Dead Hang'), ExerciseType.duration);
      expect(detectExerciseType('Isometric Hold'), ExerciseType.duration);
    });

    test('detects distance-based exercises', () {
      expect(detectExerciseType('Running'), ExerciseType.distance);
      expect(detectExerciseType('5K Run'), ExerciseType.distance);
      expect(detectExerciseType('Cycling'), ExerciseType.distance);
      expect(detectExerciseType('Bike Ride'), ExerciseType.distance);
      expect(detectExerciseType('Swimming'), ExerciseType.distance);
      expect(detectExerciseType('Pool Swim'), ExerciseType.distance);
      expect(detectExerciseType('Walking'), ExerciseType.distance);
      expect(detectExerciseType('Morning Walk'), ExerciseType.distance);
      expect(detectExerciseType('Sprint'), ExerciseType.distance);
      expect(detectExerciseType('Rowing'), ExerciseType.distance);
      expect(detectExerciseType('Marathon Training'), ExerciseType.distance);
    });

    test('handles mixed case and variations', () {
      expect(detectExerciseType('PLANK'), ExerciseType.duration);
      expect(detectExerciseType('running'), ExerciseType.distance);
      expect(detectExerciseType('Push-Ups'), ExerciseType.reps);
      expect(detectExerciseType('SQUATS'), ExerciseType.reps);
    });
  });
}
