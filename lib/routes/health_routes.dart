import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/health/presentation/screens/health_details_screen.dart';
import '../features/health/presentation/screens/health_sync_screen.dart';
import '../features/health/presentation/screens/health_insights_screen.dart';

/// Health feature routes
List<GoRoute> healthRoutes = [
  GoRoute(
    path: RouteConstants.healthSync,
    name: 'healthSync',
    builder: (context, state) => const HealthSyncScreen(),
  ),
  GoRoute(
    path: RouteConstants.healthDetails,
    name: 'healthDetails',
    builder: (context, state) => const HealthDetailsScreen(),
  ),
  GoRoute(
    path: RouteConstants.healthInsights,
    name: 'healthInsights',
    builder: (context, state) => const HealthInsightsScreen(),
  ),
];
