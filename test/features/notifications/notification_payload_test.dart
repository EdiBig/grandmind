import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/core/constants/route_constants.dart';
import 'package:kinesa/features/notifications/data/services/notification_payload.dart';
import 'package:kinesa/features/notifications/domain/models/notification_preference.dart';

void main() {
  group('NotificationPayload', () {
    test('encodes params and resolves route', () {
      final encoded = payloadForRoute(
        RouteConstants.editHabit,
        params: {'id': 'habit-123'},
      );

      final parsed = NotificationPayload.tryParse(encoded);

      expect(parsed, isNotNull);
      expect(parsed!.route, RouteConstants.editHabit);
      expect(parsed.params, {'id': 'habit-123'});
      expect(parsed.resolvedRoute(), '/habits/habit-123/edit');
    });

    test('creates habit reminder payload with linked entity id', () {
      final preference = NotificationPreference(
        id: 'pref-1',
        userId: 'user-1',
        type: ReminderType.habit,
        enabled: true,
        title: 'Habit Reminder',
        message: 'Complete your habit',
        daysOfWeek: [1],
        hour: 9,
        minute: 0,
        linkedEntityId: 'habit-42',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final encoded = payloadForReminder(preference);
      final parsed = NotificationPayload.tryParse(encoded);

      expect(parsed, isNotNull);
      expect(parsed!.resolvedRoute(), '/habits/habit-42/edit');
    });

    test('falls back to legacy payload mapping', () {
      final parsed = NotificationPayload.tryParse('workout_reminder');

      expect(parsed, isNotNull);
      expect(parsed!.route, RouteConstants.workouts);
      expect(parsed.resolvedRoute(), RouteConstants.workouts);
    });

    test('unknown legacy payload defaults to notifications', () {
      final parsed = NotificationPayload.tryParse('unknown_payload');

      expect(parsed, isNotNull);
      expect(parsed!.route, RouteConstants.notifications);
    });
  });
}
