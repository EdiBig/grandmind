/// Offline Sync & Conflict Resolution Module
///
/// This module provides offline-first data management with automatic
/// conflict resolution for the Kinesa app.
///
/// ## Usage
///
/// 1. Initialise in main.dart:
/// ```dart
/// await SyncInitialiser.initialise();
/// ```
///
/// 2. Add OfflineBanner to your app:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: yourContent),
///     ],
///   ),
/// )
/// ```
///
/// 3. Use SyncableRepository mixin in your repositories:
/// ```dart
/// class MyRepository with SyncableRepository {
///   @override
///   String get collectionName => 'my_collection';
///   // ...
/// }
/// ```

library sync;

// Models
export 'models/sync_record.dart';

// Services
export 'services/local_database_service.dart';
export 'services/sync_service.dart';

// Mixins
export 'mixins/syncable_repository.dart';

// Widgets
export 'widgets/offline_banner.dart';

// Initialiser
export 'sync_initialiser.dart';
