import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../user/data/models/user_model.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/data/services/user_stats_service.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../health/presentation/providers/health_providers.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Provider for current user data
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  // Watch auth state to react to login/logout
  final authState = ref.watch(authStateProvider);
  final userId = authState.asData?.value?.uid;

  if (userId == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  });
});

/// Provider for dashboard statistics
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const AsyncValue.data(DashboardStats());
  }

  final workoutStatsAsync = ref.watch(workoutStatsProvider);
  final habitStatsAsync = ref.watch(habitStatsProvider);
  final userStatsAsync = ref.watch(userStatsProvider);
  final recentWorkoutsAsync = ref.watch(recentWorkoutLogsProvider);
  final recentHabitsAsync = ref.watch(recentHabitLogsProvider);
  final healthSummaryAsync = ref.watch(healthSummaryProvider);

  if (workoutStatsAsync.isLoading ||
      habitStatsAsync.isLoading ||
      userStatsAsync.isLoading ||
      recentWorkoutsAsync.isLoading ||
      recentHabitsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (workoutStatsAsync.hasError) {
    return AsyncValue.error(
      workoutStatsAsync.error!,
      workoutStatsAsync.stackTrace!,
    );
  }
  if (habitStatsAsync.hasError) {
    return AsyncValue.error(
      habitStatsAsync.error!,
      habitStatsAsync.stackTrace!,
    );
  }
  if (userStatsAsync.hasError) {
    return AsyncValue.error(
      userStatsAsync.error!,
      userStatsAsync.stackTrace!,
    );
  }
  if (recentWorkoutsAsync.hasError) {
    return AsyncValue.error(
      recentWorkoutsAsync.error!,
      recentWorkoutsAsync.stackTrace!,
    );
  }
  if (recentHabitsAsync.hasError) {
    return AsyncValue.error(
      recentHabitsAsync.error!,
      recentHabitsAsync.stackTrace!,
    );
  }

  final workoutStats = workoutStatsAsync.asData?.value ?? {};
  final habitStats = habitStatsAsync.asData?.value ?? {};
  final userStats = userStatsAsync.asData?.value ?? UserStats.empty();
  final recentWorkouts = recentWorkoutsAsync.asData?.value ?? [];
  final recentHabits = recentHabitsAsync.asData?.value ?? [];
  final healthSummary = healthSummaryAsync.asData?.value;

  final lastWorkoutDate =
      recentWorkouts.isNotEmpty ? recentWorkouts.first.startedAt : null;
  final lastHabitDate =
      recentHabits.isNotEmpty ? recentHabits.last.completedAt : null;
  DateTime? lastActivityDate = lastWorkoutDate;
  if (lastHabitDate != null) {
    if (lastActivityDate == null || lastHabitDate.isAfter(lastActivityDate)) {
      lastActivityDate = lastHabitDate;
    }
  }

  return AsyncValue.data(
    DashboardStats(
      workoutsThisWeek: workoutStats['workoutsThisWeek'] as int? ?? 0,
      workoutsThisMonth: workoutStats['workoutsThisMonth'] as int? ?? 0,
      totalWorkouts: workoutStats['totalWorkouts'] as int? ?? 0,
      habitsCompleted: habitStats['completedToday'] as int? ?? 0,
      totalHabits: habitStats['totalHabits'] as int? ?? 0,
      habitCompletionRate:
          (habitStats['completionRate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: userStats.currentStreak,
      longestStreak: userStats.longestStreak,
      stepsToday: healthSummary?.steps ?? 0,
      hoursSlept: healthSummary?.sleepHours ?? 0.0,
      lastWorkoutDate: lastWorkoutDate,
      lastActivityDate: lastActivityDate,
    ),
  );
});

/// Provider for recent activities
final recentActivitiesProvider = Provider<AsyncValue<List<ActivityItem>>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const AsyncValue.data([]);
  }

  final recentWorkoutsAsync = ref.watch(recentWorkoutLogsProvider);
  final recentHabitsAsync = ref.watch(recentHabitLogsProvider);
  final habitsAsync = ref.watch(userHabitsProvider);

  if (recentWorkoutsAsync.isLoading ||
      recentHabitsAsync.isLoading ||
      habitsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (recentWorkoutsAsync.hasError) {
    return AsyncValue.error(
      recentWorkoutsAsync.error!,
      recentWorkoutsAsync.stackTrace!,
    );
  }
  if (recentHabitsAsync.hasError) {
    return AsyncValue.error(
      recentHabitsAsync.error!,
      recentHabitsAsync.stackTrace!,
    );
  }
  if (habitsAsync.hasError) {
    return AsyncValue.error(
      habitsAsync.error!,
      habitsAsync.stackTrace!,
    );
  }

  final habits = habitsAsync.asData?.value ?? [];
  final habitById = {
    for (final habit in habits) habit.id: habit,
  };

  final workoutItems = (recentWorkoutsAsync.asData?.value ?? []).map((log) {
    return ActivityItem(
      id: log.id,
      title: log.workoutName,
      description: '${log.duration} min workout',
      timestamp: log.startedAt,
      type: ActivityType.workout,
      value: '${log.duration}',
      unit: 'min',
    );
  });

  final habitItems = (recentHabitsAsync.asData?.value ?? []).map((log) {
    final habitName = habitById[log.habitId]?.name ?? 'Habit';
    return ActivityItem(
      id: log.id,
      title: habitName,
      description: 'Habit completed',
      timestamp: log.completedAt,
      type: ActivityType.habit,
    );
  });

  final activities = [...workoutItems, ...habitItems]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return AsyncValue.data(activities.take(5).toList());
});

/// Provider for today's plan
final todayPlanProvider = Provider<AsyncValue<List<TodayPlanItem>>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const AsyncValue.data([]);
  }

  final habitsAsync = ref.watch(userHabitsProvider);
  final todayLogsAsync = ref.watch(todayHabitLogsProvider);
  final goalsAsync = ref.watch(activeGoalsProvider);

  if (habitsAsync.isLoading ||
      todayLogsAsync.isLoading ||
      goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (habitsAsync.hasError) {
    return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
  }
  if (todayLogsAsync.hasError) {
    return AsyncValue.error(todayLogsAsync.error!, todayLogsAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }

  final habits = habitsAsync.asData?.value ?? [];
  final logs = todayLogsAsync.asData?.value ?? [];
  final completedHabitIds = {for (final log in logs) log.habitId};

  final habitItems = habits.map((habit) {
    return TodayPlanItem(
      id: habit.id,
      title: habit.name,
      description: habit.description,
      isCompleted: completedHabitIds.contains(habit.id),
      type: PlanItemType.habit,
    );
  });

  final goals = goalsAsync.asData?.value ?? [];
  final goalItems = goals.take(2).map((goal) {
    return TodayPlanItem(
      id: goal.id,
      title: goal.title,
      description:
          'Progress ${goal.progressPercentage.toStringAsFixed(0)}%',
      isCompleted: goal.isCompleted,
      type: PlanItemType.other,
    );
  });

  final items = [...habitItems, ...goalItems].toList();
  items.sort((a, b) => a.isCompleted == b.isCompleted
      ? a.title.compareTo(b.title)
      : (a.isCompleted ? 1 : -1));
  return AsyncValue.data(items);
});

/// Motivational messages based on coach tone
class MotivationalMessages {
  static String getWelcomeMessage(String? coachTone, String? userName) {
    final name = userName ?? 'there';

    switch (coachTone) {
      case 'friendly':
        return 'Hey $name! Ready to have an amazing day? 🌟';
      case 'strict':
        return 'Welcome back, $name. Time to push your limits.';
      case 'clinical':
        return 'Good day, $name. Let\'s optimize your performance.';
      default:
        return 'Welcome back, $name!';
    }
  }

  static String getSubtitleMessage(String? coachTone) {
    switch (coachTone) {
      case 'friendly':
        return 'You\'re doing great! Let\'s keep the momentum going 💪';
      case 'strict':
        return 'Consistency is key. Execute your plan.';
      case 'clinical':
        return 'Your progress data indicates positive trends.';
      default:
        return 'Ready to crush your goals today?';
    }
  }

  static String getStreakMessage(int streak, String? coachTone) {
    if (streak == 0) {
      switch (coachTone) {
        case 'friendly':
          return 'Start fresh today! Every journey begins with a single step 🌱';
        case 'strict':
          return 'Build your streak. Start now.';
        case 'clinical':
          return 'Initiate new streak cycle for optimal consistency.';
        default:
          return 'Start your streak today!';
      }
    }

    switch (coachTone) {
      case 'friendly':
        return '$streak day streak! You\'re on fire! 🔥';
      case 'strict':
        return '$streak days. Don\'t break it.';
      case 'clinical':
        return 'Current streak: $streak days. Maintain consistency.';
      default:
        return '$streak day streak!';
    }
  }

  static String getNoWorkoutsMessage(String? coachTone) {
    switch (coachTone) {
      case 'friendly':
        return 'No worries! Today\'s a perfect day to start 🌈';
      case 'strict':
        return 'Time to get moving. No excuses.';
      case 'clinical':
        return 'Initiate activity to begin data collection.';
      default:
        return 'Let\'s get started today!';
    }
  }
}
