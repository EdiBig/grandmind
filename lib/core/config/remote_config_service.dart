import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logger/logger.dart';

/// Service for managing Firebase Remote Config
class RemoteConfigService {
  static final _logger = Logger();
  static FirebaseRemoteConfig? _remoteConfig;
  static bool _initialized = false;

  // Default values (fallbacks if Remote Config fetch fails)
  static const Map<String, dynamic> _defaults = {
    'ai_proxy_url': 'https://claudeproxy-fy7x3gndyq-uc.a.run.app',
    'ai_default_model': 'claude-3-haiku-20240307',
    'ai_fast_model': 'claude-3-haiku-20240307',
    'ai_free_monthly_limit': 20,
    'ai_max_tokens_per_request': 4096,
    'ai_streaming_enabled': false,
    'ai_coach_enabled': true,
    'mood_insights_enabled': true,
    'nutrition_assistant_enabled': true,
    'recovery_advisor_enabled': true,
    'maintenance_mode': false,
    'minimum_app_version': '1.0.0',
  };

  /// Initialize Remote Config
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig!.setDefaults(_defaults.map(
        (key, value) => MapEntry(key, value.toString()),
      ));

      // Fetch and activate
      await _remoteConfig!.fetchAndActivate();

      _initialized = true;
      _logger.i('Remote Config initialized successfully');
    } catch (e) {
      _logger.w('Remote Config initialization failed, using defaults: $e');
      _initialized = true; // Mark as initialized to use defaults
    }
  }

  /// Get string value
  static String getString(String key) {
    if (_remoteConfig == null) {
      return _defaults[key]?.toString() ?? '';
    }
    return _remoteConfig!.getString(key);
  }

  /// Get int value
  static int getInt(String key) {
    if (_remoteConfig == null) {
      final defaultValue = _defaults[key];
      return defaultValue is int ? defaultValue : 0;
    }
    return _remoteConfig!.getInt(key);
  }

  /// Get bool value
  static bool getBool(String key) {
    if (_remoteConfig == null) {
      final defaultValue = _defaults[key];
      return defaultValue is bool ? defaultValue : false;
    }
    return _remoteConfig!.getBool(key);
  }

  /// Get double value
  static double getDouble(String key) {
    if (_remoteConfig == null) {
      final defaultValue = _defaults[key];
      return defaultValue is double ? defaultValue : 0.0;
    }
    return _remoteConfig!.getDouble(key);
  }

  /// Force refresh config (bypasses minimum fetch interval)
  static Future<bool> forceRefresh() async {
    if (_remoteConfig == null) return false;

    try {
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      final updated = await _remoteConfig!.fetchAndActivate();
      _logger.i('Remote Config force refreshed: updated=$updated');
      return updated;
    } catch (e) {
      _logger.e('Remote Config force refresh failed: $e');
      return false;
    }
  }
}
