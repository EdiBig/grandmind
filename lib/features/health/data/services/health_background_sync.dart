import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../firebase_options.dart';
import '../repositories/health_repository.dart';
import 'health_service.dart';

const String healthSyncTaskName = 'healthSyncTask';

@pragma('vm:entry-point')
void healthSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (!e.toString().contains('duplicate-app')) {
        rethrow;
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return true;
    }

    try {
      final healthService = HealthService();
      final repository = HealthRepository(healthService: healthService);
      await repository.syncTodayHealthData(user.uid);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_health_sync',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Best-effort background sync; ignore errors to avoid retry storms.
    }
    return true;
  });
}

Future<void> registerHealthBackgroundSync() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  await Workmanager().initialize(
    healthSyncCallbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  await Workmanager().registerPeriodicTask(
    'healthSyncTask',
    healthSyncTaskName,
    frequency: const Duration(hours: 6),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
