import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/progress_correlation_service.dart';

class CorrelationBarChart extends StatelessWidget {
  final List<HabitCorrelation> correlations;

  const CorrelationBarChart({
    super.key,
    required this.correlations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (correlations.isEmpty) {
      return Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No correlation data available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Limit to top 10 correlations for better visualization
    final displayCorrelations = correlations.take(10).toList();
    final chartHeight = (displayCorrelations.length * 50.0).clamp(200.0, 500.0);

    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          minY: -1.0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.primary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final correlation = displayCorrelations[group.x.toInt()];
                return BarTooltipItem(
                  '${correlation.habit.name}\n',
                  TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: 'Correlation: ${correlation.correlationStrength.toStringAsFixed(2)}\n',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: correlation.strengthLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
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
                getTitlesWidget: (value, meta) {
                  // Show -1, 0, 1 labels
                  if (value == -1) return const Text('-1', style: TextStyle(fontSize: 10));
                  if (value == 0) return const Text('0', style: TextStyle(fontSize: 10));
                  if (value == 1) return const Text('1', style: TextStyle(fontSize: 10));
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 120,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= displayCorrelations.length) {
                    return const SizedBox.shrink();
                  }
                  final habit = displayCorrelations[index].habit;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      habit.name,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 0.5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              // Highlight the zero line
              if (value == 0) {
                return FlLine(
                  color: AppColors.grey.withValues(alpha: 0.5),
                  strokeWidth: 2,
                );
              }
              return FlLine(
                color: AppColors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.2),
            ),
          ),
          barGroups: displayCorrelations.asMap().entries.map((entry) {
            final index = entry.key;
            final correlation = entry.value;
            final strength = correlation.correlationStrength;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: strength,
                  color: _getCorrelationColor(strength),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getCorrelationColor(double strength) {
    if (strength > 0.3) {
      return AppColors.success;
    } else if (strength > 0) {
      return AppColors.success.withValues(alpha: 0.7);
    } else if (strength > -0.2) {
      return AppColors.grey;
    } else {
      return AppColors.warning;
    }
  }
}
