import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/personal_best.dart';

/// Card widget for displaying a personal best record
class PersonalBestCard extends StatelessWidget {
  final PersonalBest pr;
  final VoidCallback? onTap;
  final bool showImprovement;

  const PersonalBestCard({
    super.key,
    required this.pr,
    this.onTap,
    this.showImprovement = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasImprovement = pr.previousValue != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade400,
              Colors.orange.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(pr.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pr.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        pr.metric,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatValue(pr.value, pr.unit),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    pr.unit,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (showImprovement && hasImprovement)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${pr.improvementPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Previous record and date
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(pr.achievedAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                if (hasImprovement) ...[
                  const Spacer(),
                  Text(
                    'Previous: ${_formatValue(pr.previousValue!, pr.unit)} ${pr.unit}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),

            // Notes
            if (pr.notes != null && pr.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                pr.notes!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(PersonalBestCategory category) {
    switch (category) {
      case PersonalBestCategory.weight:
        return Icons.monitor_weight;
      case PersonalBestCategory.workout:
        return Icons.fitness_center;
      case PersonalBestCategory.strength:
        return Icons.sports_gymnastics;
      case PersonalBestCategory.cardio:
        return Icons.directions_run;
      case PersonalBestCategory.streak:
        return Icons.local_fire_department;
      case PersonalBestCategory.habit:
        return Icons.check_circle;
    }
  }

  String _formatValue(double value, String unit) {
    if (unit == 'min') {
      final minutes = value.floor();
      final seconds = ((value - minutes) * 60).round();
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return value.toStringAsFixed(1);
  }
}

/// Compact PR indicator for lists
class MiniPersonalBestIndicator extends StatelessWidget {
  final int prCount;
  final VoidCallback? onTap;

  const MiniPersonalBestIndicator({
    super.key,
    required this.prCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (prCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade500],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '$prCount PR${prCount > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary card showing PR statistics
class PersonalBestsSummaryCard extends StatelessWidget {
  final PersonalBestsSummary summary;
  final VoidCallback? onViewAll;

  const PersonalBestsSummaryCard({
    super.key,
    required this.summary,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Personal Records',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '${summary.totalPRCount}',
                  'Total PRs',
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '${summary.monthlyPRCount}',
                  'This Month',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '${summary.allTimeBests.length}',
                  'Categories',
                  Colors.blue,
                ),
              ),
            ],
          ),
          if (summary.recentPRs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recent PRs',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...summary.recentPRs.take(3).map((pr) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildMiniPRItem(context, pr),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildMiniPRItem(BuildContext context, PersonalBest pr) {
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          size: 16,
          color: Colors.amber.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            pr.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${pr.value.toStringAsFixed(1)} ${pr.unit}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
