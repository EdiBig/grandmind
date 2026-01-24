import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_navigator.dart';
import 'notification_payload.dart';

class NotificationNavigation {
  static String? _pendingRoute;

  static void handlePayload(String? payload) {
    final resolved = NotificationPayload.tryParse(payload);
    if (resolved == null) {
      return;
    }

    _goOrQueue(resolved.resolvedRoute());
  }

  static void handlePendingNavigation() {
    if (_pendingRoute == null) {
      return;
    }

    _goOrQueue(_pendingRoute!);
  }

  static void _goOrQueue(String route) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _pendingRoute = route;
      if (kDebugMode) {
        debugPrint('Notification navigation queued: $route');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('Notification navigation: $route');
    }

    GoRouter.of(context).go(route);
    _pendingRoute = null;
  }
}
