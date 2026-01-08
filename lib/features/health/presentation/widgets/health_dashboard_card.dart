import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../data/services/health_service.dart';
import '../providers/health_providers.dart';

/// Health Dashboard Card - displays today's health metrics
class HealthDashboardCard extends ConsumerWidget {
  const HealthDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummaryAsync = ref.watch(todayHealthSummaryProvider);
    final permissionsAsync = ref.watch(healthPermissionsProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final gradients = Theme.of(context).extension<AppGradients>()!;

    return GestureDetector(
      onTap: () => context.push(RouteConstants.healthDetails),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: permissionsAsync.when(
        data: (hasPermissions) {
          if (!hasPermissions) {
            return _buildPermissionRequired(context, ref);
          }

          return healthSummaryAsync.when(
            data: (summary) => _buildHealthData(context, summary, ref),
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(context, ref),
          );
        },
        loading: () => _buildLoading(),
        error: (error, stack) => _buildPermissionRequired(context, ref),
      ),
      ),
    );
  }

  Widget _buildHealthData(BuildContext context, HealthSummary summary, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () {
                ref.invalidate(todayHealthSummaryProvider);
                ref.invalidate(healthSyncProvider);
              },
              tooltip: 'Refresh health data',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Health Metrics Grid
        if (summary.hasMeaningfulData) ...[
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  icon: Icons.directions_walk,
                  value: _formatNumber(summary.steps),
                  label: 'Steps',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  icon: Icons.local_fire_department,
                  value: '${summary.caloriesBurned.toInt()}',
                  label: 'Calories',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  icon: Icons.straighten,
                  value: '${summary.distanceKm.toStringAsFixed(1)}',
                  label: 'km',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  icon: summary.averageHeartRate != null
                      ? Icons.favorite
                      : Icons.bedtime,
                  value: summary.averageHeartRate != null
                      ? '${summary.averageHeartRate!.toInt()}'
                      : summary.sleepHours > 0
                          ? '${summary.sleepHours.toStringAsFixed(1)}h'
                          : '--',
                  label: summary.averageHeartRate != null
                      ? 'BPM'
                      : 'Sleep',
                ),
              ),
            ],
          ),
        ] else
          _buildNoDataMessage(),
      ],
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No health data available yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay active and check back later!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequired(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Health Integration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Track your daily activity, sleep, and more!',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            final healthService = ref.read(healthServiceProvider);
            final granted = await healthService.requestAuthorization();

            if (granted) {
              // Refresh providers
              ref.invalidate(healthPermissionsProvider);
              ref.invalidate(todayHealthSummaryProvider);
            }
          },
          icon: const Icon(Icons.lock_open, size: 18),
          label: const Text('Enable Health Sync'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Health Data Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Unable to load health data',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            ref.invalidate(todayHealthSummaryProvider);
          },
          icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
          label: const Text(
            'Try Again',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
