import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/analytics_service.dart';

/// Provider for the analytics service
/// Use this to access analytics throughout the app
final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
