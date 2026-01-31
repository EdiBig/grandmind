import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../config/ai_config.dart';
import '../config/remote_config_service.dart';
import '../../features/notifications/data/services/notification_service.dart';
import '../../features/notifications/data/services/fcm_service.dart';
import '../../features/health/data/services/health_background_sync.dart';

/// Service for initializing non-critical components after the first frame.
/// This improves perceived startup performance, especially on lower-end devices.
class DeferredInitService {
  static final _logger = Logger();
  static bool _initialized = false;
  static bool _initializing = false;

  /// Initialize all deferred services after the first frame renders.
  /// Call this from a widget's initState or via addPostFrameCallback.
  static Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;

    final stopwatch = Stopwatch()..start();
    _logger.i('Starting deferred initialization...');

    try {
      // Run initializations in parallel where possible
      await Future.wait([
        _initCrashlytics(),
        _initAppCheck(),
        _initTimezones(),
        _initRemoteConfig(),
      ]);

      // These depend on Remote Config, so run after
      await AIConfig.initialize();

      // Notifications can be initialized in parallel
      await Future.wait([
        _initNotifications(),
        _initFCM(),
      ]);

      // Health sync is lowest priority
      await _initHealthSync();

      _initialized = true;
      stopwatch.stop();
      _logger.i('Deferred initialization complete in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, stack) {
      _logger.e('Deferred initialization error: $e', error: e, stackTrace: stack);
      // Don't rethrow - app should still work with partial initialization
    } finally {
      _initializing = false;
    }
  }

  /// Check if deferred initialization is complete
  static bool get isInitialized => _initialized;

  static Future<void> _initCrashlytics() async {
    if (kIsWeb) return;

    try {
      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _logger.d('Crashlytics initialized');
    } catch (e) {
      _logger.w('Crashlytics initialization failed: $e');
    }
  }

  static Future<void> _initAppCheck() async {
    if (kIsWeb) return;

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      );
      _logger.d('AppCheck initialized');
    } catch (e) {
      _logger.w('AppCheck initialization failed: $e');
    }
  }

  static Future<void> _initTimezones() async {
    try {
      tz.initializeTimeZones();
      _logger.d('Timezones initialized');
    } catch (e) {
      _logger.w('Timezone initialization failed: $e');
    }
  }

  static Future<void> _initRemoteConfig() async {
    try {
      await RemoteConfigService.initialize();
      _logger.d('Remote Config initialized');
    } catch (e) {
      _logger.w('Remote Config initialization failed: $e');
    }
  }

  static Future<void> _initNotifications() async {
    try {
      await NotificationService().initialize();
      _logger.d('Notifications initialized');
    } catch (e) {
      _logger.w('Notifications initialization failed: $e');
    }
  }

  static Future<void> _initFCM() async {
    if (kIsWeb) return;

    try {
      await FCMService().initialize();
      _logger.d('FCM initialized');
    } catch (e) {
      _logger.w('FCM initialization failed: $e');
    }
  }

  static Future<void> _initHealthSync() async {
    try {
      await registerHealthBackgroundSync();
      _logger.d('Health background sync initialized');
    } catch (e) {
      _logger.w('Health sync initialization failed: $e');
    }
  }
}
