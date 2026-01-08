import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_providers.dart';

class HealthSyncScreen extends ConsumerWidget {
  const HealthSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(healthPermissionsProvider);
    final lastSyncAsync = ref.watch(lastHealthSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          permissionsAsync.when(
            data: (hasPermissions) => _buildStatusCard(context, ref, hasPermissions),
            loading: () => _buildLoadingCard(),
            error: (_, __) => _buildStatusCard(context, ref, false),
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

  Widget _buildStatusCard(BuildContext context, WidgetRef ref, bool hasPermissions) {
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
          Row(
            children: [
              Icon(
                hasPermissions ? Icons.check_circle : Icons.lock_outline,
                color: hasPermissions ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                hasPermissions ? 'Health access granted' : 'Health access required',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasPermissions
                ? 'We can read your health data to keep your dashboard updated.'
                : 'Grant access to sync steps, sleep, heart rate, and workouts.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (!hasPermissions)
            ElevatedButton.icon(
              onPressed: () async {
                final healthService = ref.read(healthServiceProvider);
                final granted = await healthService.requestAuthorization();
                if (!context.mounted) return;
                if (granted) {
                  ref.invalidate(healthPermissionsProvider);
                  ref.invalidate(todayHealthSummaryProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Health access granted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Health access not granted. Make sure Health Connect is installed and permissions are enabled.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(healthSyncProvider.future);
                if (context.mounted) {
                  ref.invalidate(lastHealthSyncProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Health sync completed')),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      ),
    );
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
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
