import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/models/weight_entry.dart';

class MiniWeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final bool useKg;

  const MiniWeightChart({
    super.key,
    required this.entries,
    this.useKg = true,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (entries.length - 1).toDouble(),
          minY: _getMinWeight() - 1,
          maxY: _getMaxWeight() + 1,
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              color: Colors.white,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final displayWeight = useKg ? entry.weight : entry.weight * 2.20462;
      spots.add(FlSpot(i.toDouble(), displayWeight));
    }
    return spots;
  }

  double _getMinWeight() {
    if (entries.isEmpty) return 0;
    var minWeight = entries.first.weight;
    for (var entry in entries) {
      if (entry.weight < minWeight) {
        minWeight = entry.weight;
      }
    }
    return useKg ? minWeight : minWeight * 2.20462;
  }

  double _getMaxWeight() {
    if (entries.isEmpty) return 100;
    var maxWeight = entries.first.weight;
    for (var entry in entries) {
      if (entry.weight > maxWeight) {
        maxWeight = entry.weight;
      }
    }
    return useKg ? maxWeight : maxWeight * 2.20462;
  }
}
