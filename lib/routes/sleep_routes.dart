import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/sleep/presentation/screens/log_sleep_screen.dart';
import '../features/sleep/presentation/screens/sleep_history_screen.dart';
import '../features/sleep/domain/models/sleep_log.dart';

/// Sleep feature routes
List<GoRoute> sleepRoutes = [
  GoRoute(
    path: RouteConstants.logSleep,
    name: 'logSleep',
    builder: (context, state) {
      final existingLog = state.extra as SleepLog?;
      return LogSleepScreen(existingLog: existingLog);
    },
  ),
  GoRoute(
    path: RouteConstants.sleepHistory,
    name: 'sleepHistory',
    builder: (context, state) => const SleepHistoryScreen(),
  ),
];
