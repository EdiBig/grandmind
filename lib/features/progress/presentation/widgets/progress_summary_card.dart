import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/progress_providers.dart';
import 'mini_weight_chart.dart';

class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);

    return GestureDetector(
      onTap: () => context.push(RouteConstants.progressDashboard),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.cyan.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini Weight Chart
            weightEntriesAsync.when(
              data: (entries) {
                if (entries.isNotEmpty) {
                  // Get last 7 days
                  final last7Days = entries.take(7).toList().reversed.toList();
                  return MiniWeightChart(entries: last7Days);
                }
                return _buildEmptyChart(context);
              },
              loading: () => _buildLoadingChart(),
              error: (_, __) => _buildEmptyChart(context),
            ),
            const SizedBox(height: 16),

            // Current Weight and Change
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current Weight
                Expanded(
                  child: latestWeightAsync.when(
                    data: (weight) {
                      if (weight != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weight.weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'No data',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // Week-over-week change
                weightEntriesAsync.when(
                  data: (entries) {
                    if (entries.length >= 2) {
                      final latest = entries.first.weight;
                      final weekAgo = entries.length >= 7
                          ? entries[6].weight
                          : entries.last.weight;
                      final change = latest - weekAgo;

                      return _buildWeightChange(change);
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Goals
            activeGoalsAsync.when(
              data: (goals) {
                final activeCount = goals.length;
                final onTrack = goals.where((g) {
                  final progress = g.progressPercentage;
                  return progress >= 25; // Simple on-track logic
                }).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Goals: $activeCount',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    if (activeCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            onTrack > 0 ? 'On Track' : 'Keep Going',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
              loading: () => Text(
                'Loading goals...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // View Details Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChange(double change) {
    final isLoss = change < 0;
    final color = isLoss ? Colors.green : Colors.red;
    final icon = isLoss ? Icons.arrow_downward : Icons.arrow_upward;

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '${change.abs().toStringAsFixed(1)} kg',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Start tracking to see your progress',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
