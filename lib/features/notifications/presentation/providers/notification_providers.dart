import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/reminder_scheduler.dart';
import '../../data/services/notification_payload.dart';
import '../../domain/models/notification_preference.dart';
import '../../../../core/constants/route_constants.dart';

// ==================== SERVICE PROVIDERS ====================

/// Provider for NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Provider for ReminderScheduler
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return ReminderScheduler(notificationService);
});

// ==================== USER PROVIDERS ====================

/// Provider for current user ID
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

// ==================== PREFERENCE PROVIDERS ====================

/// Provider for all notification preferences
final notificationPreferencesProvider =
    FutureProvider<List<NotificationPreference>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getAllPreferences(userId);
});

/// Provider for enabled preferences
final enabledPreferencesProvider =
    FutureProvider<List<NotificationPreference>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getEnabledPreferences(userId);
});

/// Provider for preferences by type
final preferencesByTypeProvider = FutureProvider.family<
    List<NotificationPreference>, ReminderType>((ref, type) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getPreferencesByType(userId, type);
});

/// Stream provider for watching preferences
final watchNotificationPreferencesProvider =
    StreamProvider<List<NotificationPreference>>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchPreferences(userId);
});

// ==================== HISTORY PROVIDERS ====================

/// Provider for notification history
final notificationHistoryProvider =
    FutureProvider<List<NotificationHistory>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getHistory(userId, limit: 50);
});

/// Provider for unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return 0;

  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getUnreadCount(userId);
});

/// Stream provider for watching history
final watchNotificationHistoryProvider =
    StreamProvider<List<NotificationHistory>>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchHistory(userId, limit: 50);
});

// ==================== NOTIFICATION OPERATIONS ====================

/// Provider for notification operations
final notificationOperationsProvider = Provider((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  final repository = ref.watch(notificationRepositoryProvider);
  final scheduler = ref.watch(reminderSchedulerProvider);

  return NotificationOperations(userId, repository, scheduler, ref);
});

/// Class for notification operations
class NotificationOperations {
  final String? userId;
  final NotificationRepository repository;
  final ReminderScheduler scheduler;
  final Ref ref;

  NotificationOperations(this.userId, this.repository, this.scheduler, this.ref);

  /// Create a new notification preference
  Future<NotificationPreference?> createPreference(
    NotificationPreference preference,
  ) async {
    if (userId == null) return null;

    try {
      final created = await repository.createPreference(userId!, preference);

      // Schedule the reminder if enabled
      if (created.enabled) {
        await scheduler.scheduleReminder(created);
      }

      // Refresh preferences
      ref.invalidate(notificationPreferencesProvider);
      ref.invalidate(watchNotificationPreferencesProvider);

      return created;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing preference
  Future<bool> updatePreference(NotificationPreference preference) async {
    if (userId == null) return false;

    try {
      await repository.updatePreference(userId!, preference);

      // Reschedule the reminder
      await scheduler.rescheduleReminder(preference);

      // Refresh preferences
      ref.invalidate(notificationPreferencesProvider);
      ref.invalidate(watchNotificationPreferencesProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle preference enabled status
  Future<bool> togglePreference(String preferenceId, bool enabled) async {
    if (userId == null) return false;

    try {
      await repository.togglePreference(userId!, preferenceId, enabled);

      // Get the preference to reschedule
      final preference = await repository.getPreference(userId!, preferenceId);
      if (preference != null) {
        await scheduler.rescheduleReminder(
          preference.copyWith(enabled: enabled),
        );
      }

      // Refresh preferences
      ref.invalidate(notificationPreferencesProvider);
      ref.invalidate(watchNotificationPreferencesProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a preference
  Future<bool> deletePreference(String preferenceId) async {
    if (userId == null) return false;

    try {
      // Get the preference to cancel its reminders
      final preference = await repository.getPreference(userId!, preferenceId);
      if (preference != null) {
        await scheduler.cancelReminder(preference);
      }

      await repository.deletePreference(userId!, preferenceId);

      // Refresh preferences
      ref.invalidate(notificationPreferencesProvider);
      ref.invalidate(watchNotificationPreferencesProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reschedule all reminders
  Future<void> rescheduleAllReminders() async {
    if (userId == null) return;

    try {
      final preferences = await repository.getAllPreferences(userId!);
      await scheduler.scheduleAllReminders(preferences);
    } catch (e) {
      // Handle error
    }
  }

  /// Create default workout reminder
  Future<NotificationPreference?> createDefaultWorkoutReminder() async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultWorkoutReminder(userId!);
    return await createPreference(defaultReminder);
  }

  /// Create default habit reminder
  Future<NotificationPreference?> createDefaultHabitReminder({
    required String habitName,
    String? habitId,
  }) async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultHabitReminder(
      userId!,
      habitName: habitName,
      habitId: habitId,
    );
    return await createPreference(defaultReminder);
  }

  /// Create default water reminder
  Future<NotificationPreference?> createDefaultWaterReminder() async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultWaterReminder(userId!);
    return await createPreference(defaultReminder);
  }

  /// Create default meal reminder
  Future<NotificationPreference?> createDefaultMealReminder({
    required String mealType,
  }) async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultMealReminder(
      userId!,
      mealType: mealType,
    );
    return await createPreference(defaultReminder);
  }

  /// Create default sleep reminder
  Future<NotificationPreference?> createDefaultSleepReminder() async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultSleepReminder(userId!);
    return await createPreference(defaultReminder);
  }

  /// Create default meditation reminder
  Future<NotificationPreference?> createDefaultMeditationReminder() async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultMeditationReminder(userId!);
    return await createPreference(defaultReminder);
  }

  /// Create default mood & energy reminder
  Future<NotificationPreference?> createDefaultMoodEnergyReminder() async {
    if (userId == null) return null;

    final defaultReminder = scheduler.createDefaultMoodEnergyReminder(userId!);
    return await createPreference(defaultReminder);
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    await scheduler.sendInstantReminder(
      title: '🔔 Test Notification',
      message: 'This is a test notification from Kinesa!',
      payload: payloadForRoute(RouteConstants.notifications),
    );
  }

  /// Log notification
  Future<void> logNotification(NotificationHistory history) async {
    if (userId == null) return;
    await repository.logNotification(userId!, history);
    ref.invalidate(notificationHistoryProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  /// Mark notification as read
  Future<void> markAsRead(String historyId) async {
    if (userId == null) return;
    await repository.markAsRead(userId!, historyId);
    ref.invalidate(unreadNotificationCountProvider);
  }

  /// Mark notification as actioned
  Future<void> markAsActioned(String historyId, String action) async {
    if (userId == null) return;
    await repository.markAsActioned(userId!, historyId, action);
  }

  /// Clear old history
  Future<void> clearOldHistory({int daysToKeep = 30}) async {
    if (userId == null) return;
    await repository.clearOldHistory(userId!, daysToKeep: daysToKeep);
    ref.invalidate(notificationHistoryProvider);
  }
}
