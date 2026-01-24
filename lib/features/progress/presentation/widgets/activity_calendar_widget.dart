import 'package:flutter/material.dart';
import '../../domain/models/streak_data.dart';

/// A calendar heatmap widget showing activity intensity for each day
class ActivityCalendarWidget extends StatelessWidget {
  final List<ActivityDay> activityDays;
  final DateTime displayMonth;
  final void Function(DateTime, ActivityDay)? onDayTap;

  const ActivityCalendarWidget({
    super.key,
    required this.activityDays,
    required this.displayMonth,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: _calculateGridItemCount(startWeekday, lastDayOfMonth.day),
          itemBuilder: (context, index) {
            final dayOffset = index - (startWeekday - 1);
            final date = firstDayOfMonth.add(Duration(days: dayOffset));

            // Check if date is in current month
            if (date.isBefore(firstDayOfMonth) || date.isAfter(lastDayOfMonth)) {
              return const SizedBox();
            }

            // Find activity for this day
            final activity = _findActivityForDate(date);

            return _buildDayCell(context, date, activity);
          },
        ),

        // Legend
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  int _calculateGridItemCount(int startWeekday, int daysInMonth) {
    // Calculate the total cells needed (start offset + days in month, rounded up to full weeks)
    final totalCells = (startWeekday - 1) + daysInMonth;
    final weeksNeeded = (totalCells / 7).ceil();
    return weeksNeeded * 7;
  }

  ActivityDay _findActivityForDate(DateTime date) {
    return activityDays.firstWhere(
      (a) => a.date.year == date.year &&
             a.date.month == date.month &&
             a.date.day == date.day,
      orElse: () => ActivityDay.empty(date),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, ActivityDay activity) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = _isToday(date);
    final isFuture = date.isAfter(DateTime.now());

    // Color intensity based on activity score
    Color cellColor;
    Color textColor;

    if (isFuture) {
      cellColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      cellColor = _getIntensityColor(context, activity.intensityLevel);
      textColor = activity.intensityLevel >= 3
          ? Colors.white
          : colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: isFuture ? null : () => onDayTap?.call(date, activity),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(BuildContext context, int level) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (level) {
      case 0:
        return colorScheme.surfaceContainerHighest;
      case 1:
        return colorScheme.primary.withValues(alpha: 0.2);
      case 2:
        return colorScheme.primary.withValues(alpha: 0.4);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.6);
      case 4:
        return colorScheme.primary.withValues(alpha: 0.9);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getIntensityColor(context, index),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// A compact version of the activity calendar for dashboard cards
class MiniActivityCalendar extends StatelessWidget {
  final List<ActivityDay> activityDays;
  final VoidCallback? onTap;

  const MiniActivityCalendar({
    super.key,
    required this.activityDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Show last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: last7Days.map((date) {
          final activity = activityDays.firstWhere(
            (a) => a.date.year == date.year &&
                   a.date.month == date.month &&
                   a.date.day == date.day,
            orElse: () => ActivityDay.empty(date),
          );

          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return Column(
            children: [
              Text(
                _getWeekdayLabel(date.weekday),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getIntensityColor(context, activity.intensityLevel),
                  borderRadius: BorderRadius.circular(4),
                  border: isToday
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : null,
                ),
                child: activity.hasActivity
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: activity.intensityLevel >= 3
                            ? Colors.white
                            : colorScheme.primary,
                      )
                    : null,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getWeekdayLabel(int weekday) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[weekday - 1];
  }

  Color _getIntensityColor(BuildContext context, int level) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (level) {
      case 0:
        return colorScheme.surfaceContainerHighest;
      case 1:
        return colorScheme.primary.withValues(alpha: 0.2);
      case 2:
        return colorScheme.primary.withValues(alpha: 0.4);
      case 3:
        return colorScheme.primary.withValues(alpha: 0.6);
      case 4:
        return colorScheme.primary.withValues(alpha: 0.9);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
}
