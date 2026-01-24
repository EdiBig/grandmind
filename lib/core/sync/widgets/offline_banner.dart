import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../models/sync_record.dart';
import '../services/sync_service.dart';

/// Banner that shows when the device is offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline = results.contains(ConnectivityResult.none);

        if (!isOffline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.warning,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: AppColors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re offline. Changes will sync when connected.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Indicator showing pending sync count
class SyncStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final Color? iconColor;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingSyncCountProvider);
    final conflictCountAsync = ref.watch(conflictCountProvider);
    final theme = Theme.of(context);

    return pendingCountAsync.when(
      data: (pendingCount) {
        final conflictCount = conflictCountAsync.valueOrNull ?? 0;

        if (pendingCount == 0 && conflictCount == 0) {
          return const SizedBox.shrink();
        }

        final hasConflicts = conflictCount > 0;
        final color = hasConflicts
            ? AppColors.error
            : iconColor ?? theme.colorScheme.primary;

        return InkWell(
          onTap: hasConflicts
              ? () => _showConflictDialog(context, ref)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      hasConflicts ? Icons.sync_problem : Icons.sync,
                      color: color,
                      size: 20,
                    ),
                    if (pendingCount > 0 || conflictCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${pendingCount + conflictCount}',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    hasConflicts
                        ? '$conflictCount conflict${conflictCount > 1 ? 's' : ''}'
                        : '$pendingCount pending',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showConflictDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ConflictResolutionDialog(),
    );
  }
}

/// Dialog for resolving sync conflicts
class ConflictResolutionDialog extends ConsumerStatefulWidget {
  const ConflictResolutionDialog({super.key});

  @override
  ConsumerState<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState
    extends ConsumerState<ConflictResolutionDialog> {
  List<SyncRecord>? _conflicts;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    final syncService = ref.read(syncServiceProvider);
    final conflicts = await syncService.getConflicts();
    setState(() {
      _conflicts = conflicts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return AlertDialog(
        title: const Text('Sync Conflicts'),
        content: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_conflicts == null || _conflicts!.isEmpty) {
      return AlertDialog(
        title: const Text('Sync Conflicts'),
        content: const Text('No conflicts to resolve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final conflict = _conflicts![_currentIndex];

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.sync_problem, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conflict ${_currentIndex + 1} of ${_conflicts!.length}',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Collection: ${conflict.collection}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'ID: ${conflict.id}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This record was modified both locally and on the server.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildDataPreview('Local Changes', conflict.data, theme),
            const SizedBox(height: 8),
            Text(
              'Local updated: ${_formatDateTime(conflict.localUpdatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (conflict.serverUpdatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Server updated: ${_formatDateTime(conflict.serverUpdatedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _resolveConflict(ConflictChoice.keepLocal),
          child: const Text('Keep Local'),
        ),
        TextButton(
          onPressed: () => _resolveConflict(ConflictChoice.keepServer),
          child: const Text('Keep Server'),
        ),
        FilledButton(
          onPressed: () => _resolveConflict(ConflictChoice.merge),
          child: const Text('Merge'),
        ),
      ],
    );
  }

  Widget _buildDataPreview(
    String title,
    Map<String, dynamic> data,
    ThemeData theme,
  ) {
    // Filter out metadata fields for display
    final displayData = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('userId')
      ..remove('updatedAt')
      ..remove('clientId')
      ..remove('createdAt');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...displayData.entries.take(5).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.key}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${e.value}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (displayData.length > 5)
            Text(
              '... and ${displayData.length - 5} more fields',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _resolveConflict(ConflictChoice choice) async {
    final conflict = _conflicts![_currentIndex];
    final syncService = ref.read(syncServiceProvider);

    try {
      Map<String, dynamic> resolvedData;

      switch (choice) {
        case ConflictChoice.keepLocal:
          resolvedData = conflict.data;
        case ConflictChoice.keepServer:
          // Fetch server data
          final doc = await FirebaseFirestore.instance
              .collection(conflict.collection)
              .doc(conflict.id)
              .get();
          resolvedData = doc.data() ?? conflict.data;
        case ConflictChoice.merge:
          // For merge, combine local and server data
          final doc = await FirebaseFirestore.instance
              .collection(conflict.collection)
              .doc(conflict.id)
              .get();
          final serverData = doc.data() ?? {};
          resolvedData = {...serverData, ...conflict.data};
      }

      await syncService.resolveConflict(
        collection: conflict.collection,
        id: conflict.id,
        resolvedData: resolvedData,
      );

      // Move to next conflict or close
      if (_currentIndex < _conflicts!.length - 1) {
        setState(() {
          _conflicts!.removeAt(_currentIndex);
        });
      } else {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All conflicts resolved'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      // Refresh providers
      ref.invalidate(pendingSyncCountProvider);
      ref.invalidate(conflictCountProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resolve conflict: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

enum ConflictChoice {
  keepLocal,
  keepServer,
  merge,
}

/// Toast notification for sync completion
class SyncCompleteToast extends StatelessWidget {
  final int syncedCount;
  final int failedCount;

  const SyncCompleteToast({
    super.key,
    required this.syncedCount,
    required this.failedCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = failedCount == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.success : AppColors.warning,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.cloud_done : Icons.cloud_sync,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isSuccess
                ? 'Sync complete ($syncedCount items)'
                : 'Sync partial: $syncedCount synced, $failedCount failed',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show sync complete toast
void showSyncCompleteToast(
  BuildContext context, {
  required int syncedCount,
  required int failedCount,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: SyncCompleteToast(
        syncedCount: syncedCount,
        failedCount: failedCount,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
