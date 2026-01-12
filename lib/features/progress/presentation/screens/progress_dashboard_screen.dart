import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/models/progress_goal.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/measurement_entry.dart';
import '../providers/progress_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/weight_chart_widget.dart';
import '../widgets/goal_progress_card.dart';
import 'weight_tracking_screen.dart';
import 'measurements_screen.dart';
import 'goals_screen.dart';

/// Comprehensive progress dashboard showing all progress metrics
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen> {
  DateRange _selectedRange = DateRange.last30Days;

  @override
  Widget build(BuildContext context) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final measurementEntriesAsync = ref.watch(measurementEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
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
            ),
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
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const GoalsScreen(),
                                ),
                              );
                            },
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
              error: (_, __) => const SizedBox.shrink(),
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
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WeightTrackingScreen(),
                                ),
                              );
                            },
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRangeChip(context),
                      const SizedBox(height: 12),
                      WeightChartWidget(
                        entries: filteredEntries.reversed.toList(),
                        useKg: true,
                      ),
                      const SizedBox(height: 8),
                      _buildWeightInsights(context, filteredEntries),
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
              error: (_, __) => const SizedBox.shrink(),
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
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MeasurementsScreen(),
                                ),
                              );
                            },
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMeasurementsSummary(context, latest),
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
              error: (_, __) => const SizedBox.shrink(),
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
                  color: Colors.white,
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
                      return _buildSummaryStatWhite(
                        context,
                        weight.weight.toStringAsFixed(1),
                        'kg',
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
                    'kg',
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
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeightInsights(
      BuildContext context, List<WeightEntry> entries) {
    if (entries.length < 2) return const SizedBox.shrink();

    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    final latest = sorted.first;
    final oldest = sorted.last;
    final change = latest.weight - oldest.weight;
    final isLoss = change < 0;
    final daysBetween = latest.date.difference(oldest.date).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoss ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoss ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLoss ? Icons.trending_down : Icons.trending_up,
            color: isLoss ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isLoss ? 'Lost' : 'Gained'} ${change.abs().toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLoss
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Over the last $daysBetween days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
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
  ) {
    final types = latest.recordedTypes;
    if (types.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest: ${DateFormat('MMM d, yyyy').format(latest.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: types.take(6).map((type) {
              final value = latest.getMeasurement(type);
              return _buildMeasurementChip(
                context,
                type.displayName,
                value != null ? '${value.toStringAsFixed(1)} cm' : '--',
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
                      color: Colors.grey[600],
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
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
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
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.push(RouteConstants.progressInsights);
            },
            icon: const Icon(Icons.insights),
            label: const Text('View Insights'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: Colors.white,
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.monitor_weight_outlined,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No Weight Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Start tracking your weight to see trends',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WeightTrackingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.straighten, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No Measurement Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Track body measurements to monitor changes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MeasurementsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Tracking'),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 7 Days'),
              selected: _selectedRange == DateRange.last7Days,
              onTap: () {
                setState(() => _selectedRange = DateRange.last7Days);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 30 Days'),
              selected: _selectedRange == DateRange.last30Days,
              onTap: () {
                setState(() => _selectedRange = DateRange.last30Days);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 90 Days'),
              selected: _selectedRange == DateRange.last90Days,
              onTap: () {
                setState(() => _selectedRange = DateRange.last90Days);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('All Time'),
              selected: _selectedRange == DateRange.allTime,
              onTap: () {
                setState(() => _selectedRange = DateRange.allTime);
                Navigator.pop(context);
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

  String _rangeLabel() {
    final days = _selectedRange.end.difference(_selectedRange.start).inDays;
    if (days <= 7) {
      return 'last 7 days';
    }
    if (days <= 30) {
      return 'last 30 days';
    }
    if (days <= 90) {
      return 'last 90 days';
    }
    return 'all time';
  }

  Widget _buildRangeChip(BuildContext context) {
    final label = _rangeLabel();
    final displayLabel =
        label.isEmpty ? label : '${label[0].toUpperCase()}${label.substring(1)}';
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
}
