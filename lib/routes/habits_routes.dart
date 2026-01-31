import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/habits/presentation/screens/create_habit_screen.dart';
import '../features/habits/presentation/screens/habit_insights_screen.dart';
import '../features/habits/presentation/screens/habit_calendar_screen.dart';
import '../features/habits/presentation/screens/habit_history_screen.dart';
import '../features/habits/data/services/habit_insights_service.dart';

/// Habits feature routes
List<GoRoute> habitsRoutes = [
  GoRoute(
    path: RouteConstants.createHabit,
    name: 'createHabit',
    builder: (context, state) => const CreateHabitScreen(),
  ),
  GoRoute(
    path: RouteConstants.editHabit,
    name: 'editHabit',
    builder: (context, state) {
      final habitId = state.pathParameters['id'];
      return CreateHabitScreen(habitId: habitId);
    },
  ),
  GoRoute(
    path: '/habits/insights',
    name: 'habitInsights',
    builder: (context, state) {
      final insights = state.extra as HabitInsights;
      return HabitInsightsScreen(insights: insights);
    },
  ),
  GoRoute(
    path: RouteConstants.habitCalendar,
    name: 'habitCalendar',
    builder: (context, state) {
      final habitId = state.extra as String?;
      return HabitCalendarScreen(habitId: habitId);
    },
  ),
  GoRoute(
    path: RouteConstants.habitHistory,
    name: 'habitHistory',
    builder: (context, state) {
      final selectedDate = state.extra as DateTime?;
      return HabitHistoryScreen(selectedDate: selectedDate);
    },
  ),
  GoRoute(
    path: RouteConstants.habitDetailHistory,
    name: 'habitDetailHistory',
    builder: (context, state) {
      final habitId = state.pathParameters['id'] ?? '';
      return HabitHistoryScreen(habitId: habitId);
    },
  ),
];
