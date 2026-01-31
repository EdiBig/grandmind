import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/mood_energy/presentation/screens/log_mood_energy_screen.dart';
import '../features/mood_energy/presentation/screens/mood_energy_history_screen.dart';
import '../features/mood_energy/presentation/screens/mood_energy_insights_screen.dart';
import '../features/mood_energy/data/services/mood_energy_insights_service.dart';
import '../features/mood_energy/domain/models/energy_log.dart';

/// Mood & Energy feature routes
List<GoRoute> moodEnergyRoutes = [
  GoRoute(
    path: RouteConstants.logMoodEnergy,
    name: 'logMoodEnergy',
    builder: (context, state) {
      final existingLog = state.extra as EnergyLog?;
      return LogMoodEnergyScreen(existingLog: existingLog);
    },
  ),
  GoRoute(
    path: RouteConstants.moodEnergyHistory,
    name: 'moodEnergyHistory',
    builder: (context, state) => const MoodEnergyHistoryScreen(),
  ),
  GoRoute(
    path: RouteConstants.moodEnergyInsights,
    name: 'moodEnergyInsights',
    builder: (context, state) {
      final insights = state.extra as MoodEnergyInsights;
      return MoodEnergyInsightsScreen(insights: insights);
    },
  ),
];
