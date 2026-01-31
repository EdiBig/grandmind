import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/progress/presentation/screens/progress_insights_screen.dart';
import '../features/progress/presentation/screens/progress_dashboard_screen.dart';
import '../features/progress/presentation/screens/weekly_summary_screen.dart';
import '../features/progress/presentation/screens/weight_tracking_screen.dart';
import '../features/progress/presentation/screens/measurements_screen.dart';
import '../features/progress/presentation/screens/goals_screen.dart';
import '../features/progress/presentation/screens/create_goal_screen.dart';
import '../features/progress/presentation/screens/progress_photos_screen.dart';
import '../features/progress/presentation/screens/progress_comparison_screen.dart';
import '../features/progress/presentation/screens/activity_calendar_screen.dart';
import '../features/progress/presentation/screens/personal_bests_screen.dart';

/// Progress feature routes
List<GoRoute> progressRoutes = [
  GoRoute(
    path: RouteConstants.progressInsights,
    name: 'progressInsights',
    builder: (context, state) => const ProgressInsightsScreen(),
  ),
  GoRoute(
    path: RouteConstants.progressDashboard,
    name: 'progressDashboard',
    builder: (context, state) => const ProgressDashboardScreen(),
  ),
  GoRoute(
    path: RouteConstants.weeklySummary,
    name: 'weeklySummary',
    builder: (context, state) => const WeeklySummaryScreen(),
  ),
  GoRoute(
    path: RouteConstants.weightTracking,
    name: 'weightTracking',
    builder: (context, state) => const WeightTrackingScreen(),
  ),
  GoRoute(
    path: RouteConstants.measurements,
    name: 'measurements',
    builder: (context, state) => const MeasurementsScreen(),
  ),
  GoRoute(
    path: RouteConstants.goals,
    name: 'goals',
    builder: (context, state) => const GoalsScreen(),
  ),
  GoRoute(
    path: RouteConstants.createGoal,
    name: 'createGoal',
    builder: (context, state) => const CreateGoalScreen(),
  ),
  GoRoute(
    path: RouteConstants.progressPhotos,
    name: 'progressPhotos',
    builder: (context, state) => const ProgressPhotosScreen(),
  ),
  GoRoute(
    path: RouteConstants.photoComparison,
    name: 'photoComparison',
    builder: (context, state) => const ProgressComparisonScreen(),
  ),
  GoRoute(
    path: RouteConstants.activityCalendar,
    name: 'activityCalendar',
    builder: (context, state) => const ActivityCalendarScreen(),
  ),
  GoRoute(
    path: RouteConstants.personalBests,
    name: 'personalBests',
    builder: (context, state) => const PersonalBestsScreen(),
  ),
];
