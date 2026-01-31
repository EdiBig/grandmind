import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/models/sleep_log.dart';
import '../../data/repositories/sleep_repository.dart';
import 'log_sleep_screen.dart';

// Provider for sleep history
final sleepHistoryProvider =
    FutureProvider.family<List<SleepLog>, int>((ref, days) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repository = ref.watch(sleepRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(Duration(days: days));
  return repository.getLogsInRange(userId, startDate, endDate);
});

class SleepHistoryScreen extends ConsumerStatefulWidget {
  const SleepHistoryScreen({super.key});

  @override
  ConsumerState<SleepHistoryScreen> createState() => _SleepHistoryScreenState();
}

class _SleepHistoryScreenState extends ConsumerState<SleepHistoryScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(sleepHistoryProvider(_selectedDays));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep History'),
        backgroundColor: AppColors.metricSleep,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedDays = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 14, child: Text('Last 14 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteConstants.logSleep),
        backgroundColor: AppColors.metricSleep,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: logsAsync.when(
        data: (logs) => _buildContent(context, logs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: AppColors.error.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              const Text('Error loading history'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SleepLog> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No sleep logs yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your sleep to see trends and insights',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteConstants.logSleep),
              icon: const Icon(Icons.add),
              label: const Text('Log Sleep'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.metricSleep,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, logs),
          const SizedBox(height: 16),
          _buildHoursChart(context, logs),
          const SizedBox(height: 16),
          _buildQualityChart(context, logs),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Recent Sleep Logs'),
          const SizedBox(height: 12),
          _buildLogsList(context, logs),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<SleepLog> logs) {
    final avgHours = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.hoursSlept).reduce((a, b) => a + b) / logs.length;

    final qualityLogs = logs.where((l) => l.quality != null);
    final avgQuality = qualityLogs.isEmpty
        ? 0.0
        : qualityLogs.map((l) => l.quality!).reduce((a, b) => a + b) /
            qualityLogs.length;

    // Find best and worst nights
    final sortedByHours = List<SleepLog>.from(logs)
      ..sort((a, b) => b.hoursSlept.compareTo(a.hoursSlept));
    final bestNight = sortedByHours.isNotEmpty ? sortedByHours.first : null;
    final worstNight = sortedByHours.isNotEmpty ? sortedByHours.last : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary (Last $_selectedDays days)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Total Logs',
                    logs.length.toString(),
                    Icons.calendar_today,
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Avg Hours',
                    _formatHours(avgHours),
                    Icons.bedtime,
                    AppColors.metricSleep,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Avg Quality',
                    avgQuality > 0 ? avgQuality.toStringAsFixed(1) : '-',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            if (bestNight != null && worstNight != null && logs.length > 1) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildNightHighlight(
                      context,
                      'Best Night',
                      bestNight,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNightHighlight(
                      context,
                      'Needs Improvement',
                      worstNight,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNightHighlight(
      BuildContext context, String label, SleepLog log, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d').format(log.logDate),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _formatHours(log.hoursSlept),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHoursChart(BuildContext context, List<SleepLog> logs) {
    // Sort logs by date and take last N entries for cleaner chart
    final sortedLogs = List<SleepLog>.from(logs)
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    // Create bar data
    final barGroups = sortedLogs.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      final hours = log.hoursSlept;

      // Color based on hours
      Color barColor;
      if (hours < 6) {
        barColor = AppColors.error;
      } else if (hours < 7) {
        barColor = AppColors.warning;
      } else if (hours <= 9) {
        barColor = AppColors.success;
      } else {
        barColor = AppColors.info;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: barColor,
            width: sortedLogs.length > 14 ? 8 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: AppColors.metricSleep),
                const SizedBox(width: 8),
                const Text(
                  'Hours per Night',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildChartLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 14,
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedLogs.length) {
                            return const SizedBox.shrink();
                          }
                          final log = sortedLogs[value.toInt()];
                          // Show fewer labels for clarity
                          if (sortedLogs.length > 7 && value.toInt() % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('M/d').format(log.logDate),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final log = sortedLogs[group.x];
                        return BarTooltipItem(
                          '${DateFormat('MMM d').format(log.logDate)}\n${_formatHours(log.hoursSlept)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('<6h', AppColors.error),
        const SizedBox(width: 16),
        _buildLegendItem('6-7h', AppColors.warning),
        const SizedBox(width: 16),
        _buildLegendItem('7-9h', AppColors.success),
        const SizedBox(width: 16),
        _buildLegendItem('>9h', AppColors.info),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildQualityChart(BuildContext context, List<SleepLog> logs) {
    // Filter logs with quality
    final qualityLogs = logs.where((l) => l.quality != null).toList()
      ..sort((a, b) => a.logDate.compareTo(b.logDate));

    if (qualityLogs.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Text(
                    'Quality Trend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Icon(Icons.trending_up,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 8),
              Text(
                'Log sleep quality to see trends',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    final spots = qualityLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.quality!.toDouble());
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text(
                  'Quality Trend',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value < 1 || value > 5) return const SizedBox();
                          final emoji = _getQualityEmoji(value.toInt());
                          return Text(emoji, style: const TextStyle(fontSize: 14));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= qualityLogs.length || index < 0) {
                            return const SizedBox.shrink();
                          }
                          // Show fewer labels for clarity
                          if (qualityLogs.length > 7 && index % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          final log = qualityLogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('M/d').format(log.logDate),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.warning,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.warning.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final log = qualityLogs[spot.x.toInt()];
                          final quality = SleepQuality.fromValue(log.quality!);
                          return LineTooltipItem(
                            '${DateFormat('MMM d').format(log.logDate)}\n${quality.emoji} ${quality.label}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQualityEmoji(int value) {
    switch (value) {
      case 1:
        return '😫';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😴';
      default:
        return '';
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, List<SleepLog> logs) {
    // Sort by most recent first
    final sortedLogs = List<SleepLog>.from(logs)
      ..sort((a, b) => b.logDate.compareTo(a.logDate));

    return Column(
      children: sortedLogs.map((log) => _buildLogCard(context, log)).toList(),
    );
  }

  Widget _buildLogCard(BuildContext context, SleepLog log) {
    final quality =
        log.quality != null ? SleepQuality.fromValue(log.quality!) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LogSleepScreen(existingLog: log),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bedtime,
                      size: 20, color: AppColors.metricSleep),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM d').format(log.logDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getHoursColor(log.hoursSlept).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatHours(log.hoursSlept),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getHoursColor(log.hoursSlept),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (quality != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(quality.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            quality.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (log.bedTime != null && log.wakeTime != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${DateFormat('h:mm a').format(log.bedTime!)} → ${DateFormat('h:mm a').format(log.wakeTime!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (log.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: log.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.metricSleep.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.metricSleep,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  log.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  Color _getHoursColor(double hours) {
    if (hours < 6) return AppColors.error;
    if (hours < 7) return AppColors.warning;
    if (hours <= 9) return AppColors.success;
    return AppColors.info;
  }
}
