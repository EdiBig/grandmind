import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/weight_entry.dart';

/// Widget that displays a line chart of weight entries over time
class WeightChartWidget extends StatefulWidget {
  final List<WeightEntry> entries;
  final bool useKg;

  const WeightChartWidget({
    super.key,
    required this.entries,
    this.useKg = true,
  });

  @override
  State<WeightChartWidget> createState() => _WeightChartWidgetState();
}

class _WeightChartWidgetState extends State<WeightChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return _buildEmptyState();
    }

    if (widget.entries.length == 1) {
      return _buildSingleEntryState();
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              _buildLineChartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final spots = _getSpots();
    final minWeight = _getMinWeight();
    final maxWeight = _getMaxWeight();
    final weightRange = maxWeight - minWeight;

    // Ensure minimum range to prevent division by zero in fl_chart
    final effectiveRange = weightRange > 0 ? weightRange : 10.0;
    final padding = effectiveRange * 0.1; // 10% padding on Y-axis

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (effectiveRange + padding * 2) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomInterval(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() < 0 || value.toInt() >= widget.entries.length) {
                return const SizedBox.shrink();
              }

              final entry = widget.entries[value.toInt()];
              final dateStr = DateFormat('MMM d').format(entry.date);

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
          left: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      minX: 0,
      maxX: (widget.entries.length - 1).toDouble(),
      minY: weightRange > 0 ? minWeight - padding : minWeight - effectiveRange / 2,
      maxY: weightRange > 0 ? maxWeight + padding : maxWeight + effectiveRange / 2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: touchedIndex == index ? 6 : 4,
                color: AppColors.primary,
                strokeWidth: touchedIndex == index ? 2 : 0,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          setState(() {
            if (response == null || response.lineBarSpots == null) {
              touchedIndex = null;
              return;
            }
            touchedIndex = response.lineBarSpots!.first.spotIndex;
          });
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.primary,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final entry = widget.entries[spot.x.toInt()];
              final displayWeight = widget.useKg
                  ? entry.weight
                  : entry.weight * 2.20462;
              final unit = widget.useKg ? 'kg' : 'lbs';
              final dateStr = DateFormat('MMM d, yyyy').format(entry.date);

              return LineTooltipItem(
                '${displayWeight.toStringAsFixed(1)} $unit\n$dateStr',
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
    );
  }

  List<FlSpot> _getSpots() {
    final spots = <FlSpot>[];

    for (var i = 0; i < widget.entries.length; i++) {
      final entry = widget.entries[i];
      final displayWeight = widget.useKg
          ? entry.weight
          : entry.weight * 2.20462;

      spots.add(FlSpot(i.toDouble(), displayWeight));
    }

    return spots;
  }

  double _getMinWeight() {
    if (widget.entries.isEmpty) return 0;

    var minWeight = widget.entries.first.weight;
    for (var entry in widget.entries) {
      if (entry.weight < minWeight) {
        minWeight = entry.weight;
      }
    }

    return widget.useKg ? minWeight : minWeight * 2.20462;
  }

  double _getMaxWeight() {
    if (widget.entries.isEmpty) return 100;

    var maxWeight = widget.entries.first.weight;
    for (var entry in widget.entries) {
      if (entry.weight > maxWeight) {
        maxWeight = entry.weight;
      }
    }

    return widget.useKg ? maxWeight : maxWeight * 2.20462;
  }

  double _getBottomInterval() {
    final count = widget.entries.length;

    if (count <= 7) return 1; // Show every day
    if (count <= 30) return count / 5; // Show ~5 labels
    return count / 4; // Show ~4 labels for longer periods
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No Weight Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log your weight to see the chart',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleEntryState() {
    final entry = widget.entries.first;
    final displayWeight = widget.useKg
        ? entry.weight
        : entry.weight * 2.20462;
    final unit = widget.useKg ? 'kg' : 'lbs';

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Single Entry',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${displayWeight.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log more weights to see trends',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
