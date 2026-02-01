import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/log_activity_screen.dart';
import '../features/home/presentation/screens/achievements_screen.dart';

/// Home and main tab routes
/// [scheduleHomeTab] is a callback to set the selected tab index
List<GoRoute> homeRoutes(void Function(int) scheduleHomeTab) => [
  GoRoute(
    path: RouteConstants.home,
    name: 'home',
    builder: (context, state) {
      scheduleHomeTab(0);
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: RouteConstants.workouts,
    name: 'workouts',
    builder: (context, state) {
      scheduleHomeTab(1);
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: RouteConstants.habits,
    name: 'habits',
    builder: (context, state) {
      scheduleHomeTab(2);
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: RouteConstants.progress,
    name: 'progress',
    builder: (context, state) {
      scheduleHomeTab(3);
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: RouteConstants.logActivity,
    name: 'logActivity',
    builder: (context, state) => const LogActivityScreen(),
  ),
  GoRoute(
    path: RouteConstants.achievements,
    name: 'achievements',
    builder: (context, state) => const AchievementsScreen(),
  ),
];
