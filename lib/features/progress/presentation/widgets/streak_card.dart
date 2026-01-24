import 'package:flutter/material.dart';
import '../../domain/models/streak_data.dart';

/// A card widget displaying the user's current streak
class StreakCard extends StatelessWidget {
  final StreakData streakData;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasStreak = streakData.currentStreak > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: hasStreak
              ? LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasStreak ? null : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: hasStreak ? Colors.white : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Streak',
                  style: TextStyle(
                    color: hasStreak ? Colors.white : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: hasStreak
                        ? Colors.white.withValues(alpha: 0.8)
                        : colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${streakData.currentStreak}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: hasStreak ? Colors.white : colorScheme.onSurface,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    streakData.currentStreak == 1 ? 'day' : 'days',
                    style: TextStyle(
                      fontSize: 16,
                      color: hasStreak
                          ? Colors.white.withValues(alpha: 0.9)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(
                  context,
                  'Best',
                  '${streakData.longestStreak}',
                  hasStreak,
                ),
                _buildMiniStat(
                  context,
                  'Total Active',
                  '${streakData.totalActiveDays}',
                  hasStreak,
                ),
                _buildMiniStat(
                  context,
                  'This Month',
                  '${streakData.activeDatesThisMonth.length}',
                  hasStreak,
                ),
              ],
            ),
            if (streakData.graceDays > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasStreak
                      ? Colors.white.withValues(alpha: 0.2)
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: hasStreak
                          ? Colors.white.withValues(alpha: 0.9)
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${streakData.graceDays} grace day${streakData.graceDays > 1 ? 's' : ''} - miss a day without losing your streak!',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasStreak
                            ? Colors.white.withValues(alpha: 0.9)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    bool hasStreak,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: hasStreak ? Colors.white : colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: hasStreak
                ? Colors.white.withValues(alpha: 0.8)
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A compact streak indicator for dashboard headers
class MiniStreakIndicator extends StatelessWidget {
  final int currentStreak;
  final VoidCallback? onTap;

  const MiniStreakIndicator({
    super.key,
    required this.currentStreak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasStreak = currentStreak > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: hasStreak
              ? LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                )
              : null,
          color: hasStreak ? null : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 18,
              color: hasStreak ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '$currentStreak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasStreak ? Colors.white : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
