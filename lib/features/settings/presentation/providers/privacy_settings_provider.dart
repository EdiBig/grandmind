import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../user/data/services/firestore_service.dart';
import '../../domain/models/privacy_settings.dart';

final privacySettingsProvider = Provider<AsyncValue<PrivacySettings>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => AsyncValue.data(
      PrivacySettings.fromPreferences(user?.preferences),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class PrivacySettingsOperations extends StateNotifier<AsyncValue<void>> {
  PrivacySettingsOperations(this._firestoreService) : super(const AsyncValue.data(null));

  final FirestoreService _firestoreService;

  Future<void> updateSetting(String key, bool value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateUser(userId, {
        'preferences.privacy.$key': value,
      });

      if (key == 'allowCrashReports') {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(value);
      }

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final privacySettingsOperationsProvider =
    StateNotifierProvider<PrivacySettingsOperations, AsyncValue<void>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return PrivacySettingsOperations(firestore);
});
