/// Configuration for USDA FoodData Central API
/// https://fdc.nal.usda.gov/api-guide.html
class USDAConfig {
  /// USDA API key from environment or default demo key
  /// Get your own key at: https://fdc.nal.usda.gov/api-key-signup.html
  static String get apiKey {
    const envKey = String.fromEnvironment('USDA_API_KEY', defaultValue: '');
    // Use registered key if no environment key is set (1000 requests/hour)
    return envKey.isNotEmpty ? envKey : 'd8IzzfORhQhsZrhb70XQXl0SnL2ETgr16qwhxRCO';
  }

  /// Base URL for USDA FoodData Central API
  static const String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  /// Check if a custom API key is configured
  static bool get hasCustomKey {
    const envKey = String.fromEnvironment('USDA_API_KEY', defaultValue: '');
    return envKey.isNotEmpty;
  }

  /// Check if USDA is configured (always true, since DEMO_KEY works)
  static bool get isConfigured => true;

  /// Rate limits
  static const int maxRequestsPerHour = 1000; // With API key
  static const int demoRequestsPerHour = 30; // With DEMO_KEY

  /// Default search parameters
  static const int defaultPageSize = 25;
  static const int maxPageSize = 50;
}
