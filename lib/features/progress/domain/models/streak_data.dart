import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'streak_data.freezed.dart';
part 'streak_data.g.dart';

/// Represents a user's streak data with adaptive forgiveness
@freezed
class StreakData with _$StreakData {
  const StreakData._();

  const factory StreakData({
    required int currentStreak,
    required int longestStreak,
    required int totalActiveDays,
    @NullableTimestampConverter() DateTime? lastActiveDate,
    @Default([]) List<DateTime> activeDatesThisMonth,
    @Default(1) int graceDays,
  }) = _StreakData;

  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);

  factory StreakData.empty() => const StreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalActiveDays: 0,
        lastActiveDate: null,
        activeDatesThisMonth: [],
      );
}

/// Represents activity data for a single day
@freezed
class ActivityDay with _$ActivityDay {
  const ActivityDay._();

  const factory ActivityDay({
    @TimestampConverter() required DateTime date,
    required int workoutCount,
    required int habitsCompleted,
    required int habitsTotal,
    required bool weightLogged,
    required bool measurementsLogged,
    @Default(0) int activityScore,
  }) = _ActivityDay;

  factory ActivityDay.fromJson(Map<String, dynamic> json) =>
      _$ActivityDayFromJson(json);

  factory ActivityDay.empty(DateTime date) => ActivityDay(
        date: date,
        workoutCount: 0,
        habitsCompleted: 0,
        habitsTotal: 0,
        weightLogged: false,
        measurementsLogged: false,
        activityScore: 0,
      );

  /// Whether this day has any activity
  bool get hasActivity => activityScore > 0;

  /// Whether all habits were completed
  bool get allHabitsCompleted =>
      habitsTotal > 0 && habitsCompleted >= habitsTotal;

  /// Returns the activity intensity level (0-4) for heatmap coloring
  int get intensityLevel {
    if (activityScore == 0) return 0;
    if (activityScore < 25) return 1;
    if (activityScore < 50) return 2;
    if (activityScore < 75) return 3;
    return 4;
  }
}
