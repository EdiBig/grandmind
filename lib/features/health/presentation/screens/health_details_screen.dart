import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../providers/health_providers.dart';

class HealthDetailsScreen extends ConsumerStatefulWidget {
  const HealthDetailsScreen({super.key});

  @override
  ConsumerState<HealthDetailsScreen> createState() =>
      _HealthDetailsScreenState();
}

class _HealthDetailsScreenState extends ConsumerState<HealthDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 7; // Default to 7 days
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runHealthSync();
      ref.invalidate(weeklyHealthStatsProvider);
      ref.invalidate(dailyHealthPointsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyStatsAsync = ref.watch(weeklyHealthStatsProvider);
    final dailyPointsAsync = ref.watch(dailyHealthPointsProvider(_selectedDays));
    final permissionsAsync = ref.watch(healthPermissionsProvider);
    final lastSyncAsync = ref.watch(lastHealthSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => context.push(RouteConstants.healthInsights),
            tooltip: 'View Insights',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _runHealthSync();
              ref.invalidate(weeklyHealthStatsProvider);
              ref.invalidate(dailyHealthPointsProvider);
              ref.invalidate(syncedTodayHealthDataProvider);
            },
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: permissionsAsync.when(
        data: (hasPermissions) {
          if (!hasPermissions) {
            return _buildPermissionRequired(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSyncStatusCard(context, lastSyncAsync),
                const SizedBox(height: 16),
                // Weekly Stats Card
                weeklyStatsAsync.when(
                  data: (stats) => _buildWeeklyStatsCard(stats),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _buildErrorCard('Failed to load weekly stats'),
                ),
                const SizedBox(height: 16),

                // View Insights Button
                _buildInsightsButton(context),
                const SizedBox(height: 24),

                // Time Range Selector
                _buildTimeRangeSelector(),
                const SizedBox(height: 16),

                // Charts with Tabs
                _buildChartsSection(dailyPointsAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildPermissionRequired(context),
      ),
    );
  }

  Widget _buildWeeklyStatsCard(dynamic stats) {
    final gradients = Theme.of(context).extension<AppGradients>()!;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStatItem(
                  icon: Icons.directions_walk,
                  value: _formatNumber(stats.totalSteps),
                  label: 'Total Steps',
                  subtitle: '${stats.averageStepsPerDay.toStringAsFixed(0)}/day avg',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeeklyStatItem(
                  icon: Icons.local_fire_department,
                  value: '${stats.totalCalories.toStringAsFixed(0)}',
                  label: 'Calories',
                  subtitle: '${stats.averageCaloriesPerDay.toStringAsFixed(0)}/day avg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStatItem(
                  icon: Icons.straighten,
                  value: '${stats.totalDistanceKm.toStringAsFixed(1)} km',
                  label: 'Distance',
                  subtitle: '${stats.averageDistancePerDay.toStringAsFixed(1)} km/day',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWeeklyStatItem(
                  icon: Icons.bedtime,
                  value: '${stats.averageSleepHours.toStringAsFixed(1)}h',
                  label: 'Avg Sleep',
                  subtitle: 'per night',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatItem({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildRangeButton('7 Days', 7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRangeButton('14 Days', 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRangeButton('30 Days', 30),
        ),
      ],
    );
  }

  Widget _buildRangeButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDays = days;
        });
        ref.invalidate(dailyHealthPointsProvider);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        foregroundColor: isSelected ? AppColors.white : AppColors.black.withValues(alpha: 0.87),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildChartsSection(AsyncValue<List<dynamic>> dailyPointsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Steps'),
              Tab(text: 'Calories'),
              Tab(text: 'Distance'),
              Tab(text: 'Sleep'),
            ],
          ),
          SizedBox(
            height: 300,
            child: dailyPointsAsync.when(
              data: (points) {
                if (points.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No data available for this period'),
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStepsChart(points),
                    _buildCaloriesChart(points),
                    _buildDistanceChart(points),
                    _buildSleepChart(points),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Failed to load chart data'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsChart(List<dynamic> points) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < points.length) {
                    final point = points[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.steps.toDouble()))
                  .toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(List<dynamic> points) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < points.length) {
                    final point = points[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.calories))
                  .toList(),
              isCurved: true,
              color: AppColors.warning,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.warning.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceChart(List<dynamic> points) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < points.length) {
                    final point = points[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.distanceKm))
                  .toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.tertiary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(List<dynamic> points) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < points.length) {
                    final point = points[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('MM/dd').format(point.date),
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.sleepHours))
                  .toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.secondary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'Health Permissions Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To view your health details, please grant access to your health data.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final healthService = ref.read(healthServiceProvider);
                final granted = await healthService.requestAuthorization();

                if (granted && context.mounted) {
                  ref.invalidate(healthPermissionsProvider);
                  await _runHealthSync();
                  ref.invalidate(weeklyHealthStatsProvider);
                  ref.invalidate(syncedTodayHealthDataProvider);
                  ref.invalidate(dailyHealthPointsProvider);
                  ref
                      .read(healthSummaryProvider.notifier)
                      .refresh(force: true);
                } else if (context.mounted) {
                  // Permission request failed - show snackbar with option to open settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Permission denied. Open Settings to enable health access.',
                      ),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Settings',
                        onPressed: () async {
                          await healthService.openHealthSettings();
                        },
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Secondary button to open settings directly
            TextButton.icon(
              onPressed: () async {
                final healthService = ref.read(healthServiceProvider);
                await healthService.openHealthSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Health Settings'),
            ),
            const SizedBox(height: 24),
            Text(
              'If you previously denied access, you may need to enable it in your device settings.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Future<void> _runHealthSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await ref.read(healthSyncProvider.future);
      ref.invalidate(lastHealthSyncProvider);
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Widget _buildSyncStatusCard(
    BuildContext context,
    AsyncValue<DateTime?> lastSyncAsync,
  ) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Row(
        children: [
          Icon(
            _isSyncing ? Icons.sync : Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: lastSyncAsync.when(
              data: (timestamp) => Text(
                _isSyncing
                    ? 'Syncing health data...'
                    : _formatLastSync(timestamp),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              loading: () => const Text('Checking last sync...'),
              error: (_, __) => const Text('Unable to read last sync time'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Last synced: never';
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Last synced: just now';
    }
    if (difference.inMinutes < 60) {
      return 'Last synced: ${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return 'Last synced: ${difference.inHours}h ago';
    }
    return 'Last synced: ${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  Widget _buildInsightsButton(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteConstants.healthInsights),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View AI Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get personalised health analysis and recommendations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
