import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_navigation.dart';
import 'notification_payload.dart';

/// Service for handling Firebase Cloud Messaging (FCM) push notifications
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and set up message handlers
  Future<void> initialize() async {
    // Request notification permissions (iOS and Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('FCM authorization status: ${settings.authorizationStatus}');
    }

    // Handle notification that opened the app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Handle foreground messages (optional: show local notification)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Get FCM token for debugging/server registration
    if (kDebugMode) {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
    }
  }

  /// Handle notification message tap
  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('FCM message opened: ${message.data}');
    }

    // Check for route in message data
    final route = message.data['route'] as String?;
    if (route != null) {
      final params = <String, String>{};
      message.data.forEach((key, value) {
        if (key != 'route' && value is String) {
          params[key] = value;
        }
      });

      final payload = NotificationPayload(route: route, params: params);
      NotificationNavigation.handlePayload(payload.encode());
    }
  }

  /// Handle messages received while app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('FCM foreground message: ${message.notification?.title}');
    }

    // Foreground messages are typically shown as local notifications
    // or in-app banners. The local notification service can be used here
    // if needed.
  }

  /// Get the current FCM token
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to a topic for targeted messaging
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
