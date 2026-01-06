import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../user/data/models/user_model.dart';
import '../../domain/models/dashboard_stats.dart';

/// Provider for current user data
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
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
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(const DashboardStats());
  }

  // For now, return mock data. We'll implement real data fetching later
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return const DashboardStats(
      workoutsThisWeek: 3,
      workoutsThisMonth: 12,
      totalWorkouts: 45,
      habitsCompleted: 17,
      totalHabits: 20,
      habitCompletionRate: 85.0,
      currentStreak: 7,
      longestStreak: 21,
      stepsToday: 8500,
      hoursSlept: 7.5,
    );
  }).take(1);
});

/// Provider for recent activities
final recentActivitiesProvider = StreamProvider<List<ActivityItem>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  // For now, return mock data. We'll implement real data fetching later
  final now = DateTime.now();
  return Stream.value([
    ActivityItem(
      id: '1',
      title: 'Completed HIIT Workout',
      description: '30 minutes high intensity',
      timestamp: now.subtract(const Duration(hours: 24)),
      type: ActivityType.workout,
      value: '30',
      unit: 'min',
    ),
    ActivityItem(
      id: '2',
      title: 'Logged 8 hours of sleep',
      description: 'Great sleep quality',
      timestamp: now.subtract(const Duration(hours: 36)),
      type: ActivityType.sleep,
      value: '8',
      unit: 'hours',
    ),
    ActivityItem(
      id: '3',
      title: '10,000 steps milestone',
      description: 'Daily goal achieved',
      timestamp: now.subtract(const Duration(days: 2)),
      type: ActivityType.steps,
      value: '10000',
      unit: 'steps',
    ),
  ]);
});

/// Provider for today's plan
final todayPlanProvider = StreamProvider<List<TodayPlanItem>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  // For now, return mock data. We'll implement real data fetching later
  final now = DateTime.now();
  return Stream.value([
    TodayPlanItem(
      id: '1',
      title: 'Morning Workout',
      description: 'Full Body Strength',
      scheduledTime: DateTime(now.year, now.month, now.day, 7, 0),
      isCompleted: false,
      type: PlanItemType.workout,
    ),
    TodayPlanItem(
      id: '2',
      title: 'Meditation',
      description: '15 minutes mindfulness',
      scheduledTime: DateTime(now.year, now.month, now.day, 12, 0),
      isCompleted: true,
      type: PlanItemType.meditation,
    ),
    TodayPlanItem(
      id: '3',
      title: 'Evening Walk',
      description: '30 minutes outdoor',
      scheduledTime: DateTime(now.year, now.month, now.day, 18, 0),
      isCompleted: false,
      type: PlanItemType.walk,
    ),
  ]);
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
