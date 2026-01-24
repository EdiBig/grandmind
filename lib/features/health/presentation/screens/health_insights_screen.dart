import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/models/health_insights.dart';
import '../providers/health_providers.dart';
import '../widgets/health_correlation_card.dart';

class HealthInsightsScreen extends ConsumerWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(healthInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(healthInsightsProvider),
            tooltip: 'Refresh insights',
          ),
        ],
      ),
      body: insightsAsync.when(
        data: (insights) => _buildInsightsContent(context, insights),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing your health data...'),
            ],
          ),
        ),
        error: (error, stack) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, HealthInsights insights) {
    final gradients = Theme.of(context).extension<AppGradients>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Header
          _buildAIHeader(context, gradients),
          const SizedBox(height: 24),

          // Summary Section
          _buildSummarySection(context, insights),
          const SizedBox(height: 24),

          // Weekly Comparison
          _buildWeeklyComparison(context, insights.weeklyComparison),
          const SizedBox(height: 24),

          // Correlations Discovered
          if (insights.correlations.isNotEmpty) ...[
            _buildSectionTitle(context, 'Correlations Discovered'),
            const SizedBox(height: 12),
            ...insights.correlations.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HealthCorrelationCard(correlation: c),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Trends Section
          _buildTrendsSection(context, insights.trends),
          const SizedBox(height: 24),

          // Key Insights
          if (insights.keyInsights.isNotEmpty) ...[
            _buildSectionTitle(context, 'Key Insights'),
            const SizedBox(height: 12),
            _buildKeyInsights(context, insights.keyInsights),
            const SizedBox(height: 24),
          ],

          // Suggestions
          if (insights.suggestions.isNotEmpty) ...[
            _buildSectionTitle(context, 'Suggestions'),
            const SizedBox(height: 12),
            _buildSuggestions(context, insights.suggestions),
            const SizedBox(height: 24),
          ],

          // Statistics Grid
          _buildStatisticsGrid(context, insights.statistics),
          const SizedBox(height: 24),

          // Health Disclaimer
          _buildDisclaimer(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAIHeader(BuildContext context, AppGradients gradients) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personalised insights from your health data',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, HealthInsights insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insights.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison(BuildContext context, WeeklyComparison comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'This Week vs Last Week'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                context,
                'Steps',
                comparison.stepsChange,
                Icons.directions_walk,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                context,
                'Sleep',
                comparison.sleepChange,
                Icons.bedtime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                context,
                'Calories',
                comparison.caloriesChange,
                Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWorkoutComparisonCard(
                context,
                comparison.workoutsThisWeek,
                comparison.workoutsLastWeek,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    String label,
    double changePercent,
    IconData icon,
  ) {
    final isPositive = changePercent >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 16,
              ),
              Text(
                '${changePercent.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutComparisonCard(
    BuildContext context,
    int thisWeek,
    int lastWeek,
  ) {
    final diff = thisWeek - lastWeek;
    final isPositive = diff >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            'Workouts',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '$thisWeek vs $lastWeek',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection(BuildContext context, HealthTrends trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Trends (7-day)'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTrendChip(context, 'Steps', trends.steps),
            _buildTrendChip(context, 'Sleep', trends.sleep),
            _buildTrendChip(context, 'Calories', trends.calories),
            _buildTrendChip(context, 'Activity', trends.activity),
            if (trends.mood != null)
              _buildTrendChip(context, 'Mood', trends.mood!),
            if (trends.energy != null)
              _buildTrendChip(context, 'Energy', trends.energy!),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendChip(BuildContext context, String label, TrendDirection direction) {
    Color chipColor;
    Color textColor;

    switch (direction) {
      case TrendDirection.improving:
        chipColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case TrendDirection.declining:
        chipColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
      case TrendDirection.stable:
        chipColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        break;
      case TrendDirection.insufficient:
        chipColor = AppColors.grey.withValues(alpha: 0.1);
        textColor = AppColors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            direction.emoji,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights(BuildContext context, List<String> insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: insights.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < insights.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, List<String> suggestions) {
    return Column(
      children: suggestions.asMap().entries.map((entry) {
        return Container(
          margin: EdgeInsets.only(
            bottom: entry.key < suggestions.length - 1 ? 12 : 0,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, HealthInsightsStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Statistics (${stats.daysWithData} days)'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Avg Steps',
                      stats.avgSteps.toStringAsFixed(0),
                      Icons.directions_walk,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Avg Sleep',
                      '${stats.avgSleepHours.toStringAsFixed(1)}h',
                      Icons.bedtime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Avg Calories',
                      stats.avgCalories.toStringAsFixed(0),
                      Icons.local_fire_department,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Workouts',
                      stats.totalWorkouts.toString(),
                      Icons.fitness_center,
                    ),
                  ),
                ],
              ),
              if (stats.avgMoodRating != null || stats.avgEnergyLevel != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (stats.avgMoodRating != null)
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Avg Mood',
                          '${stats.avgMoodRating!.toStringAsFixed(1)}/5',
                          Icons.mood,
                        ),
                      ),
                    if (stats.avgEnergyLevel != null)
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Avg Energy',
                          '${stats.avgEnergyLevel!.toStringAsFixed(1)}/5',
                          Icons.bolt,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These insights are for informational purposes only and should not replace professional medical advice.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to generate insights',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure you have at least 7 days of health data synced.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(healthInsightsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
