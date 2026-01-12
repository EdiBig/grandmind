import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/user_saved_workout.dart';

final savedWorkoutsStreamProvider =
    StreamProvider<List<UserSavedWorkout>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.empty();
  }
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUserSavedWorkoutsStream(userId);
});

final savedWorkoutsByWorkoutIdProvider =
    Provider<Map<String, UserSavedWorkout>>((ref) {
  final saved = ref.watch(savedWorkoutsStreamProvider);
  return saved.maybeWhen(
    data: (items) => {
      for (final item in items) item.workoutId: item,
    },
    orElse: () => {},
  );
});
