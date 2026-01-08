import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../data/services/progress_correlation_service.dart';
import '../providers/progress_insights_provider.dart';
import '../widgets/helpful_habit_card.dart';
import '../widgets/habit_to_review_card.dart';
import '../widgets/correlation_bar_chart.dart';

class ProgressInsightsScreen extends ConsumerWidget {
  const ProgressInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(insightsDateRangeProvider);
    final insightsAsync = ref.watch(progressInsightsProvider(dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Insights'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangeSelector(context, ref),
          ),
        ],
      ),
      body: insightsAsync.when(
        data: (insights) {
          if (!insights.hasEnoughData) {
            return _buildEmptyState(context);
          }
          return _buildInsightsContent(context, ref, insights, dateRange);
        },
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error, ref, dateRange),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing your progress...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Not Enough Data Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Log at least 2 weight entries and track some habits to see correlations between your habits and progress.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.pop();
                // Navigate to weight tracking or habits
              },
              icon: const Icon(Icons.add),
              label: const Text('Start Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    WidgetRef ref,
    DateRange dateRange,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'There was an error analyzing your data. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(progressInsightsProvider(dateRange));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent(
    BuildContext context,
    WidgetRef ref,
    HabitProgressInsights insights,
    DateRange dateRange,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header Icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<AppGradients>()!.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          'Your Progress Insights',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          insights.dateRange,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // Overview Card
        _buildOverviewCard(context, insights),
        const SizedBox(height: 24),

        // Helpful Habits Section
        if (insights.topHelpfulHabits.isNotEmpty) ...[
          _buildSection(
            context,
            icon: Icons.emoji_events,
            title: 'Habits That Help',
            iconColor: Colors.green,
            children: insights.topHelpfulHabits
                .map((correlation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HelpfulHabitCard(correlation: correlation),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ] else ...[
          _buildSection(
            context,
            icon: Icons.emoji_events,
            title: 'Habits That Help',
            iconColor: Colors.green,
            children: [
              Text(
                'Keep tracking to discover helpful patterns!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Habits to Review Section
        if (insights.habitsToReview.isNotEmpty) ...[
          _buildSection(
            context,
            icon: Icons.lightbulb,
            title: 'Habits to Adjust',
            iconColor: Colors.orange,
            children: insights.habitsToReview
                .map((correlation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HabitToReviewCard(correlation: correlation),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ] else ...[
          _buildSection(
            context,
            icon: Icons.lightbulb,
            title: 'Habits to Adjust',
            iconColor: Colors.orange,
            children: [
              Text(
                'All habits look good! 🎉',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Correlation Chart
        if (insights.correlations.isNotEmpty) ...[
          _buildSection(
            context,
            icon: Icons.bar_chart,
            title: 'Correlation Strengths',
            iconColor: Theme.of(context).colorScheme.primary,
            children: [
              CorrelationBarChart(correlations: insights.correlations),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
              const SizedBox(height: 8),
              Text(
                'These correlations are statistical patterns based on your tracking data, not medical advice. Consult a healthcare professional for health-related concerns.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, HabitProgressInsights insights) {
    final weightChange = insights.overallWeightChange;
    final isLoss = weightChange < 0;
    final changeColor = isLoss ? Colors.green : Colors.red;
    final changeIcon = isLoss ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight Change',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(changeIcon, color: changeColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${weightChange.abs().toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Habits Tracked',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insights.correlations.length.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _showDateRangeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date Range',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDateRangeOption(
                context,
                ref,
                'Last 7 Days',
                DateRange.last7Days(),
              ),
              _buildDateRangeOption(
                context,
                ref,
                'Last 30 Days',
                DateRange.last30Days(),
              ),
              _buildDateRangeOption(
                context,
                ref,
                'Last 90 Days',
                DateRange.last90Days(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    DateRange range,
  ) {
    final currentRange = ref.read(insightsDateRangeProvider);
    final isSelected = currentRange == range;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(insightsDateRangeProvider.notifier).state = range;
        Navigator.pop(context);
      },
    );
  }
}
