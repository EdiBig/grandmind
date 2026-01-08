import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/measurement_entry.dart';

/// Widget that displays a line chart of measurement entries over time
class MeasurementChartWidget extends StatefulWidget {
  final List<MeasurementEntry> entries;
  final MeasurementType measurementType;
  final bool useCm;

  const MeasurementChartWidget({
    super.key,
    required this.entries,
    required this.measurementType,
    this.useCm = true,
  });

  @override
  State<MeasurementChartWidget> createState() => _MeasurementChartWidgetState();
}

class _MeasurementChartWidgetState extends State<MeasurementChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Filter entries that have this measurement type
    final validEntries = widget.entries
        .where((entry) => entry.hasMeasurement(widget.measurementType))
        .toList();

    if (validEntries.isEmpty) {
      return _buildEmptyState();
    }

    if (validEntries.length == 1) {
      return _buildSingleEntryState(validEntries.first);
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
            '${widget.measurementType.displayName} Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              _buildLineChartData(validEntries),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<MeasurementEntry> validEntries) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = _getSpots(validEntries);
    final minValue = _getMinValue(validEntries);
    final maxValue = _getMaxValue(validEntries);
    final valueRange = maxValue - minValue;

    final effectiveRange = valueRange > 0 ? valueRange : 10.0;
    final padding = effectiveRange * 0.1;

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
            interval: _getBottomInterval(validEntries),
            getTitlesWidget: (value, meta) {
              if (value.toInt() < 0 ||
                  value.toInt() >= validEntries.length) {
                return const SizedBox.shrink();
              }

              final entry = validEntries[value.toInt()];
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
      maxX: (validEntries.length - 1).toDouble(),
      minY: valueRange > 0 ? minValue - padding : minValue - effectiveRange / 2,
      maxY: valueRange > 0 ? maxValue + padding : maxValue + effectiveRange / 2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colorScheme.secondary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: touchedIndex == index ? 6 : 4,
                color: colorScheme.secondary,
                strokeWidth: touchedIndex == index ? 2 : 0,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.secondary.withOpacity(0.3),
                colorScheme.secondary.withOpacity(0.0),
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
          getTooltipColor: (touchedSpot) => colorScheme.secondary,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final entry = validEntries[spot.x.toInt()];
              final value = entry.getMeasurement(widget.measurementType);
              if (value == null) return null;

              final displayValue =
                  widget.useCm ? value : value / 2.54; // Convert to inches
              final unit = widget.useCm ? 'cm' : 'in';
              final dateStr = DateFormat('MMM d, yyyy').format(entry.date);

              return LineTooltipItem(
                '${displayValue.toStringAsFixed(1)} $unit\n$dateStr',
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

  List<FlSpot> _getSpots(List<MeasurementEntry> validEntries) {
    final spots = <FlSpot>[];

    for (var i = 0; i < validEntries.length; i++) {
      final entry = validEntries[i];
      final value = entry.getMeasurement(widget.measurementType);
      if (value != null) {
        final displayValue = widget.useCm ? value : value / 2.54;
        spots.add(FlSpot(i.toDouble(), displayValue));
      }
    }

    return spots;
  }

  double _getMinValue(List<MeasurementEntry> validEntries) {
    double? minValue;

    for (var entry in validEntries) {
      final value = entry.getMeasurement(widget.measurementType);
      if (value != null) {
        final displayValue = widget.useCm ? value : value / 2.54;
        if (minValue == null || displayValue < minValue) {
          minValue = displayValue;
        }
      }
    }

    return minValue ?? 0;
  }

  double _getMaxValue(List<MeasurementEntry> validEntries) {
    double? maxValue;

    for (var entry in validEntries) {
      final value = entry.getMeasurement(widget.measurementType);
      if (value != null) {
        final displayValue = widget.useCm ? value : value / 2.54;
        if (maxValue == null || displayValue > maxValue) {
          maxValue = displayValue;
        }
      }
    }

    return maxValue ?? 100;
  }

  double _getBottomInterval(List<MeasurementEntry> validEntries) {
    final count = validEntries.length;

    if (count <= 7) return 1;
    if (count <= 30) return count / 5;
    return count / 4;
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
            'No Measurement Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log ${widget.measurementType.displayName} to see the chart',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleEntryState(MeasurementEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = entry.getMeasurement(widget.measurementType);
    if (value == null) return _buildEmptyState();

    final displayValue = widget.useCm ? value : value / 2.54;
    final unit = widget.useCm ? 'cm' : 'in';

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
            '${displayValue.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log more measurements to see trends',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
