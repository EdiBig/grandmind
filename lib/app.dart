import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_presets.dart';
import 'features/health/presentation/providers/health_providers.dart';
import 'features/settings/presentation/providers/app_settings_provider.dart';
import 'features/notifications/data/services/notification_navigation.dart';
import 'features/home/presentation/providers/dashboard_provider.dart';
import 'features/profile/presentation/providers/profile_providers.dart';
import 'features/user/data/services/firestore_service.dart';
import 'features/user/data/models/user_model.dart';
import 'routes/app_router.dart';

class KinesaApp extends ConsumerStatefulWidget {
  const KinesaApp({super.key});

  @override
  ConsumerState<KinesaApp> createState() => _KinesaAppState();
}

class _KinesaAppState extends ConsumerState<KinesaApp>
    with WidgetsBindingObserver {
  static const Duration _resumeSyncThrottle = Duration(minutes: 15);
  bool _isSyncing = false;
  bool _profileMigrationAttempted = false;
  ProviderSubscription<AsyncValue<UserModel?>>? _currentUserSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigation.handlePendingNavigation();
    });
    _currentUserSub =
        ref.listenManual<AsyncValue<UserModel?>>(currentUserProvider,
            (previous, next) {
      if (_profileMigrationAttempted) return;
      final user = next.asData?.value;
      if (user == null) return;
      _profileMigrationAttempted = true;
      _migrateLegacyProfilePhoto(user);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentUserSub?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeSyncHealth();
    }
  }

  Future<void> _maybeSyncHealth() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final lastSync = await ref.read(lastHealthSyncProvider.future);
      if (lastSync != null &&
          DateTime.now().difference(lastSync) < _resumeSyncThrottle) {
        return;
      }
      await ref.read(healthSyncProvider.future);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _migrateLegacyProfilePhoto(UserModel user) async {
    try {
      final profilePhotoService = ref.read(profilePhotoServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final authUser = FirebaseAuth.instance.currentUser;
      final candidateUrl = user.photoUrl ?? authUser?.photoURL;
      final migratedUrl = await profilePhotoService.migrateLegacyProfilePhoto(
        userId: user.id,
        photoUrl: candidateUrl,
      );
      if (migratedUrl == null) return;

      await firestoreService.updateUser(user.id, {
        'photoUrl': migratedUrl,
        'photoURL': migratedUrl,
      });

      if (authUser != null) {
        await authUser.updatePhotoURL(migratedUrl);
      }
    } catch (_) {
      // Best-effort; ignore migration failures.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    final preset = ThemePresets.byId(settings.themePresetId);

    return MaterialApp.router(
      title: 'Kinesa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(
        preset: preset,
        brightness: Brightness.light,
      ),
      darkTheme: AppTheme.themeData(
        preset: preset,
        brightness: Brightness.dark,
      ),
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
