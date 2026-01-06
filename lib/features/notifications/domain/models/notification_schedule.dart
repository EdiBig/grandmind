import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';
import 'notification_type.dart';

part 'notification_schedule.freezed.dart';
part 'notification_schedule.g.dart';

/// Model for scheduled notifications
@freezed
class NotificationSchedule with _$NotificationSchedule {
  const factory NotificationSchedule({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    @TimestampConverter() required DateTime scheduledTime,
    @Default(false) bool isRecurring,
    String? recurrencePattern, // 'daily', 'weekly', 'monthly'
    List<int>? daysOfWeek, // For weekly recurrence: 1 = Monday, 7 = Sunday
    TimeOfDayData? timeOfDay,
    @Default(true) bool isActive,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _NotificationSchedule;

  const NotificationSchedule._();

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) =>
      _$NotificationScheduleFromJson(json);

  /// Check if this schedule is for today
  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;
  }

  /// Check if this schedule has passed
  bool get hasPassed => DateTime.now().isAfter(scheduledTime);

  /// Get next occurrence for recurring notifications
  DateTime? getNextOccurrence() {
    if (!isRecurring || recurrencePattern == null) return null;

    final now = DateTime.now();
    DateTime next = scheduledTime;

    switch (recurrencePattern) {
      case 'daily':
        while (next.isBefore(now)) {
          next = next.add(const Duration(days: 1));
        }
        break;
      case 'weekly':
        while (next.isBefore(now)) {
          next = next.add(const Duration(days: 7));
        }
        break;
      case 'monthly':
        int monthsToAdd = 1;
        while (DateTime(
          next.year,
          next.month + monthsToAdd,
          next.day,
          next.hour,
          next.minute,
        ).isBefore(now)) {
          monthsToAdd++;
        }
        next = DateTime(
          next.year,
          next.month + monthsToAdd,
          next.day,
          next.hour,
          next.minute,
        );
        break;
    }

    return next;
  }
}

/// Time of day data for serialization
@freezed
class TimeOfDayData with _$TimeOfDayData {
  const factory TimeOfDayData({
    required int hour,
    required int minute,
  }) = _TimeOfDayData;

  const TimeOfDayData._();

  factory TimeOfDayData.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayDataFromJson(json);

  /// Format as string (e.g., "09:30")
  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format as 12-hour time (e.g., "9:30 AM")
  String format12Hour() {
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}
