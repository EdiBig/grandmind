import 'dart:convert';

import '../../../../core/constants/route_constants.dart';
import '../../domain/models/notification_preference.dart';

class NotificationPayload {
  final String route;
  final Map<String, String> params;

  const NotificationPayload({
    required this.route,
    this.params = const {},
  });

  String encode() => jsonEncode({
        'route': route,
        if (params.isNotEmpty) 'params': params,
      });

  String resolvedRoute() {
    var resolved = route;
    params.forEach((key, value) {
      resolved = resolved.replaceAll(':$key', value);
    });
    return resolved;
  }

  static NotificationPayload? tryParse(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map && decoded['route'] is String) {
        final rawParams = decoded['params'];
        if (rawParams is Map) {
          final params = <String, String>{};
          rawParams.forEach((key, value) {
            if (key is String && value != null) {
              params[key] = value.toString();
            }
          });
          return NotificationPayload(
            route: decoded['route'] as String,
            params: params,
          );
        }
        return NotificationPayload(route: decoded['route'] as String);
      }
    } catch (_) {
      final legacyRoute = _routeFromLegacyPayload(payload);
      if (legacyRoute != null) {
        return NotificationPayload(route: legacyRoute);
      }
    }

    return null;
  }
}

String payloadForReminder(NotificationPreference preference) {
  final linkedEntityId = preference.linkedEntityId;
  if (linkedEntityId != null && linkedEntityId.trim().isNotEmpty) {
    if (preference.type == ReminderType.habit) {
      return NotificationPayload(
        route: RouteConstants.editHabit,
        params: {'id': linkedEntityId},
      ).encode();
    }
  }

  return NotificationPayload(route: routeForReminder(preference)).encode();
}

String payloadForRoute(String route, {Map<String, String>? params}) {
  return NotificationPayload(route: route, params: params ?? const {}).encode();
}

String routeForReminder(NotificationPreference preference) {
  switch (preference.type) {
    case ReminderType.workout:
      return RouteConstants.workouts;
    case ReminderType.habit:
      return RouteConstants.habits;
    case ReminderType.water:
      return RouteConstants.nutrition;
    case ReminderType.meal:
      return RouteConstants.logMeal;
    case ReminderType.sleep:
      return RouteConstants.habits;
    case ReminderType.meditation:
      return RouteConstants.habits;
    case ReminderType.moodEnergy:
      return RouteConstants.logMoodEnergy;
    case ReminderType.custom:
      return RouteConstants.home;
  }
}

String? _routeFromLegacyPayload(String payload) {
  if (payload.startsWith('habit_checkin')) {
    return RouteConstants.habits;
  }

  switch (payload) {
    case 'workout_reminder':
      return RouteConstants.workouts;
    case 'motivational':
      return RouteConstants.home;
    case 'achievement':
      return RouteConstants.achievements;
    default:
      return RouteConstants.notifications;
  }
}
