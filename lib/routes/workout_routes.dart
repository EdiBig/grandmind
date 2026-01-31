import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/workouts/presentation/screens/fitness_profile_screen.dart';
import '../features/workouts/presentation/screens/my_routines_screen.dart';
import '../features/workouts/presentation/screens/workout_admin_screen.dart';
import '../features/workouts/presentation/screens/wger_exercises_screen.dart';

/// Workout feature routes
List<GoRoute> workoutRoutes = [
  GoRoute(
    path: RouteConstants.fitnessProfile,
    name: 'fitnessProfile',
    builder: (context, state) => const FitnessProfileScreen(),
  ),
  GoRoute(
    path: RouteConstants.myRoutines,
    name: 'myRoutines',
    builder: (context, state) => const MyRoutinesScreen(),
  ),
  GoRoute(
    path: RouteConstants.workoutAdmin,
    name: 'workoutAdmin',
    builder: (context, state) => const WorkoutAdminScreen(),
  ),
  GoRoute(
    path: RouteConstants.wgerExercises,
    name: 'wgerExercises',
    builder: (context, state) => const WgerExercisesScreen(),
  ),
];
