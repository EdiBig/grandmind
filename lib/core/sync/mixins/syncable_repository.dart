import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sync_record.dart';
import '../services/local_database_service.dart';
import '../services/sync_service.dart';

/// Mixin to add offline-first sync capabilities to repositories
mixin SyncableRepository {
  /// Must be implemented by the repository
  String get collectionName;

  /// Reference to the sync service
  SyncService get syncService;

  /// Reference to the local database
  LocalDatabaseService get localDb;

  /// Reference to Firestore
  FirebaseFirestore get firestore;

  /// Save data with offline support
  /// Returns the document ID
  Future<String> saveWithSync({
    required String? documentId,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    final id = documentId ?? firestore.collection(collectionName).doc().id;

    // Add user ID and timestamps
    final enrichedData = {
      ...data,
      'id': id,
      'userId': userId,
      'updatedAt': DateTime.now().toIso8601String(),
      'clientId': localDb.clientId,
    };

    // Queue for sync (handles both local cache and sync queue)
    await syncService.queueChange(
      collection: collectionName,
      documentId: id,
      data: enrichedData,
    );

    return id;
  }

  /// Delete data with offline support
  Future<void> deleteWithSync({
    required String documentId,
    required String userId,
  }) async {
    await syncService.queueChange(
      collection: collectionName,
      documentId: documentId,
      data: {'userId': userId},
      isDelete: true,
    );
  }

  /// Get data with offline fallback
  /// First tries Firestore, falls back to local cache if offline
  Future<Map<String, dynamic>?> getWithFallback(String documentId) async {
    try {
      // Try Firestore first
      if (await syncService.isOnline()) {
        final doc = await firestore.collection(collectionName).doc(documentId).get();

        if (doc.exists) {
          final data = doc.data()!;
          // Update local cache
          await localDb.cacheData(collectionName, documentId, {
            ...data,
            'id': doc.id,
          });
          return {...data, 'id': doc.id};
        }
      }
    } catch (_) {
      // Fall through to local cache
    }

    // Try local cache
    return localDb.getCachedData(collectionName, documentId);
  }

  /// Get list of data with offline fallback
  Future<List<Map<String, dynamic>>> getListWithFallback({
    required String userId,
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      if (await syncService.isOnline()) {
        Query query = firestore
            .collection(collectionName)
            .where('userId', isEqualTo: userId);

        if (queryBuilder != null) {
          query = queryBuilder(query);
        }

        final snapshot = await query.get();
        final results = <Map<String, dynamic>>[];

        for (final doc in snapshot.docs) {
          final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
          results.add(data);
          // Update local cache
          await localDb.cacheData(collectionName, doc.id, data);
        }

        return results;
      }
    } catch (_) {
      // Fall through to local cache
    }

    // Try local cache
    final cached = await localDb.getCachedCollection(collectionName);
    return cached.where((item) => item['userId'] == userId).toList();
  }

  /// Stream data with local cache updates
  Stream<List<Map<String, dynamic>>> streamWithCache({
    required String userId,
    Query Function(Query)? queryBuilder,
  }) {
    Query query = firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final results = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
        results.add(data);
        // Update local cache in background
        localDb.cacheData(collectionName, doc.id, data);
      }

      return results;
    });
  }

  /// Check if there are pending changes for this collection
  Future<bool> hasPendingChanges() async {
    final records = await localDb.getPendingRecords();
    return records.any((r) => r.collection == collectionName);
  }

  /// Check if there are conflicts for this collection
  Future<List<SyncRecord>> getCollectionConflicts() async {
    final conflicts = await localDb.getConflictRecords();
    return conflicts.where((r) => r.collection == collectionName).toList();
  }
}

/// Extension to convert Firestore documents to maps with ID
extension DocumentSnapshotExtension on DocumentSnapshot {
  Map<String, dynamic> toMapWithId() {
    final data = this.data() as Map<String, dynamic>?;
    if (data == null) return {'id': id};
    return {...data, 'id': id};
  }
}

/// Provider helper for creating syncable repository dependencies
class SyncableRepositoryDeps {
  final SyncService syncService;
  final LocalDatabaseService localDb;
  final FirebaseFirestore firestore;

  SyncableRepositoryDeps({
    required this.syncService,
    required this.localDb,
    required this.firestore,
  });
}

/// Provider for syncable repository dependencies
final syncableRepositoryDepsProvider = Provider<SyncableRepositoryDeps>((ref) {
  return SyncableRepositoryDeps(
    syncService: ref.watch(syncServiceProvider),
    localDb: ref.watch(localDatabaseServiceProvider),
    firestore: FirebaseFirestore.instance,
  );
});
