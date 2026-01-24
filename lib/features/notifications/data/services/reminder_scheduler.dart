import 'package:flutter/foundation.dart';
import '../../domain/models/notification_preference.dart';
import 'notification_service.dart';
import 'notification_payload.dart';

/// Service for scheduling and managing reminders
class ReminderScheduler {
  final NotificationService _notificationService;

  ReminderScheduler(this._notificationService);

  // Notification ID ranges for different reminder types
  static const int workoutBase = 1000;
  static const int habitBase = 2000;
  static const int waterBase = 3000;
  static const int mealBase = 4000;
  static const int sleepBase = 5000;
  static const int meditationBase = 6000;
  static const int moodEnergyBase = 7000;
  static const int customBase = 8000;

  /// Get base ID for reminder type
  int _getBaseId(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        return workoutBase;
      case ReminderType.habit:
        return habitBase;
      case ReminderType.water:
        return waterBase;
      case ReminderType.meal:
        return mealBase;
      case ReminderType.sleep:
        return sleepBase;
      case ReminderType.meditation:
        return meditationBase;
      case ReminderType.moodEnergy:
        return moodEnergyBase;
      case ReminderType.custom:
        return customBase;
    }
  }

  /// Generate unique notification ID from preference
  int _generateNotificationId(NotificationPreference preference) {
    final baseId = _getBaseId(preference.type);
    // Use hash of preference ID to get unique number
    final hash = preference.id.hashCode.abs() % 900; // Ensure it's within range
    return baseId + hash;
  }

  /// Schedule a single reminder
  Future<void> scheduleReminder(NotificationPreference preference) async {
    if (!preference.enabled) {
      if (kDebugMode) {
        print('Skipping disabled reminder: ${preference.id}');
      }
      return;
    }

    try {
      final notificationId = _generateNotificationId(preference);

      // Schedule for each day of the week
      for (final dayOfWeek in preference.daysOfWeek) {
        await _scheduleDailyReminder(
          id: notificationId + dayOfWeek, // Unique ID per day
          preference: preference,
          dayOfWeek: dayOfWeek,
        );
      }

      if (kDebugMode) {
        print('Scheduled reminder: ${preference.title} at ${preference.timeString}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling reminder: $e');
      }
      rethrow;
    }
  }

  /// Schedule daily reminder for specific day
  Future<void> _scheduleDailyReminder({
    required int id,
    required NotificationPreference preference,
    required int dayOfWeek,
  }) async {
    // Calculate next occurrence of this day at the specified time
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday;

    int daysUntilTarget;
    if (dayOfWeek >= currentDayOfWeek) {
      daysUntilTarget = dayOfWeek - currentDayOfWeek;
    } else {
      daysUntilTarget = 7 - currentDayOfWeek + dayOfWeek;
    }

    final targetDate = now.add(Duration(days: daysUntilTarget));
    final scheduledTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      preference.hour,
      preference.minute,
    );

    // If the time has passed today and it's the same day, schedule for next week
    if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      final nextWeekTime = scheduledTime.add(const Duration(days: 7));
      await _notificationService.scheduleNotification(
        id: id,
        title: preference.title,
        body: preference.message,
        scheduledTime: nextWeekTime,
        payload: payloadForReminder(preference),
      );
    } else {
      await _notificationService.scheduleNotification(
        id: id,
        title: preference.title,
        body: preference.message,
        scheduledTime: scheduledTime,
        payload: payloadForReminder(preference),
      );
    }
  }

  /// Schedule all reminders for a user
  Future<void> scheduleAllReminders(
    List<NotificationPreference> preferences,
  ) async {
    try {
      // Cancel all existing notifications first
      await _notificationService.cancelAllNotifications();

      // Schedule each enabled preference
      for (final preference in preferences) {
        if (preference.enabled) {
          await scheduleReminder(preference);
        }
      }

      if (kDebugMode) {
        final enabledCount = preferences.where((p) => p.enabled).length;
        print('Scheduled $enabledCount reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling all reminders: $e');
      }
      rethrow;
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(NotificationPreference preference) async {
    try {
      final baseNotificationId = _generateNotificationId(preference);

      // Cancel for all days of the week
      for (int day = 1; day <= 7; day++) {
        await _notificationService.cancelNotification(baseNotificationId + day);
      }

      if (kDebugMode) {
        print('Cancelled reminder: ${preference.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling reminder: $e');
      }
    }
  }

  /// Reschedule a reminder (useful after updating)
  Future<void> rescheduleReminder(NotificationPreference preference) async {
    await cancelReminder(preference);
    if (preference.enabled) {
      await scheduleReminder(preference);
    }
  }

  /// Send an instant reminder (for testing or immediate notifications)
  Future<void> sendInstantReminder({
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      await _notificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: message,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending instant reminder: $e');
      }
    }
  }

  /// Create default workout reminder
  NotificationPreference createDefaultWorkoutReminder(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.workout,
      enabled: false,
      title: '💪 Time to Work Out!',
      message: 'Your scheduled workout is starting soon. Let\'s get moving!',
      daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
      hour: 18, // 6 PM
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default habit reminder
  NotificationPreference createDefaultHabitReminder(
    String userId, {
    required String habitName,
    String? habitId,
  }) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.habit,
      enabled: false,
      title: '✅ Habit Reminder',
      message: 'Don\'t forget to complete: $habitName',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: 20, // 8 PM
      minute: 0,
      linkedEntityId: habitId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default water reminder
  NotificationPreference createDefaultWaterReminder(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.water,
      enabled: false,
      title: '💧 Hydration Reminder',
      message: 'Time to drink some water! Stay hydrated throughout the day.',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: 10, // 10 AM
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default meal reminder
  NotificationPreference createDefaultMealReminder(
    String userId, {
    required String mealType, // 'breakfast', 'lunch', 'dinner'
  }) {
    final mealTimes = {
      'breakfast': (8, 0),
      'lunch': (12, 30),
      'dinner': (18, 30),
    };

    final time = mealTimes[mealType.toLowerCase()] ?? (12, 0);

    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.meal,
      enabled: false,
      title: '🍽️ ${mealType.substring(0, 1).toUpperCase()}${mealType.substring(1)} Time',
      message: 'Time for a healthy $mealType! Fuel your body right.',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: time.$1,
      minute: time.$2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default sleep reminder
  NotificationPreference createDefaultSleepReminder(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.sleep,
      enabled: false,
      title: '😴 Wind Down Time',
      message: 'Start preparing for bed. Aim for 7-9 hours of quality sleep.',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: 22, // 10 PM
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default meditation reminder
  NotificationPreference createDefaultMeditationReminder(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.meditation,
      enabled: false,
      title: '🧘 Meditation Time',
      message: 'Take a few minutes to center yourself and breathe.',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: 7, // 7 AM
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default mood & energy reminder
  NotificationPreference createDefaultMoodEnergyReminder(String userId) {
    return NotificationPreference(
      id: '',
      userId: userId,
      type: ReminderType.moodEnergy,
      enabled: false,
      title: '😊 How Are You Feeling?',
      message: 'Take a moment to log your mood and energy levels.',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      hour: 20, // 8 PM
      minute: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
