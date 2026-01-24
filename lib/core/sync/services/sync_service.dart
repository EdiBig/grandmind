import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/sync_record.dart';
import 'local_database_service.dart';

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final localDb = ref.watch(localDatabaseServiceProvider);
  return SyncService(localDb: localDb);
});

/// Stream provider for connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider for sync status
final syncStatusProvider = StateProvider<SyncServiceStatus>((ref) {
  return SyncServiceStatus.idle;
});

/// Provider for pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final stats = await syncService.getSyncStats();
  return stats['pending'] ?? 0;
});

/// Provider for conflict count
final conflictCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  final stats = await syncService.getSyncStats();
  return stats['conflict'] ?? 0;
});

enum SyncServiceStatus {
  idle,
  syncing,
  offline,
  error,
}

/// Main sync service for offline-first data management
class SyncService {
  SyncService({
    required LocalDatabaseService localDb,
    FirebaseFirestore? firestore,
  })  : _localDb = localDb,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final LocalDatabaseService _localDb;
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  bool _isOnline = true;
  Timer? _retryTimer;

  static const int _maxRetries = 3;
  static const Duration _syncDebounce = Duration(seconds: 2);

  ConflictResolutionStrategy defaultStrategy = ConflictResolutionStrategy.preferNewest;

  /// Initialise the sync service
  Future<void> initialise() async {
    await _localDb.initialise();
    _startConnectivityMonitoring();
    _logger.i('SyncService initialised');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _logger.i('SyncService disposed');
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) async {
        final wasOffline = !_isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        _logger.d('Connectivity changed: $_isOnline (results: $results)');

        if (_isOnline && wasOffline) {
          _logger.i('Back online - triggering sync');
          // Debounce to avoid rapid sync attempts
          _retryTimer?.cancel();
          _retryTimer = Timer(_syncDebounce, () => syncPendingChanges());
        }
      },
    );
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    return _isOnline;
  }

  /// Queue a local change for sync
  Future<void> queueChange({
    required String collection,
    required String? documentId,
    required Map<String, dynamic> data,
    bool isDelete = false,
  }) async {
    final id = documentId ?? _uuid.v4();
    final now = DateTime.now();

    final record = SyncRecord(
      id: id,
      collection: collection,
      data: {
        ...data,
        'id': id,
        'updatedAt': now.toIso8601String(),
        'clientId': _localDb.clientId,
      },
      status: SyncStatus.pending,
      localUpdatedAt: now,
      clientId: _localDb.clientId,
      isDeleted: isDelete,
    );

    await _localDb.addToSyncQueue(record);

    // Also cache locally for immediate reading
    if (!isDelete) {
      await _localDb.cacheData(collection, id, record.data);
    } else {
      await _localDb.removeCachedData(collection, id);
    }

    _logger.d('Queued change for $collection/$id (delete: $isDelete)');

    // Try to sync immediately if online
    if (await isOnline()) {
      unawaited(syncPendingChanges());
    }
  }

  /// Sync all pending changes to Firestore
  Future<SyncResult> syncPendingChanges() async {
    if (_isSyncing) {
      _logger.d('Sync already in progress, skipping');
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        conflictCount: 0,
        message: 'Sync already in progress',
      );
    }

    if (!await isOnline()) {
      _logger.d('Offline, skipping sync');
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        conflictCount: 0,
        message: 'Device is offline',
      );
    }

    _isSyncing = true;
    int syncedCount = 0;
    int failedCount = 0;
    int conflictCount = 0;

    try {
      final pendingRecords = await _localDb.getPendingRecords();
      _logger.i('Starting sync of ${pendingRecords.length} pending records');

      for (final record in pendingRecords) {
        try {
          final result = await _syncRecord(record);

          switch (result) {
            case SyncRecordResult.success:
              syncedCount++;
            case SyncRecordResult.conflict:
              conflictCount++;
            case SyncRecordResult.failed:
              failedCount++;
          }
        } catch (e, stack) {
          _logger.e(
            'Failed to sync record ${record.collection}/${record.id}',
            error: e,
            stackTrace: stack,
          );
          failedCount++;

          // Update retry count
          final updatedRecord = record.copyWith(
            status: SyncStatus.failed,
            retryCount: (record.retryCount ?? 0) + 1,
            errorMessage: e.toString(),
          );
          await _localDb.updateSyncRecord(updatedRecord);
        }
      }

      // Clean up synced records
      await _localDb.clearSyncedRecords();

      _logger.i(
        'Sync complete: $syncedCount synced, $failedCount failed, $conflictCount conflicts',
      );

      return SyncResult(
        success: failedCount == 0 && conflictCount == 0,
        syncedCount: syncedCount,
        failedCount: failedCount,
        conflictCount: conflictCount,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single record
  Future<SyncRecordResult> _syncRecord(SyncRecord record) async {
    final ref = _firestore.collection(record.collection).doc(record.id);

    if (record.isDeleted) {
      return _syncDelete(record, ref);
    }

    return _syncUpsert(record, ref);
  }

  /// Sync a delete operation
  Future<SyncRecordResult> _syncDelete(
    SyncRecord record,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      final serverDoc = await ref.get();

      if (!serverDoc.exists) {
        // Already deleted on server
        await _markSynced(record, 'delete');
        return SyncRecordResult.success;
      }

      final serverData = serverDoc.data()!;
      final serverUpdatedAt = _parseTimestamp(serverData['updatedAt']);

      // Check if server has newer changes
      if (serverUpdatedAt != null &&
          serverUpdatedAt.isAfter(record.localUpdatedAt)) {
        // Server has newer data - conflict
        return _handleConflict(record, serverData);
      }

      // Safe to delete
      await ref.delete();
      await _markSynced(record, 'delete');
      return SyncRecordResult.success;
    } catch (e) {
      _logger.e('Delete sync failed for ${record.id}', error: e);
      rethrow;
    }
  }

  /// Sync an upsert (create/update) operation
  Future<SyncRecordResult> _syncUpsert(
    SyncRecord record,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      final serverDoc = await ref.get();

      if (!serverDoc.exists) {
        // New document - just create it
        await ref.set({
          ...record.data,
          'updatedAt': FieldValue.serverTimestamp(),
          'clientId': record.clientId,
        });
        await _markSynced(record, 'create');
        return SyncRecordResult.success;
      }

      // Document exists - check for conflicts
      final serverData = serverDoc.data()!;
      final serverUpdatedAt = _parseTimestamp(serverData['updatedAt']);
      final serverClientId = serverData['clientId'] as String?;

      // Same client updated - just overwrite
      if (serverClientId == record.clientId) {
        await ref.set({
          ...record.data,
          'updatedAt': FieldValue.serverTimestamp(),
          'clientId': record.clientId,
        }, SetOptions(merge: true));
        await _markSynced(record, 'update');
        return SyncRecordResult.success;
      }

      // Different client - check timestamps
      if (serverUpdatedAt != null &&
          serverUpdatedAt.isAfter(record.localUpdatedAt)) {
        // Server has newer data from another client
        return _handleConflict(record, serverData);
      }

      // Local is newer - safe to overwrite
      await ref.set({
        ...record.data,
        'updatedAt': FieldValue.serverTimestamp(),
        'clientId': record.clientId,
      }, SetOptions(merge: true));
      await _markSynced(record, 'update');
      return SyncRecordResult.success;
    } catch (e) {
      _logger.e('Upsert sync failed for ${record.id}', error: e);
      rethrow;
    }
  }

  /// Handle a conflict based on the resolution strategy
  Future<SyncRecordResult> _handleConflict(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    _logger.w(
      'Conflict detected for ${localRecord.collection}/${localRecord.id}',
    );

    switch (defaultStrategy) {
      case ConflictResolutionStrategy.preferLocal:
        return _resolvePreferLocal(localRecord, serverData);

      case ConflictResolutionStrategy.preferServer:
        return _resolvePreferServer(localRecord, serverData);

      case ConflictResolutionStrategy.preferNewest:
        return _resolvePreferNewest(localRecord, serverData);

      case ConflictResolutionStrategy.fieldMerge:
        return _resolveFieldMerge(localRecord, serverData);

      case ConflictResolutionStrategy.manualPrompt:
        return _markAsConflict(localRecord, serverData);
    }
  }

  Future<SyncRecordResult> _resolvePreferLocal(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    final ref = _firestore.collection(localRecord.collection).doc(localRecord.id);

    await ref.set({
      ...localRecord.data,
      'updatedAt': FieldValue.serverTimestamp(),
      'clientId': localRecord.clientId,
    }, SetOptions(merge: true));

    await _logConflictResolution(
      localRecord,
      serverData,
      'preferLocal',
      localRecord.data,
    );
    await _markSynced(localRecord, 'conflict_resolved');

    return SyncRecordResult.success;
  }

  Future<SyncRecordResult> _resolvePreferServer(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    // Update local cache with server data
    await _localDb.cacheData(
      localRecord.collection,
      localRecord.id,
      serverData,
    );

    await _logConflictResolution(
      localRecord,
      serverData,
      'preferServer',
      serverData,
    );
    await _markSynced(localRecord, 'conflict_resolved');

    return SyncRecordResult.success;
  }

  Future<SyncRecordResult> _resolvePreferNewest(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    final serverUpdatedAt = _parseTimestamp(serverData['updatedAt']);

    if (serverUpdatedAt != null &&
        serverUpdatedAt.isAfter(localRecord.localUpdatedAt)) {
      return _resolvePreferServer(localRecord, serverData);
    } else {
      return _resolvePreferLocal(localRecord, serverData);
    }
  }

  Future<SyncRecordResult> _resolveFieldMerge(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    // Merge non-conflicting fields
    final merged = <String, dynamic>{...serverData};
    final localData = localRecord.data;

    // Fields that should always come from local (user intent)
    final localPriorityFields = ['updatedAt', 'clientId'];

    for (final entry in localData.entries) {
      final key = entry.key;
      final localValue = entry.value;
      final serverValue = serverData[key];

      // Skip metadata fields
      if (localPriorityFields.contains(key)) continue;

      // If field doesn't exist on server, use local
      if (!serverData.containsKey(key)) {
        merged[key] = localValue;
        continue;
      }

      // If values are the same, no conflict
      if (localValue == serverValue) continue;

      // For nested maps, attempt deep merge
      if (localValue is Map && serverValue is Map) {
        merged[key] = _deepMerge(
          Map<String, dynamic>.from(serverValue),
          Map<String, dynamic>.from(localValue),
        );
        continue;
      }

      // For lists, combine unique items
      if (localValue is List && serverValue is List) {
        merged[key] = {...serverValue, ...localValue}.toList();
        continue;
      }

      // For primitive conflicts, prefer local (most recent user action)
      merged[key] = localValue;
    }

    // Write merged result
    final ref = _firestore.collection(localRecord.collection).doc(localRecord.id);
    await ref.set({
      ...merged,
      'updatedAt': FieldValue.serverTimestamp(),
      'clientId': localRecord.clientId,
    });

    // Update local cache
    await _localDb.cacheData(localRecord.collection, localRecord.id, merged);

    await _logConflictResolution(localRecord, serverData, 'fieldMerge', merged);
    await _markSynced(localRecord, 'conflict_resolved');

    return SyncRecordResult.success;
  }

  Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> overlay,
  ) {
    final result = Map<String, dynamic>.from(base);

    for (final entry in overlay.entries) {
      final key = entry.key;
      final overlayValue = entry.value;
      final baseValue = base[key];

      if (overlayValue is Map && baseValue is Map) {
        result[key] = _deepMerge(
          Map<String, dynamic>.from(baseValue),
          Map<String, dynamic>.from(overlayValue),
        );
      } else {
        result[key] = overlayValue;
      }
    }

    return result;
  }

  Future<SyncRecordResult> _markAsConflict(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
  ) async {
    final updatedRecord = localRecord.copyWith(
      status: SyncStatus.conflict,
      serverUpdatedAt: _parseTimestamp(serverData['updatedAt']),
    );

    await _localDb.updateSyncRecord(updatedRecord);
    await _logConflictResolution(
      localRecord,
      serverData,
      'manualPrompt',
      null,
    );

    return SyncRecordResult.conflict;
  }

  Future<void> _markSynced(SyncRecord record, String action) async {
    final updatedRecord = record.copyWith(status: SyncStatus.synced);
    await _localDb.updateSyncRecord(updatedRecord);

    await _localDb.addToSyncHistory(
      SyncHistoryEntry(
        id: _uuid.v4(),
        recordId: record.id,
        collection: record.collection,
        action: action,
        timestamp: DateTime.now(),
        previousStatus: record.status,
        newStatus: SyncStatus.synced,
      ),
    );
  }

  Future<void> _logConflictResolution(
    SyncRecord localRecord,
    Map<String, dynamic> serverData,
    String strategy,
    Map<String, dynamic>? resolvedData,
  ) async {
    await _localDb.addToSyncHistory(
      SyncHistoryEntry(
        id: _uuid.v4(),
        recordId: localRecord.id,
        collection: localRecord.collection,
        action: 'conflict_resolved',
        timestamp: DateTime.now(),
        previousStatus: localRecord.status,
        newStatus: SyncStatus.synced,
        localData: localRecord.data,
        serverData: serverData,
        resolutionStrategy: strategy,
      ),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Manually resolve a conflict
  Future<void> resolveConflict({
    required String collection,
    required String id,
    required Map<String, dynamic> resolvedData,
  }) async {
    final record = await _localDb.getSyncRecord(collection, id);
    if (record == null || record.status != SyncStatus.conflict) {
      throw StateError('No conflict found for $collection/$id');
    }

    final ref = _firestore.collection(collection).doc(id);
    await ref.set({
      ...resolvedData,
      'updatedAt': FieldValue.serverTimestamp(),
      'clientId': _localDb.clientId,
    });

    // Update local cache
    await _localDb.cacheData(collection, id, resolvedData);
    await _markSynced(record, 'manual_resolution');

    _logger.i('Manually resolved conflict for $collection/$id');
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    return _localDb.getSyncQueueStats();
  }

  /// Get all conflicts for manual resolution
  Future<List<SyncRecord>> getConflicts() async {
    return _localDb.getConflictRecords();
  }

  /// Get sync history for GDPR export
  Future<List<SyncHistoryEntry>> exportSyncHistory() async {
    return _localDb.getAllSyncHistory();
  }

  /// Force retry failed syncs
  Future<void> retryFailedSyncs() async {
    final pendingRecords = await _localDb.getPendingRecords();

    for (final record in pendingRecords) {
      if (record.status == SyncStatus.failed &&
          (record.retryCount ?? 0) < _maxRetries) {
        final resetRecord = record.copyWith(
          status: SyncStatus.pending,
        );
        await _localDb.updateSyncRecord(resetRecord);
      }
    }

    await syncPendingChanges();
  }

  /// Clear all sync data (for logout)
  Future<void> clearAll() async {
    await _localDb.clearAllCaches();
    _logger.i('Cleared all sync data');
  }
}

enum SyncRecordResult {
  success,
  conflict,
  failed,
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final String? message;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.conflictCount,
    this.message,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, synced: $syncedCount, failed: $failedCount, conflicts: $conflictCount)';
  }
}
