import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

import 'services/local_database_service.dart';
import 'services/sync_service.dart';

/// Background task name for periodic sync
const String syncBackgroundTask = 'com.kinesa.backgroundSync';

/// Initialises the sync module
class SyncInitialiser {
  static final Logger _logger = Logger();
  static bool _isInitialised = false;

  /// Initialise the sync module
  /// Call this in main.dart before runApp()
  static Future<void> initialise() async {
    if (_isInitialised) {
      _logger.w('SyncInitialiser already initialised');
      return;
    }

    try {
      // Initialise Hive
      await Hive.initFlutter();
      _logger.i('Hive initialised');

      // Initialise Workmanager for background sync
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: false,
      );
      _logger.i('Workmanager initialised');

      _isInitialised = true;
      _logger.i('SyncInitialiser completed');
    } catch (e, stack) {
      _logger.e('Failed to initialise sync module', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Register periodic background sync
  /// Call this after user login
  static Future<void> registerBackgroundSync({
    Duration frequency = const Duration(hours: 1),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        syncBackgroundTask,
        syncBackgroundTask,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      _logger.i('Background sync registered with frequency: $frequency');
    } catch (e) {
      _logger.w('Failed to register background sync', error: e);
    }
  }

  /// Cancel background sync
  /// Call this on user logout
  static Future<void> cancelBackgroundSync() async {
    try {
      await Workmanager().cancelByUniqueName(syncBackgroundTask);
      _logger.i('Background sync cancelled');
    } catch (e) {
      _logger.w('Failed to cancel background sync', error: e);
    }
  }
}

/// Workmanager callback dispatcher
/// This runs in a separate isolate
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final logger = Logger();

    try {
      logger.i('Background sync started: $task');

      // Initialise Hive in the background isolate
      await Hive.initFlutter();

      // Create local database service
      final localDb = LocalDatabaseService();
      await localDb.initialise();

      // Create sync service
      final syncService = SyncService(localDb: localDb);

      // Perform sync
      final result = await syncService.syncPendingChanges();
      logger.i('Background sync completed: $result');

      return true;
    } catch (e, stack) {
      logger.e('Background sync failed', error: e, stackTrace: stack);
      return false;
    }
  });
}

/// Extension on ProviderContainer for initialising sync services
extension SyncProviderContainerExtension on ProviderContainer {
  /// Initialise sync services
  Future<void> initialiseSyncServices() async {
    final localDb = read(localDatabaseServiceProvider);
    await localDb.initialise();

    final syncService = read(syncServiceProvider);
    await syncService.initialise();
  }
}

/// Provider for sync initialisation status
final syncInitialisedProvider = FutureProvider<bool>((ref) async {
  final localDb = ref.watch(localDatabaseServiceProvider);
  await localDb.initialise();

  final syncService = ref.watch(syncServiceProvider);
  await syncService.initialise();

  return true;
});
