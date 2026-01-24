import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/predictive_insights_service.dart';

/// Widget showing predictive insights and trend analysis
class EnhancedInsightsWidget extends StatelessWidget {
  final ProgressPredictions predictions;
  final VoidCallback? onViewDetails;

  const EnhancedInsightsWidget({
    super.key,
    required this.predictions,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
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
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insights,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Predictive Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('Details'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Trend Card
          if (predictions.weightTrend.hasEnoughData)
            _buildTrendCard(context, predictions.weightTrend),

          // Goal Predictions
          if (predictions.goalPredictions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Goal Predictions',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...predictions.goalPredictions.take(2).map((prediction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildGoalPredictionCard(context, prediction),
                )),
          ],

          // Insights
          if (predictions.insights.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Insights',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...predictions.insights.take(3).map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildInsightItem(context, insight),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context, TrendData trend) {
    final colorScheme = Theme.of(context).colorScheme;

    Color trendColor;
    IconData trendIcon;

    switch (trend.direction) {
      case TrendDirection.improving:
        trendColor = AppColors.success;
        trendIcon = Icons.trending_up;
        break;
      case TrendDirection.declining:
        trendColor = AppColors.warning;
        trendIcon = Icons.trending_down;
        break;
      case TrendDirection.stable:
        trendColor = colorScheme.primary;
        trendIcon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(trendIcon, color: trendColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight Trend: ${trend.direction.label}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: trendColor,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  trend.changePerWeek.abs() > 0.1
                      ? '${trend.changePerWeek > 0 ? '+' : ''}${trend.changePerWeek.toStringAsFixed(1)}kg per week'
                      : 'Maintaining current weight',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${trend.confidenceLabel} confidence',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: trendColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPredictionCard(
    BuildContext context,
    GoalPrediction prediction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOnTrack = prediction.onTrack;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOnTrack
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isOnTrack ? Icons.check_circle : Icons.warning,
              color: isOnTrack ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.goal.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  prediction.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${prediction.progressPercentage.toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOnTrack ? AppColors.success : AppColors.warning,
                    ),
              ),
              Text(
                'progress',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, String insight) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            insight,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

/// Compact insight card for dashboard
class MiniInsightCard extends StatelessWidget {
  final TrendData trend;
  final VoidCallback? onTap;

  const MiniInsightCard({
    super.key,
    required this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color trendColor;
    IconData trendIcon;

    switch (trend.direction) {
      case TrendDirection.improving:
        trendColor = AppColors.success;
        trendIcon = Icons.trending_up;
        break;
      case TrendDirection.declining:
        trendColor = AppColors.warning;
        trendIcon = Icons.trending_down;
        break;
      case TrendDirection.stable:
        trendColor = colorScheme.primary;
        trendIcon = Icons.trending_flat;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: trendColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: trendColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, color: trendColor, size: 18),
            const SizedBox(width: 6),
            Text(
              trend.direction.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: trendColor,
                fontSize: 13,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: trendColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
