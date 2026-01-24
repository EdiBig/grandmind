import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/health_service.dart';
import '../../domain/models/health_data.dart';
import '../providers/health_providers.dart';

final _dashboardRefreshingProvider = StateProvider<bool>((ref) => false);

/// Health Dashboard Card - displays today's health metrics
class HealthDashboardCard extends ConsumerWidget {
  const HealthDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSummaryAsync = ref.watch(healthSummaryProvider);
    final permissionsAsync = ref.watch(healthPermissionsProvider);
    final lastSyncAsync = ref.watch(lastHealthSyncProvider);
    final isRefreshing = ref.watch(_dashboardRefreshingProvider);
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
            color: primary.withValues(alpha: 0.3),
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
            data: (summary) => _buildHealthData(
              context,
              summary,
              lastSyncAsync,
              isRefreshing,
              ref,
            ),
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

  Widget _buildHealthData(
    BuildContext context,
    HealthSummary summary,
    AsyncValue<DateTime?> lastSyncAsync,
    bool isRefreshing,
    WidgetRef ref,
  ) {
    final healthService = ref.read(healthServiceProvider);
    final currentSource = healthService.getCurrentSource();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                _buildSourceIndicator(currentSource),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                lastSyncAsync.when(
                  data: (timestamp) => Text(
                    _formatLastSyncCompact(timestamp),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: isRefreshing
                          ? SizedBox(
                              key: const ValueKey('refreshing'),
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey('idle'),
                              width: 14,
                              height: 14,
                            ),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.refresh, color: AppColors.white, size: 20),
                      onPressed: () async {
                        ref
                            .read(_dashboardRefreshingProvider.notifier)
                            .state = true;
                        try {
                          await ref.read(healthSyncProvider.future);
                          await ref
                              .read(healthSummaryProvider.notifier)
                              .refresh(force: true);
                        } finally {
                          ref
                              .read(_dashboardRefreshingProvider.notifier)
                              .state = false;
                        }
                      },
                      tooltip: 'Refresh health data',
                    ),
                  ],
                ),
              ],
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
                  value: summary.distanceKm.toStringAsFixed(1),
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
                      ? summary.averageHeartRate!.toInt().toString()
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
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
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
              color: AppColors.white.withValues(alpha: 0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No health data available yet',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Stay active and check back later!',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
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
            const Icon(Icons.health_and_safety, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Health Integration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Track your daily activity, sleep, and more!',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.9),
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
              await ref.read(healthSyncProvider.future);
              await ref
                  .read(healthSummaryProvider.notifier)
                  .refresh(force: true);
            }
          },
          icon: Icon(Icons.lock_open, size: 18),
          label: const Text('Enable Health Sync'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
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
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
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
            Icon(Icons.error_outline, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Health Data Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Unable to load health data',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            ref.read(healthSummaryProvider.notifier).refresh(force: true);
          },
          icon: const Icon(Icons.refresh, color: AppColors.white, size: 18),
          label: const Text(
            'Try Again',
            style: TextStyle(color: AppColors.white),
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

  String _formatLastSyncCompact(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Updated: --';
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Updated: now';
    }
    if (difference.inMinutes < 60) {
      return 'Updated: ${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return 'Updated: ${difference.inHours}h';
    }
    return 'Updated: ${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
  }

  Widget _buildSourceIndicator(HealthDataSource source) {
    IconData icon;
    String label;

    switch (source) {
      case HealthDataSource.appleHealth:
        icon = Icons.apple;
        label = 'Apple';
        break;
      case HealthDataSource.googleFit:
        icon = Icons.fitness_center;
        label = 'Fit';
        break;
      case HealthDataSource.manual:
        icon = Icons.edit;
        label = 'Manual';
        break;
      case HealthDataSource.unknown:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
