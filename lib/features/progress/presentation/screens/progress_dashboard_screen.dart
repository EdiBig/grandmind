import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/models/progress_goal.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/measurement_entry.dart';
import '../providers/progress_providers.dart';
import '../widgets/weight_chart_widget.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/personal_best_card.dart';
import '../widgets/milestone_widget.dart';

/// Comprehensive progress dashboard showing all progress metrics
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen> {
  DateRange _selectedRange = DateRange.last30Days();

  @override
  Widget build(BuildContext context) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final measurementEntriesAsync = ref.watch(measurementEntriesProvider);
    final useMetric = ref.watch(useMetricUnitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _showDateRangePicker(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weightEntriesProvider);
          ref.invalidate(latestWeightProvider);
          ref.invalidate(latestMeasurementsProvider);
          ref.invalidate(measurementEntriesProvider);
          ref.invalidate(activeGoalsProvider);
          ref.invalidate(streakDataProvider);
          ref.invalidate(personalBestsSummaryProvider);
          ref.invalidate(milestoneSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress Summary Card
            _buildProgressSummaryCard(
              context,
              weightEntriesAsync,
              measurementEntriesAsync,
              activeGoalsAsync,
              useMetric,
            ),
            const SizedBox(height: 24),

            // Streak Card
            _buildStreakSection(context),
            const SizedBox(height: 24),

            // Personal Bests Section
            _buildPersonalBestsSection(context),
            const SizedBox(height: 24),

            // Milestones Section
            _buildMilestonesSection(context),
            const SizedBox(height: 24),

            // Active Goals Section
            activeGoalsAsync.when(
              data: (goals) {
                final filteredGoals = _filterGoalsByRange(goals);
                if (filteredGoals.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Goals',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteConstants.goals),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...filteredGoals.take(3).map((goal) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GoalProgressCard(goal: goal),
                          )),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return _buildEmptyGoalsState(context);
              },
              loading: () => const SizedBox.shrink(),
              error: (error, __) => _buildErrorCard(
                context,
                'Unable to load goals',
                () => ref.invalidate(activeGoalsProvider),
              ),
            ),

            // Weight Trend Section
            weightEntriesAsync.when(
              data: (entries) {
                final filteredEntries = _filterEntriesByRange(entries);
                if (filteredEntries.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weight Trend',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteConstants.weightTracking),
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRangeChip(context),
                      const SizedBox(height: 12),
                      WeightChartWidget(
                        entries: filteredEntries.reversed.toList(),
                        useKg: useMetric,
                      ),
                      const SizedBox(height: 8),
                      _buildWeightInsights(context, filteredEntries, useMetric),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return _buildEmptyWeightState(
                  context,
                  subtitle: 'No weight entries in the selected range.',
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, __) => _buildErrorCard(
                context,
                'Unable to load weight data',
                () => ref.invalidate(weightEntriesProvider),
              ),
            ),

            // Measurements Section
            measurementEntriesAsync.when(
              data: (entries) {
                final filtered = _filterMeasurementEntriesByRange(entries);
                if (filtered.isNotEmpty) {
                  final latest = _latestMeasurement(filtered);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Body Measurements',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteConstants.measurements),
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMeasurementsSummary(context, latest, useMetric),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return _buildEmptyMeasurementsState(
                  context,
                  subtitle: 'No measurements in the selected range.',
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, __) => _buildErrorCard(
                context,
                'Unable to load measurements',
                () => ref.invalidate(measurementEntriesProvider),
              ),
            ),

            // Insights & Correlations Section
            _buildInsightsSection(context, _rangeLabel()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummaryCard(
    BuildContext context,
    AsyncValue<List<WeightEntry>> weightEntriesAsync,
    AsyncValue<List<MeasurementEntry>> measurementEntriesAsync,
    AsyncValue<List<ProgressGoal>> activeGoals,
    bool useMetric,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Latest Weight
              Expanded(
                child: weightEntriesAsync.when(
                  data: (entries) {
                    final filtered = _filterEntriesByRange(entries);
                    final weight = _latestWeight(filtered);
                    if (weight != null) {
                      final displayWeight = useMetric
                          ? weight.weight
                          : weight.weight * 2.20462;
                      final unit = useMetric ? 'kg' : 'lbs';
                      return _buildSummaryStatWhite(
                        context,
                        displayWeight.toStringAsFixed(1),
                        unit,
                        Icons.monitor_weight,
                      );
                    }
                    return _buildSummaryStatWhite(
                      context,
                      '--',
                      'Weight',
                      Icons.monitor_weight,
                    );
                  },
                  loading: () => _buildSummaryStatWhite(
                    context,
                    '...',
                    useMetric ? 'kg' : 'lbs',
                    Icons.monitor_weight,
                  ),
                  error: (_, __) => _buildSummaryStatWhite(
                    context,
                    '--',
                    'Weight',
                    Icons.monitor_weight,
                  ),
                ),
              ),
              // Active Goals Count
              Expanded(
                child: activeGoals.when(
                  data: (goals) {
                    final filtered = _filterGoalsByRange(goals);
                    final activeCount = filtered
                        .where((g) => g.status == GoalStatus.active)
                        .length;
                    return _buildSummaryStatWhite(
                      context,
                      '$activeCount',
                      activeCount == 1 ? 'Goal' : 'Goals',
                      Icons.flag,
                    );
                  },
                  loading: () => _buildSummaryStatWhite(
                    context,
                    '...',
                    'Goals',
                    Icons.flag,
                  ),
                  error: (_, __) => _buildSummaryStatWhite(
                    context,
                    '0',
                    'Goals',
                    Icons.flag,
                  ),
                ),
              ),
              // Measurements Count
              Expanded(
                child: measurementEntriesAsync.when(
                  data: (entries) {
                    final filtered = _filterMeasurementEntriesByRange(entries);
                    final latest = filtered.isEmpty
                        ? null
                        : _latestMeasurement(filtered);
                    final count = latest?.measurements.length ?? 0;
                    return _buildSummaryStatWhite(
                      context,
                      '$count',
                      'Metrics',
                      Icons.straighten,
                    );
                  },
                  loading: () => _buildSummaryStatWhite(
                    context,
                    '...',
                    'Metrics',
                    Icons.straighten,
                  ),
                  error: (_, __) => _buildSummaryStatWhite(
                    context,
                    '0',
                    'Metrics',
                    Icons.straighten,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatWhite(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightInsights(
      BuildContext context, List<WeightEntry> entries, bool useMetric) {
    if (entries.length < 2) return const SizedBox.shrink();

    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    final latest = sorted.first;
    final oldest = sorted.last;
    final change = latest.weight - oldest.weight;
    final displayChange = useMetric ? change : change * 2.20462;
    final unit = useMetric ? 'kg' : 'lbs';
    final isLoss = change < 0;
    final daysBetween = latest.date.difference(oldest.date).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoss ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoss ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLoss ? Icons.trending_down : Icons.trending_up,
            color: isLoss ? AppColors.success : AppColors.warning,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isLoss ? 'Lost' : 'Gained'} ${displayChange.abs().toStringAsFixed(1)} $unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLoss
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Over the last $daysBetween days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsSummary(
    BuildContext context,
    MeasurementEntry latest,
    bool useMetric,
  ) {
    final types = latest.recordedTypes;
    if (types.isEmpty) return const SizedBox.shrink();
    final unit = useMetric ? 'cm' : 'in';
    final conversionFactor = useMetric ? 1.0 : 0.393701;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest: ${DateFormat('MMM d, yyyy').format(latest.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: types.take(6).map((type) {
              final value = latest.getMeasurement(type);
              final displayValue = value != null
                  ? '${(value * conversionFactor).toStringAsFixed(1)} $unit'
                  : '--';
              return _buildMeasurementChip(
                context,
                type.displayName,
                displayValue,
                type.icon,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.secondary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, String rangeLabel) {
    final gradients = Theme.of(context).extension<AppGradients>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradients.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights & Correlations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Discover correlations between your habits and progress ($rangeLabel). '
            'See which habits help you achieve your goals!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.push(RouteConstants.progressInsights);
            },
            icon: Icon(Icons.insights),
            label: const Text('View Insights'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWeightState(BuildContext context, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.monitor_weight_outlined,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No Weight Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Start tracking your weight to see trends',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(RouteConstants.weightTracking),
            icon: Icon(Icons.add),
            label: const Text('Start Tracking'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMeasurementsState(BuildContext context, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.straighten, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No Measurement Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Track body measurements to monitor changes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(RouteConstants.measurements),
            icon: Icon(Icons.add),
            label: const Text('Start Tracking'),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time Range',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 7 Days'),
              selected: _selectedRange.label == 'Last 7 days',
              onTap: () {
                setState(() => _selectedRange = DateRange.last7Days());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 30 Days'),
              selected: _selectedRange.label == 'Last 30 days',
              onTap: () {
                setState(() => _selectedRange = DateRange.last30Days());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 90 Days'),
              selected: _selectedRange.label == 'Last 90 days',
              onTap: () {
                setState(() => _selectedRange = DateRange.last90Days());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('All Time'),
              selected: _selectedRange.label == 'All time',
              onTap: () {
                setState(() => _selectedRange = DateRange.allTime());
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<WeightEntry> _filterEntriesByRange(List<WeightEntry> entries) {
    final range = _selectedRange;
    return entries.where((entry) {
      return !entry.date.isBefore(range.start) &&
          !entry.date.isAfter(range.end);
    }).toList();
  }

  List<MeasurementEntry> _filterMeasurementEntriesByRange(
    List<MeasurementEntry> entries,
  ) {
    final range = _selectedRange;
    return entries.where((entry) {
      return !entry.date.isBefore(range.start) &&
          !entry.date.isAfter(range.end);
    }).toList();
  }

  List<ProgressGoal> _filterGoalsByRange(List<ProgressGoal> goals) {
    final range = _selectedRange;
    return goals.where((goal) {
      final startedWithin = !goal.startDate.isBefore(range.start) &&
          !goal.startDate.isAfter(range.end);
      final completedWithin = goal.completedDate != null &&
          !goal.completedDate!.isBefore(range.start) &&
          !goal.completedDate!.isAfter(range.end);
      final targetWithin = goal.targetDate != null &&
          !goal.targetDate!.isBefore(range.start) &&
          !goal.targetDate!.isAfter(range.end);
      final overlaps = goal.startDate.isBefore(range.end) &&
          (goal.targetDate == null || !goal.targetDate!.isBefore(range.start));
      return startedWithin || completedWithin || targetWithin || overlaps;
    }).toList();
  }

  WeightEntry? _latestWeight(List<WeightEntry> entries) {
    if (entries.isEmpty) return null;
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  MeasurementEntry _latestMeasurement(List<MeasurementEntry> entries) {
    final sorted = List<MeasurementEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  String _rangeLabel() => _selectedRange.label.toLowerCase();

  Widget _buildRangeChip(BuildContext context) {
    final displayLabel = _selectedRange.label;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              displayLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap retry to try again',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No active goals in the selected range.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    final streakAsync = ref.watch(streakDataProvider);

    return streakAsync.when(
      data: (streakData) => StreakCard(
        streakData: streakData,
        onTap: () => context.push(RouteConstants.activityCalendar),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPersonalBestsSection(BuildContext context) {
    final summaryAsync = ref.watch(personalBestsSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary.totalPRCount == 0) return const SizedBox.shrink();
        return PersonalBestsSummaryCard(
          summary: summary,
          onViewAll: () => context.push(RouteConstants.personalBests),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    final summaryAsync = ref.watch(milestoneSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary.totalCount == 0) return const SizedBox.shrink();
        return MilestonesSummaryCard(
          summary: summary,
          onViewAll: null, // TODO: Add milestones screen route
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
