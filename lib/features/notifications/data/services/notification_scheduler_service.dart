import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification_schedule.dart';
import '../../domain/models/notification_type.dart';

/// Service for scheduling and managing local notifications
class NotificationSchedulerService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String channelId = 'kinesa_reminders';
  static const String channelName = 'Kinesa Reminders';
  static const String channelDescription = 'Reminders for workouts, habits, and progress';

  NotificationSchedulerService(this._notificationsPlugin);

  /// Initialize the notification service
  Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Request permissions for iOS
    await _requestIOSPermissions();
  }

  /// Request iOS notification permissions
  Future<void> _requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    // TODO: Navigate to appropriate screen based on payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ========== WORKOUT REMINDERS ==========

  /// Schedule a workout reminder notification
  Future<void> scheduleWorkoutReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule recurring workout reminders
  Future<void> scheduleRecurringWorkoutReminders({
    required List<int> daysOfWeek, // 1 = Monday, 7 = Sunday
    required TimeOfDay time,
    String title = 'Time to workout!',
    String body = 'Your training session is ready. Let\'s get moving!',
  }) async {
    // Cancel existing workout reminders
    await cancelNotificationsByType(NotificationType.workoutReminder);

    // Schedule for each day of the week
    for (final day in daysOfWeek) {
      final id = 1000 + day; // Base ID for workout reminders
      final now = DateTime.now();

      // Calculate next occurrence of this weekday
      DateTime nextOccurrence = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Adjust to correct day of week
      while (nextOccurrence.weekday != day) {
        nextOccurrence = nextOccurrence.add(const Duration(days: 1));
      }

      // If the time has passed today, schedule for next week
      if (nextOccurrence.isBefore(now)) {
        nextOccurrence = nextOccurrence.add(const Duration(days: 7));
      }

      await scheduleWorkoutReminder(
        id: id,
        title: title,
        body: body,
        scheduledTime: nextOccurrence,
        payload: 'workout_reminder',
      );

      // Save to Firestore
      await _saveNotificationSchedule(
        NotificationSchedule(
          id: id.toString(),
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          type: NotificationType.workoutReminder,
          title: title,
          body: body,
          scheduledTime: nextOccurrence,
          isRecurring: true,
          recurrencePattern: 'weekly',
          daysOfWeek: [day],
          timeOfDay: TimeOfDayData(hour: time.hour, minute: time.minute),
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // ========== HABIT CHECK-IN REMINDERS ==========

  /// Schedule habit check-in notification
  Future<void> scheduleHabitCheckIn({
    required int id,
    required String habitName,
    required DateTime scheduledTime,
    String? customMessage,
  }) async {
    final title = 'Habit Check-in';
    final body = customMessage ?? 'Time to complete "$habitName"!';

    await scheduleWorkoutReminder(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: 'habit_checkin_$id',
    );

    // Save to Firestore
    await _saveNotificationSchedule(
      NotificationSchedule(
        id: id.toString(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        type: NotificationType.habitCheckIn,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        isRecurring: true,
        recurrencePattern: 'daily',
        timeOfDay: TimeOfDayData(
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
        ),
        isActive: true,
        createdAt: DateTime.now(),
        metadata: {'habitName': habitName},
      ),
    );
  }

  /// Schedule daily habit check-ins
  Future<void> scheduleDailyHabitCheckIns({
    required TimeOfDay time,
    String title = 'Daily Habits',
    String body = 'Check in on your habits for today!',
  }) async {
    final id = 2000; // Base ID for habit check-ins
    final now = DateTime.now();

    DateTime nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed, schedule for tomorrow
    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 1));
    }

    await scheduleHabitCheckIn(
      id: id,
      habitName: 'Daily Check-in',
      scheduledTime: nextOccurrence,
      customMessage: body,
    );
  }

  // ========== MOTIVATIONAL MESSAGES ==========

  /// Schedule a motivational message notification
  Future<void> scheduleMotivationalMessage({
    required int id,
    required String message,
    required DateTime scheduledTime,
  }) async {
    await scheduleWorkoutReminder(
      id: id,
      title: 'You\'ve got this!',
      body: message,
      scheduledTime: scheduledTime,
      payload: 'motivational',
    );

    // Save to Firestore
    await _saveNotificationSchedule(
      NotificationSchedule(
        id: id.toString(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        type: NotificationType.motivational,
        title: 'You\'ve got this!',
        body: message,
        scheduledTime: scheduledTime,
        isRecurring: false,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Schedule random motivational messages throughout the day
  Future<void> scheduleRandomMotivationalMessages({
    required List<String> messages,
    int messagesPerDay = 2,
  }) async {
    // Cancel existing motivational notifications
    await cancelNotificationsByType(NotificationType.motivational);

    final now = DateTime.now();

    for (int i = 0; i < messagesPerDay; i++) {
      final id = 3000 + i;
      final message = messages[i % messages.length];

      // Schedule at random times (morning and afternoon)
      final hour = i == 0 ? 9 : 15; // 9 AM and 3 PM
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        0,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await scheduleMotivationalMessage(
        id: id,
        message: message,
        scheduledTime: scheduledTime,
      );
    }
  }

  // ========== ACHIEVEMENT CELEBRATIONS ==========

  /// Show achievement celebration notification immediately
  Future<void> showAchievementNotification({
    required String achievementTitle,
    required String description,
  }) async {
    const id = 4000; // Base ID for achievements

    await _notificationsPlugin.show(
      id,
      '🎉 Achievement Unlocked!',
      '$achievementTitle - $description',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'achievement',
    );

    // Log to Firestore
    await _logNotificationSent(
      type: NotificationType.achievement,
      title: '🎉 Achievement Unlocked!',
      body: '$achievementTitle - $description',
    );
  }

  // ========== UTILITY METHODS ==========

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);

    // Delete from Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestore
          .collection('notification_schedules')
          .doc(id.toString())
          .delete();
    }
  }

  /// Cancel all notifications of a specific type
  Future<void> cancelNotificationsByType(NotificationType type) async {
    int startId;
    int endId;

    switch (type) {
      case NotificationType.workoutReminder:
        startId = 1000;
        endId = 1999;
        break;
      case NotificationType.habitCheckIn:
        startId = 2000;
        endId = 2999;
        break;
      case NotificationType.motivational:
        startId = 3000;
        endId = 3999;
        break;
      case NotificationType.achievement:
        startId = 4000;
        endId = 4999;
        break;
      default:
        return;
    }

    for (int id = startId; id <= endId; id++) {
      await _notificationsPlugin.cancel(id);
    }

    // Delete from Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _firestore
          .collection('notification_schedules')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();

    // Delete all from Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _firestore
          .collection('notification_schedules')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  /// Get list of all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Save notification schedule to Firestore
  Future<void> _saveNotificationSchedule(NotificationSchedule schedule) async {
    await _firestore
        .collection('notification_schedules')
        .doc(schedule.id)
        .set(schedule.toJson());
  }

  /// Log notification sent
  Future<void> _logNotificationSent({
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('notification_logs').add({
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Helper class for TimeOfDay serialization
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'minute': minute,
      };

  factory TimeOfDay.fromJson(Map<String, dynamic> json) => TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      );
}
