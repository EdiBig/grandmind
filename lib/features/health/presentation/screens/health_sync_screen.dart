import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/health_providers.dart';

class HealthSyncScreen extends ConsumerStatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  ConsumerState<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends ConsumerState<HealthSyncScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(healthPermissionsProvider);
    final healthConnectStatusAsync = ref.watch(healthConnectStatusProvider);
    final lastSyncAsync = ref.watch(lastHealthSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          permissionsAsync.when(
            data: (hasPermissions) => _buildStatusCard(
              context,
              hasPermissions,
              healthConnectStatusAsync,
            ),
            loading: () => _buildLoadingCard(),
            error: (_, __) => _buildStatusCard(
              context,
              false,
              healthConnectStatusAsync,
            ),
          ),
          const SizedBox(height: 16),
          _buildLastSyncCard(context, lastSyncAsync),
          const SizedBox(height: 16),
          _buildDataTypesCard(context),
          const SizedBox(height: 16),
          _buildTroubleshootingCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool hasPermissions,
    AsyncValue<HealthConnectSdkStatus?> healthConnectStatusAsync,
  ) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final showHealthConnectCTA =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final healthConnectStatus = healthConnectStatusAsync.asData?.value;
    final canRequest = !_isRequesting;
    final isWeb = kIsWeb;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPermissions ? Icons.check_circle : Icons.lock_outline,
                color: hasPermissions ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                hasPermissions
                    ? 'Health access granted'
                    : isWeb
                        ? 'Health sync unavailable on web'
                        : 'Health access required',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasPermissions
                ? _connectedCopy()
                : isWeb
                    ? 'Health Connect and Apple Health require a mobile device. '
                        'Open this screen on Android or iOS to connect.'
                    : _disconnectedCopy(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (!hasPermissions && !isWeb)
            ElevatedButton.icon(
              onPressed: canRequest
                  ? () => _handleGrantAccess(
                        context,
                        showHealthConnectCTA,
                      )
                  : null,
              icon: _isRequesting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.lock_open),
              label: Text(_isRequesting ? 'Requesting...' : 'Grant Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else if (hasPermissions)
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(healthSyncProvider.future);
                await ref
                    .read(healthSummaryProvider.notifier)
                    .refresh(force: true);
                if (context.mounted) {
                  ref.invalidate(lastHealthSyncProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Health sync completed')),
                  );
                }
              },
              icon: Icon(Icons.sync),
              label: const Text('Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          if (showHealthConnectCTA && healthConnectStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                healthConnectStatus == HealthConnectSdkStatus.sdkAvailable
                    ? 'Health Connect is ready.'
                    : healthConnectStatus ==
                            HealthConnectSdkStatus
                                .sdkUnavailableProviderUpdateRequired
                        ? 'Health Connect needs an update.'
                        : 'Health Connect is unavailable on this device.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          if (showHealthConnectCTA)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: healthConnectStatusAsync.when(
                data: (status) {
                  if (status == null ||
                      status == HealthConnectSdkStatus.sdkAvailable) {
                    return OutlinedButton.icon(
                      onPressed: () async {
                        final opened = await ref
                            .read(healthServiceProvider)
                            .openHealthConnectSettings();
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to open Health Connect settings. Opened Play Store instead.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.settings),
                      label: const Text('Manage Permissions'),
                    );
                  }
                  return OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(healthServiceProvider).installHealthConnect();
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Install Health Connect'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLastSyncCard(BuildContext context, AsyncValue<DateTime?> lastSyncAsync) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: lastSyncAsync.when(
              data: (timestamp) {
                final text = timestamp == null
                    ? 'Never synced'
                    : 'Last synced: ${_formatTimestamp(timestamp)}';
                return Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
              loading: () => const Text('Checking last sync...'),
              error: (_, __) => const Text('Unable to read last sync time'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypesCard(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synced Data Types',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Read: steps, distance, calories, heart rate, sleep, workouts. Write: workouts, weight.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          const _DataTypeRow(icon: Icons.directions_walk, label: 'Steps'),
          const _DataTypeRow(icon: Icons.straighten, label: 'Distance'),
          const _DataTypeRow(icon: Icons.local_fire_department, label: 'Active calories'),
          const _DataTypeRow(icon: Icons.favorite, label: 'Heart rate'),
          const _DataTypeRow(icon: Icons.bedtime, label: 'Sleep'),
          const _DataTypeRow(icon: Icons.monitor_weight, label: 'Weight'),
          const _DataTypeRow(icon: Icons.fitness_center, label: 'Workouts'),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingCard(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Troubleshooting',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If data looks missing, open your health app and ensure permissions are enabled. You may need to reconnect after OS updates.',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _handleGrantAccess(
    BuildContext context,
    bool showHealthConnectCTA,
  ) async {
    setState(() => _isRequesting = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Requesting health access...'),
        duration: Duration(seconds: 2),
      ),
    );
    final healthService = ref.read(healthServiceProvider);
    try {
      if (showHealthConnectCTA) {
        final status = await healthService.getHealthConnectStatus();
        if (status == HealthConnectSdkStatus.sdkUnavailable) {
          await healthService.installHealthConnect();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health Connect is unavailable on this device.'),
            ),
          );
          return;
        }
        if (status ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          await healthService.installHealthConnect();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Health Connect needs an update. Update it and try again.',
              ),
            ),
          );
          return;
        }
      }

      final granted = await healthService.requestAuthorization();
      if (!context.mounted) return;
      if (granted) {
        ref.invalidate(healthPermissionsProvider);
        await ref.read(healthSyncProvider.future);
        await ref
            .read(healthSummaryProvider.notifier)
            .refresh(force: true);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health access granted')),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Health access not granted. Make sure Health Connect is installed and permissions are enabled.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to request health permissions. Try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  String _connectedCopy() {
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS) {
      return 'Connected to Apple Health. We read your data and can write back workouts and weight.';
    }
    if (platform == TargetPlatform.android) {
      return 'Connected to Health Connect. We read your data and can write back workouts and weight.';
    }
    return 'Health sync connected.';
  }

  String _disconnectedCopy() {
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS) {
      return 'Connect Apple Health to sync steps, sleep, heart rate, and workouts.';
    }
    if (platform == TargetPlatform.android) {
      return 'Connect Health Connect to sync steps, sleep, heart rate, and workouts.';
    }
    return 'Connect your health data to sync steps, sleep, heart rate, and workouts.';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}

class _DataTypeRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DataTypeRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
