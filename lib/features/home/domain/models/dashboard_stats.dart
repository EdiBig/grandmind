import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

/// Dashboard statistics model
@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int workoutsThisWeek,
    @Default(0) int workoutsThisMonth,
    @Default(0) int totalWorkouts,
    @Default(0) int habitsCompleted,
    @Default(0) int totalHabits,
    @Default(0.0) double habitCompletionRate,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int stepsToday,
    @Default(0.0) double hoursSlept,
    DateTime? lastWorkoutDate,
    DateTime? lastActivityDate,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

/// Recent activity item
@freezed
class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String id,
    required String title,
    required String description,
    required DateTime timestamp,
    required ActivityType type,
    String? value,
    String? unit,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}

/// Activity type enumeration
enum ActivityType {
  workout,
  habit,
  sleep,
  steps,
  weight,
  mood,
  nutrition,
  other;

  String get displayName {
    switch (this) {
      case ActivityType.workout:
        return 'Workout';
      case ActivityType.habit:
        return 'Habit';
      case ActivityType.sleep:
        return 'Sleep';
      case ActivityType.steps:
        return 'Steps';
      case ActivityType.weight:
        return 'Weight';
      case ActivityType.mood:
        return 'Mood';
      case ActivityType.nutrition:
        return 'Nutrition';
      case ActivityType.other:
        return 'Activity';
    }
  }
}

/// Today's plan item
@freezed
class TodayPlanItem with _$TodayPlanItem {
  const factory TodayPlanItem({
    required String id,
    required String title,
    required String description,
    DateTime? scheduledTime,
    @Default(false) bool isCompleted,
    required PlanItemType type,
  }) = _TodayPlanItem;

  factory TodayPlanItem.fromJson(Map<String, dynamic> json) =>
      _$TodayPlanItemFromJson(json);
}

/// Plan item type enumeration
enum PlanItemType {
  workout,
  habit,
  meditation,
  walk,
  meal,
  other;

  String get displayName {
    switch (this) {
      case PlanItemType.workout:
        return 'Workout';
      case PlanItemType.habit:
        return 'Habit';
      case PlanItemType.meditation:
        return 'Meditation';
      case PlanItemType.walk:
        return 'Walk';
      case PlanItemType.meal:
        return 'Meal';
      case PlanItemType.other:
        return 'Activity';
    }
  }
}
