import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

/// Habit model
@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String userId,
    required String name,
    required String description,
    required HabitFrequency frequency,
    required HabitIcon icon,
    required HabitColor color,
    @TimestampConverter() required DateTime createdAt,
    @Default(true) bool isActive,
    @Default(0) int targetCount, // For quantifiable habits (e.g., 8 glasses of water)
    String? unit, // e.g., "glasses", "minutes", "steps"
    @Default([]) List<int> daysOfWeek, // For weekly habits: 1=Monday, 7=Sunday
    @NullableTimestampConverter() DateTime? lastCompletedAt,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) =>
      _$HabitFromJson(json);
}

/// Habit frequency types
enum HabitFrequency {
  daily,
  weekly,
  custom;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }
}

/// Predefined habit icons
enum HabitIcon {
  water,
  sleep,
  meditation,
  walk,
  read,
  exercise,
  food,
  pill,
  study,
  clean,
  other;

  String get displayName {
    switch (this) {
      case HabitIcon.water:
        return 'Water';
      case HabitIcon.sleep:
        return 'Sleep';
      case HabitIcon.meditation:
        return 'Meditation';
      case HabitIcon.walk:
        return 'Walk';
      case HabitIcon.read:
        return 'Read';
      case HabitIcon.exercise:
        return 'Exercise';
      case HabitIcon.food:
        return 'Food';
      case HabitIcon.pill:
        return 'Medicine';
      case HabitIcon.study:
        return 'Study';
      case HabitIcon.clean:
        return 'Clean';
      case HabitIcon.other:
        return 'Other';
    }
  }
}

/// Predefined habit colors
enum HabitColor {
  blue,
  purple,
  pink,
  red,
  orange,
  yellow,
  green,
  teal;

  String get displayName {
    switch (this) {
      case HabitColor.blue:
        return 'Blue';
      case HabitColor.purple:
        return 'Purple';
      case HabitColor.pink:
        return 'Pink';
      case HabitColor.red:
        return 'Red';
      case HabitColor.orange:
        return 'Orange';
      case HabitColor.yellow:
        return 'Yellow';
      case HabitColor.green:
        return 'Green';
      case HabitColor.teal:
        return 'Teal';
    }
  }
}
