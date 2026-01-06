import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logger/logger.dart';

/// Configuration class for AI features
/// Handles secure API key storage and retrieval
class AIConfig {
  static const String _apiKeyKey = 'CLAUDE_API_KEY';
  static const String _remoteConfigKey = 'claude_api_key';

  static final _storage = const FlutterSecureStorage();
  static final _logger = Logger();

  // AI Feature Limits
  static const int freeMonthlyMessageLimit = 20;
  static const int maxTokensPerRequest = 4096;
  static const int maxRequestsPerMinute = 20;
  static const int cacheExpiryHours = 24;

  // Claude API Configuration
  static const String apiBaseUrl = 'https://api.anthropic.com/v1';
  static const String apiVersion = '2023-06-01';
  static const String defaultModel = 'claude-3-haiku-20240307';  // Working model for your API key
  static const String fastModel = 'claude-3-haiku-20240307';

  // Response Configuration
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1024;
  static const int streamingMaxTokens = 2048;

  /// Initialize AI configuration
  /// Call this during app startup
  static Future<void> initialize() async {
    try {
      _logger.i('Initializing AI configuration...');

      // Check if API key already exists in secure storage
      final existingKey = await _storage.read(key: _apiKeyKey);

      if (existingKey != null && existingKey.isNotEmpty) {
        _logger.i('API key found in secure storage');
        return;
      }

      // Try to fetch from Firebase Remote Config
      _logger.i('Fetching API key from Remote Config...');
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await remoteConfig.setDefaults({
        _remoteConfigKey: '',
      });

      await remoteConfig.fetchAndActivate();
      final apiKey = remoteConfig.getString(_remoteConfigKey);

      if (apiKey.isNotEmpty) {
        // Store securely
        await _storage.write(key: _apiKeyKey, value: apiKey);
        _logger.i('API key stored securely');
      } else {
        _logger.w('No API key found in Remote Config');
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing AI config', error: e, stackTrace: stackTrace);
      // Don't throw - allow app to continue without AI features
    }
  }

  /// Get the Claude API key
  /// Returns null if not configured
  static Future<String?> getApiKey() async {
    try {
      final key = await _storage.read(key: _apiKeyKey);

      if (key == null || key.isEmpty) {
        _logger.w('API key not found');
        return null;
      }

      return key;
    } catch (e) {
      _logger.e('Error reading API key', error: e);
      return null;
    }
  }

  /// Manually set API key (for testing or first-time setup)
  static Future<void> setApiKey(String apiKey) async {
    try {
      if (apiKey.isEmpty) {
        throw ArgumentError('API key cannot be empty');
      }

      if (!apiKey.startsWith('sk-ant-api')) {
        _logger.w('API key format looks unusual');
      }

      await _storage.write(key: _apiKeyKey, value: apiKey);
      _logger.i('API key set successfully');
    } catch (e) {
      _logger.e('Error setting API key', error: e);
      rethrow;
    }
  }

  /// Clear stored API key (for logout or reset)
  static Future<void> clearApiKey() async {
    try {
      await _storage.delete(key: _apiKeyKey);
      _logger.i('API key cleared');
    } catch (e) {
      _logger.e('Error clearing API key', error: e);
    }
  }

  /// Check if API key is configured
  static Future<bool> isConfigured() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}

/// AI Feature Toggle
/// Controls which AI features are enabled
class AIFeatureConfig {
  static bool get isAICoachEnabled => true;
  static bool get isMoodInsightsEnabled => true;
  static bool get isNutritionAssistantEnabled => true;
  static bool get isRecoveryAdvisorEnabled => true;

  // Future: Can be controlled by Firebase Remote Config for A/B testing
  static bool get useStreamingResponses => true;
  static bool get enableCaching => true;
  static bool get enableAnalytics => true;
}

/// Cost tracking and limits
class AICostConfig {
  // Token costs (per million tokens as of Dec 2024)
  static const double inputCostPer1M = 3.0;  // Sonnet input
  static const double outputCostPer1M = 15.0;  // Sonnet output
  static const double haikuInputCostPer1M = 0.8;  // Haiku input
  static const double haikuOutputCostPer1M = 4.0;  // Haiku output

  /// Calculate cost for a request
  static double calculateCost({
    required int inputTokens,
    required int outputTokens,
    bool useHaiku = false,
  }) {
    if (useHaiku) {
      return (inputTokens / 1000000 * haikuInputCostPer1M) +
             (outputTokens / 1000000 * haikuOutputCostPer1M);
    }

    return (inputTokens / 1000000 * inputCostPer1M) +
           (outputTokens / 1000000 * outputCostPer1M);
  }
}
