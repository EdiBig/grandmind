import 'package:logger/logger.dart';

/// Configuration class for AI features
/// API key is handled server-side via Cloud Functions proxy
class AIConfig {
  static final _logger = Logger();

  // AI Feature Limits
  static const int freeMonthlyMessageLimit = 20;
  static const int maxTokensPerRequest = 4096;
  static const int maxRequestsPerMinute = 20;
  static const int cacheExpiryHours = 24;

  // Claude API Configuration (used by proxy)
  static const String apiVersion = '2023-06-01';
  static const String defaultModel = 'claude-3-haiku-20240307';
  static const String fastModel = 'claude-3-haiku-20240307';

  // Response Configuration
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1024;
  static const int streamingMaxTokens = 2048;

  // Cloud Functions Proxy URL
  static const String _proxyUrl = 'https://claudeproxy-fy7x3gndyq-uc.a.run.app';

  /// Initialize AI configuration
  /// No longer fetches API key - handled server-side
  static Future<void> initialize() async {
    _logger.i('AI configuration initialized (using Cloud Functions proxy)');
  }

  /// Get the Cloud Functions proxy URL
  static String getProxyUrl() {
    return _proxyUrl;
  }

  /// Check if AI is configured (always true with proxy)
  static Future<bool> isConfigured() async {
    return true;
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
  static bool get useStreamingResponses => false; // Streaming not yet supported via proxy
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
