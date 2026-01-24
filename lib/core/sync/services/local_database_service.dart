import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/sync_record.dart';

/// Provider for LocalDatabaseService
final localDatabaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});

/// Service for managing local Hive database for offline-first data
class LocalDatabaseService {
  static const String _syncQueueBox = 'sync_queue';
  static const String _syncHistoryBox = 'sync_history';
  static const String _localCacheBox = 'local_cache';
  static const String _clientIdKey = 'client_id';

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  bool _isInitialised = false;
  late Box<Map> _syncQueueBoxInstance;
  late Box<Map> _syncHistoryBoxInstance;
  late Box<Map> _localCacheBoxInstance;
  late String _clientId;

  bool get isInitialised => _isInitialised;
  String get clientId => _clientId;

  /// Initialise Hive and register adapters
  Future<void> initialise() async {
    if (_isInitialised) return;

    try {
      // Register adapters
      if (!Hive.isAdapterRegistered(100)) {
        Hive.registerAdapter(SyncStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(101)) {
        Hive.registerAdapter(SyncRecordAdapter());
      }
      if (!Hive.isAdapterRegistered(102)) {
        Hive.registerAdapter(SyncHistoryEntryAdapter());
      }

      // Open boxes
      _syncQueueBoxInstance = await Hive.openBox<Map>(_syncQueueBox);
      _syncHistoryBoxInstance = await Hive.openBox<Map>(_syncHistoryBox);
      _localCacheBoxInstance = await Hive.openBox<Map>(_localCacheBox);

      // Generate or retrieve client ID
      _clientId = _localCacheBoxInstance.get(_clientIdKey)?['id'] as String? ??
          _uuid.v4();
      await _localCacheBoxInstance.put(_clientIdKey, {'id': _clientId});

      _isInitialised = true;
      _logger.i('LocalDatabaseService initialised with clientId: $_clientId');
    } catch (e, stack) {
      _logger.e('Failed to initialise LocalDatabaseService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Add a record to the sync queue
  Future<void> addToSyncQueue(SyncRecord record) async {
    _ensureInitialised();
    final key = '${record.collection}_${record.id}';
    await _syncQueueBoxInstance.put(key, record.toJson());
    _logger.d('Added to sync queue: $key');
  }

  /// Get all pending records from sync queue
  Future<List<SyncRecord>> getPendingRecords() async {
    _ensureInitialised();
    final records = <SyncRecord>[];

    for (final key in _syncQueueBoxInstance.keys) {
      final data = _syncQueueBoxInstance.get(key);
      if (data != null) {
        try {
          final record = SyncRecord.fromJson(Map<String, dynamic>.from(data));
          if (record.status == SyncStatus.pending ||
              record.status == SyncStatus.failed) {
            records.add(record);
          }
        } catch (e) {
          _logger.w('Failed to parse sync record: $key', error: e);
        }
      }
    }

    // Sort by localUpdatedAt (oldest first for FIFO processing)
    records.sort((a, b) => a.localUpdatedAt.compareTo(b.localUpdatedAt));
    return records;
  }

  /// Get all records with conflicts
  Future<List<SyncRecord>> getConflictRecords() async {
    _ensureInitialised();
    final records = <SyncRecord>[];

    for (final key in _syncQueueBoxInstance.keys) {
      final data = _syncQueueBoxInstance.get(key);
      if (data != null) {
        try {
          final record = SyncRecord.fromJson(Map<String, dynamic>.from(data));
          if (record.status == SyncStatus.conflict) {
            records.add(record);
          }
        } catch (e) {
          _logger.w('Failed to parse sync record: $key', error: e);
        }
      }
    }

    return records;
  }

  /// Get a specific record from sync queue
  Future<SyncRecord?> getSyncRecord(String collection, String id) async {
    _ensureInitialised();
    final key = '${collection}_$id';
    final data = _syncQueueBoxInstance.get(key);

    if (data == null) return null;

    try {
      return SyncRecord.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      _logger.w('Failed to parse sync record: $key', error: e);
      return null;
    }
  }

  /// Update a sync record
  Future<void> updateSyncRecord(SyncRecord record) async {
    _ensureInitialised();
    final key = '${record.collection}_${record.id}';
    await _syncQueueBoxInstance.put(key, record.toJson());
    _logger.d('Updated sync record: $key with status: ${record.status}');
  }

  /// Remove a record from sync queue (after successful sync)
  Future<void> removeFromSyncQueue(String collection, String id) async {
    _ensureInitialised();
    final key = '${collection}_$id';
    await _syncQueueBoxInstance.delete(key);
    _logger.d('Removed from sync queue: $key');
  }

  /// Clear all synced records from queue
  Future<void> clearSyncedRecords() async {
    _ensureInitialised();
    final keysToDelete = <dynamic>[];

    for (final key in _syncQueueBoxInstance.keys) {
      final data = _syncQueueBoxInstance.get(key);
      if (data != null) {
        try {
          final record = SyncRecord.fromJson(Map<String, dynamic>.from(data));
          if (record.status == SyncStatus.synced) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // Skip invalid records
        }
      }
    }

    for (final key in keysToDelete) {
      await _syncQueueBoxInstance.delete(key);
    }

    _logger.i('Cleared ${keysToDelete.length} synced records');
  }

  /// Add entry to sync history for audit logging
  Future<void> addToSyncHistory(SyncHistoryEntry entry) async {
    _ensureInitialised();
    final key = '${entry.collection}_${entry.recordId}_${entry.timestamp.millisecondsSinceEpoch}';
    await _syncHistoryBoxInstance.put(key, entry.toJson());

    // Keep history manageable - remove entries older than 30 days
    await _pruneOldHistory();
  }

  /// Get sync history for a specific record
  Future<List<SyncHistoryEntry>> getSyncHistory(
    String collection,
    String recordId,
  ) async {
    _ensureInitialised();
    final entries = <SyncHistoryEntry>[];
    final prefix = '${collection}_${recordId}_';

    for (final key in _syncHistoryBoxInstance.keys) {
      if (key.toString().startsWith(prefix)) {
        final data = _syncHistoryBoxInstance.get(key);
        if (data != null) {
          try {
            entries.add(SyncHistoryEntry.fromJson(Map<String, dynamic>.from(data)));
          } catch (e) {
            _logger.w('Failed to parse sync history: $key', error: e);
          }
        }
      }
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get all sync history entries (for GDPR export)
  Future<List<SyncHistoryEntry>> getAllSyncHistory() async {
    _ensureInitialised();
    final entries = <SyncHistoryEntry>[];

    for (final key in _syncHistoryBoxInstance.keys) {
      final data = _syncHistoryBoxInstance.get(key);
      if (data != null) {
        try {
          entries.add(SyncHistoryEntry.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          _logger.w('Failed to parse sync history: $key', error: e);
        }
      }
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Store data in local cache (for offline reading)
  Future<void> cacheData(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    _ensureInitialised();
    final key = '${collection}_$id';
    await _localCacheBoxInstance.put(key, {
      ...data,
      '_cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached data
  Future<Map<String, dynamic>?> getCachedData(
    String collection,
    String id,
  ) async {
    _ensureInitialised();
    final key = '${collection}_$id';
    final data = _localCacheBoxInstance.get(key);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all cached data for a collection
  Future<List<Map<String, dynamic>>> getCachedCollection(
    String collection,
  ) async {
    _ensureInitialised();
    final results = <Map<String, dynamic>>[];
    final prefix = '${collection}_';

    for (final key in _localCacheBoxInstance.keys) {
      if (key.toString().startsWith(prefix) && key != _clientIdKey) {
        final data = _localCacheBoxInstance.get(key);
        if (data != null) {
          results.add(Map<String, dynamic>.from(data));
        }
      }
    }

    return results;
  }

  /// Remove cached data
  Future<void> removeCachedData(String collection, String id) async {
    _ensureInitialised();
    final key = '${collection}_$id';
    await _localCacheBoxInstance.delete(key);
  }

  /// Clear all caches (for logout)
  Future<void> clearAllCaches() async {
    _ensureInitialised();
    await _syncQueueBoxInstance.clear();
    await _syncHistoryBoxInstance.clear();

    // Keep client ID, clear everything else
    final clientIdData = _localCacheBoxInstance.get(_clientIdKey);
    await _localCacheBoxInstance.clear();
    if (clientIdData != null) {
      await _localCacheBoxInstance.put(_clientIdKey, clientIdData);
    }

    _logger.i('Cleared all local caches');
  }

  /// Get sync queue stats
  Future<Map<String, int>> getSyncQueueStats() async {
    _ensureInitialised();
    int pending = 0;
    int synced = 0;
    int conflict = 0;
    int failed = 0;

    for (final key in _syncQueueBoxInstance.keys) {
      final data = _syncQueueBoxInstance.get(key);
      if (data != null) {
        try {
          final record = SyncRecord.fromJson(Map<String, dynamic>.from(data));
          switch (record.status) {
            case SyncStatus.pending:
              pending++;
            case SyncStatus.synced:
              synced++;
            case SyncStatus.conflict:
              conflict++;
            case SyncStatus.failed:
              failed++;
          }
        } catch (e) {
          // Skip invalid records
        }
      }
    }

    return {
      'pending': pending,
      'synced': synced,
      'conflict': conflict,
      'failed': failed,
      'total': pending + synced + conflict + failed,
    };
  }

  Future<void> _pruneOldHistory() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final keysToDelete = <dynamic>[];

    for (final key in _syncHistoryBoxInstance.keys) {
      final data = _syncHistoryBoxInstance.get(key);
      if (data != null) {
        try {
          final entry = SyncHistoryEntry.fromJson(Map<String, dynamic>.from(data));
          if (entry.timestamp.isBefore(cutoff)) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // Delete invalid entries
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _syncHistoryBoxInstance.delete(key);
    }

    if (keysToDelete.isNotEmpty) {
      _logger.d('Pruned ${keysToDelete.length} old history entries');
    }
  }

  void _ensureInitialised() {
    if (!_isInitialised) {
      throw StateError(
        'LocalDatabaseService not initialised. Call initialise() first.',
      );
    }
  }
}

/// Hive adapter for SyncStatus enum
class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 100;

  @override
  SyncStatus read(BinaryReader reader) {
    return SyncStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    writer.writeByte(obj.index);
  }
}
