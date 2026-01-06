import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/features/workouts/data/seed_workouts.dart';

Future<void> main() async {
  print('Starting workout seeding...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Firebase initialized');

    await seedWorkouts();

    print('Workout seeding completed!');
  } catch (e) {
    print('Error seeding workouts: $e');
  }
}
