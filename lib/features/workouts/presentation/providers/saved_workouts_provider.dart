import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/user_saved_workout.dart';

final savedWorkoutsStreamProvider =
    StreamProvider<List<UserSavedWorkout>>((ref) async* {
  final authState = ref.watch(authStateProvider);

  // Wait for auth state to resolve - don't return empty if still loading
  if (authState.isLoading) {
    return; // Stream will wait, not emit empty
  }

  final userId = authState.asData?.value?.uid;
  if (userId == null) {
    yield []; // User not logged in, return empty list
    return;
  }

  final repository = ref.watch(workoutRepositoryProvider);
  yield* repository.getUserSavedWorkoutsStream(userId);
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
