import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/ai/presentation/screens/ai_coach_screen.dart';
import '../features/ai/presentation/screens/ai_conversation_history_screen.dart';

/// AI Coach feature routes
List<GoRoute> aiRoutes = [
  GoRoute(
    path: RouteConstants.aiCoach,
    name: 'aiCoach',
    builder: (context, state) => const AICoachScreen(),
  ),
  GoRoute(
    path: RouteConstants.aiCoachHistory,
    name: 'aiCoachHistory',
    builder: (context, state) => const AIConversationHistoryScreen(),
  ),
];
