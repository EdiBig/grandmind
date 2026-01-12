import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/progress_correlation_service.dart';

/// Provider for the progress correlation service
final progressCorrelationServiceProvider = Provider<ProgressCorrelationService>((ref) {
  return ProgressCorrelationService();
});

/// Date range for insights analysis
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Last 7 days
  factory DateRange.last7Days() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }

  /// Last 30 days
  factory DateRange.last30Days() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  /// Last 90 days
  factory DateRange.last90Days() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 90)),
      end: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// State provider for selected date range
/// Default: last 30 days
final insightsDateRangeProvider = StateProvider<DateRange>((ref) {
  return DateRange.last30Days();
});

/// FutureProvider for progress insights based on date range
/// Automatically disposes when no longer used
final progressInsightsProvider = FutureProvider.autoDispose.family<HabitProgressInsights, DateRange>(
  (ref, dateRange) async {
    // Get current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the correlation service
    final service = ref.watch(progressCorrelationServiceProvider);

    // Analyze habit-weight correlations for the given date range
    final insights = await service.analyzeHabitWeightCorrelation(
      userId: userId,
      startDate: dateRange.start,
      endDate: dateRange.end,
    );

    return insights;
  },
);

/// Convenience provider for current date range insights
final currentProgressInsightsProvider = FutureProvider.autoDispose<HabitProgressInsights>(
  (ref) {
    final dateRange = ref.watch(insightsDateRangeProvider);
    return ref.watch(progressInsightsProvider(dateRange).future);
  },
);
