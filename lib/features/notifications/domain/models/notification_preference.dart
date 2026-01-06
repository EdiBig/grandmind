import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'notification_preference.freezed.dart';
part 'notification_preference.g.dart';

/// Types of reminders in the app
enum ReminderType {
  workout,
  habit,
  water,
  meal,
  sleep,
  meditation,
  custom,
}

/// Model for user notification preferences
@freezed
class NotificationPreference with _$NotificationPreference {
  const factory NotificationPreference({
    required String id,
    required String userId,
    required ReminderType type,
    required bool enabled,
    required String title,
    required String message,
    required List<int> daysOfWeek, // 1=Monday, 7=Sunday
    required int hour, // 0-23
    required int minute, // 0-59
    String? linkedEntityId, // habitId, goalId, etc.
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _NotificationPreference;

  const NotificationPreference._();

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceFromJson(json);

  /// Get notification time as formatted string
  String get timeString {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// Get days of week as readable string
  String get daysString {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.isEmpty) return 'Never';

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return daysOfWeek.map((day) => dayNames[day - 1]).join(', ');
  }

  /// Check if reminder should trigger today
  bool shouldTriggerToday() {
    final today = DateTime.now().weekday; // 1=Monday, 7=Sunday
    return enabled && daysOfWeek.contains(today);
  }

  /// Get next scheduled date/time
  DateTime? getNextScheduledTime() {
    if (!enabled || daysOfWeek.isEmpty) return null;

    final now = DateTime.now();
    final todayScheduled = DateTime(now.year, now.month, now.day, hour, minute);

    // Check if today's scheduled time has passed
    if (shouldTriggerToday() && todayScheduled.isAfter(now)) {
      return todayScheduled;
    }

    // Find next day in schedule
    for (int i = 1; i <= 7; i++) {
      final futureDay = now.add(Duration(days: i));
      if (daysOfWeek.contains(futureDay.weekday)) {
        return DateTime(
          futureDay.year,
          futureDay.month,
          futureDay.day,
          hour,
          minute,
        );
      }
    }

    return null;
  }
}

/// Model for notification history (tracking sent notifications)
@freezed
class NotificationHistory with _$NotificationHistory {
  const factory NotificationHistory({
    required String id,
    required String userId,
    required String preferenceId,
    required ReminderType type,
    required String title,
    required String message,
    @TimestampConverter() required DateTime sentAt,
    @TimestampConverter() DateTime? readAt,
    @TimestampConverter() DateTime? actionedAt,
    String? action, // 'opened', 'dismissed', 'completed'
  }) = _NotificationHistory;

  const NotificationHistory._();

  factory NotificationHistory.fromJson(Map<String, dynamic> json) =>
      _$NotificationHistoryFromJson(json);

  /// Check if notification was read
  bool get isRead => readAt != null;

  /// Check if notification was actioned
  bool get isActioned => actionedAt != null;
}
