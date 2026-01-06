import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/workout.dart';
import '../domain/models/exercise.dart';

/// Seed initial workout templates to Firestore
Future<void> seedWorkouts() async {
  final firestore = FirebaseFirestore.instance;
  final workoutsCollection = firestore.collection('workouts');

  // Check if workouts already exist
  final existingWorkouts = await workoutsCollection.limit(1).get();
  if (existingWorkouts.docs.isNotEmpty) {
    print('Workouts already seeded');
    return;
  }

  final workouts = [
    Workout(
      id: '',
      name: 'Full Body Strength',
      description: 'Build muscle and strength with compound movements',
      difficulty: WorkoutDifficulty.intermediate,
      estimatedDuration: 45,
      category: WorkoutCategory.strength,
      caloriesBurned: 350,
      equipment: 'Dumbbells, Barbell',
      exercises: [
        Exercise(
          id: '1',
          name: 'Squats',
          description: 'Stand with feet shoulder-width apart, lower down as if sitting',
          type: ExerciseType.reps,
          muscleGroups: ['Legs', 'Glutes'],
          equipment: 'Barbell',
          metrics: ExerciseMetrics(
            sets: 3,
            reps: 12,
            restTime: 60,
          ),
        ),
        Exercise(
          id: '2',
          name: 'Push-ups',
          description: 'Classic upper body exercise',
          type: ExerciseType.reps,
          muscleGroups: ['Chest', 'Triceps'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 3,
            reps: 15,
            restTime: 60,
          ),
        ),
        Exercise(
          id: '3',
          name: 'Bent-over Rows',
          description: 'Pull the weight to your lower chest',
          type: ExerciseType.reps,
          muscleGroups: ['Back', 'Biceps'],
          equipment: 'Dumbbells',
          metrics: ExerciseMetrics(
            sets: 3,
            reps: 12,
            restTime: 60,
          ),
        ),
      ],
    ),
    Workout(
      id: '',
      name: 'HIIT Cardio Blast',
      description: 'High intensity interval training for fat burning',
      difficulty: WorkoutDifficulty.advanced,
      estimatedDuration: 30,
      category: WorkoutCategory.hiit,
      caloriesBurned: 400,
      equipment: 'None',
      exercises: [
        Exercise(
          id: '4',
          name: 'Burpees',
          description: 'Full body explosive movement',
          type: ExerciseType.duration,
          muscleGroups: ['Full Body'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 4,
            duration: 30,
            restTime: 30,
          ),
        ),
        Exercise(
          id: '5',
          name: 'Mountain Climbers',
          description: 'Fast-paced core and cardio exercise',
          type: ExerciseType.duration,
          muscleGroups: ['Core', 'Shoulders'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 4,
            duration: 30,
            restTime: 30,
          ),
        ),
        Exercise(
          id: '6',
          name: 'Jump Squats',
          description: 'Explosive squat variation',
          type: ExerciseType.reps,
          muscleGroups: ['Legs'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 4,
            reps: 15,
            restTime: 30,
          ),
        ),
      ],
    ),
    Workout(
      id: '',
      name: 'Yoga Flow',
      description: 'Flexibility and mindfulness for body and mind',
      difficulty: WorkoutDifficulty.beginner,
      estimatedDuration: 60,
      category: WorkoutCategory.yoga,
      caloriesBurned: 180,
      equipment: 'Yoga Mat',
      exercises: [
        Exercise(
          id: '7',
          name: 'Sun Salutation',
          description: 'Traditional yoga warm-up sequence',
          type: ExerciseType.reps,
          muscleGroups: ['Full Body'],
          equipment: 'Yoga Mat',
          metrics: ExerciseMetrics(
            sets: 5,
            reps: 1,
            restTime: 15,
          ),
        ),
        Exercise(
          id: '8',
          name: 'Warrior Poses',
          description: 'Strength and balance poses',
          type: ExerciseType.duration,
          muscleGroups: ['Legs', 'Core'],
          equipment: 'Yoga Mat',
          metrics: ExerciseMetrics(
            sets: 3,
            duration: 60,
            restTime: 30,
          ),
        ),
        Exercise(
          id: '9',
          name: 'Savasana',
          description: 'Final relaxation pose',
          type: ExerciseType.duration,
          muscleGroups: ['Full Body'],
          equipment: 'Yoga Mat',
          metrics: ExerciseMetrics(
            sets: 1,
            duration: 300,
          ),
        ),
      ],
    ),
    Workout(
      id: '',
      name: 'Core Crusher',
      description: 'Strengthen your core with targeted exercises',
      difficulty: WorkoutDifficulty.intermediate,
      estimatedDuration: 20,
      category: WorkoutCategory.strength,
      caloriesBurned: 150,
      equipment: 'None',
      exercises: [
        Exercise(
          id: '10',
          name: 'Plank',
          description: 'Hold a strong plank position',
          type: ExerciseType.duration,
          muscleGroups: ['Core', 'Shoulders'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 3,
            duration: 60,
            restTime: 30,
          ),
        ),
        Exercise(
          id: '11',
          name: 'Russian Twists',
          description: 'Rotational core exercise',
          type: ExerciseType.reps,
          muscleGroups: ['Core', 'Obliques'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 3,
            reps: 20,
            restTime: 30,
          ),
        ),
        Exercise(
          id: '12',
          name: 'Bicycle Crunches',
          description: 'Dynamic abdominal exercise',
          type: ExerciseType.reps,
          muscleGroups: ['Core'],
          equipment: 'Bodyweight',
          metrics: ExerciseMetrics(
            sets: 3,
            reps: 20,
            restTime: 30,
          ),
        ),
      ],
    ),
  ];

  // Add workouts to Firestore
  for (final workout in workouts) {
    final workoutData = workout.toJson();
    workoutData.remove('id');
    workoutData['createdAt'] = FieldValue.serverTimestamp();
    await workoutsCollection.add(workoutData);
  }

  print('Successfully seeded ${workouts.length} workouts');
}
