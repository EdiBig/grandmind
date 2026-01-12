import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:kinesa/firebase_options.dart';
import 'package:kinesa/features/workouts/data/seed_workouts.dart';

Future<void> main() async {
  debugPrint('Starting workout seeding...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Firebase initialized');

    await seedWorkouts();

    debugPrint('Workout seeding completed!');
  } catch (e) {
    debugPrint('Error seeding workouts: $e');
  }
}
