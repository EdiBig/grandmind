import 'package:logger/logger.dart';
import 'remote_config_service.dart';

/// Configuration class for AI features
/// API key is handled server-side via Cloud Functions proxy
class AIConfig {
  static final _logger = Logger();

  // Build-time environment override (use --dart-define=AI_PROXY_URL=...)
  static const String _buildTimeProxyUrl = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: '',
  );

  // AI Feature Limits (can be overridden via Remote Config)
  static int get freeMonthlyMessageLimit =>
      RemoteConfigService.getInt('ai_free_monthly_limit');

  static int get maxTokensPerRequest =>
      RemoteConfigService.getInt('ai_max_tokens_per_request');

  static const int maxRequestsPerMinute = 20;
  static const int cacheExpiryHours = 24;

  // Claude API Configuration
  static const String apiVersion = '2023-06-01';

  static String get defaultModel =>
      RemoteConfigService.getString('ai_default_model');

  static String get fastModel =>
      RemoteConfigService.getString('ai_fast_model');

  // Response Configuration
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1024;
  static const int streamingMaxTokens = 2048;

  /// Initialize AI configuration
  static Future<void> initialize() async {
    // Remote Config should be initialized before this
    _logger.i('AI configuration initialized (using Cloud Functions proxy)');
    _logger.d('Proxy URL: ${getProxyUrl()}');
  }

  /// Get the Cloud Functions proxy URL
  /// Priority: 1. Build-time define, 2. Remote Config, 3. Default
  static String getProxyUrl() {
    // Check for build-time override first
    if (_buildTimeProxyUrl.isNotEmpty) {
      return _buildTimeProxyUrl;
    }

    // Get from Remote Config (falls back to default if not set)
    return RemoteConfigService.getString('ai_proxy_url');
  }

  /// Check if AI is configured (always true with proxy)
  static Future<bool> isConfigured() async {
    return getProxyUrl().isNotEmpty;
  }
}

/// AI Feature Toggle
/// Controls which AI features are enabled (via Remote Config)
class AIFeatureConfig {
  static bool get isAICoachEnabled =>
      RemoteConfigService.getBool('ai_coach_enabled');

  static bool get isMoodInsightsEnabled =>
      RemoteConfigService.getBool('mood_insights_enabled');

  static bool get isNutritionAssistantEnabled =>
      RemoteConfigService.getBool('nutrition_assistant_enabled');

  static bool get isRecoveryAdvisorEnabled =>
      RemoteConfigService.getBool('recovery_advisor_enabled');

  static bool get useStreamingResponses =>
      RemoteConfigService.getBool('ai_streaming_enabled');

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
