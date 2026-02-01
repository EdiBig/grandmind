import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/services/services.dart';

/// Unity settings repository provider
final unitySettingsRepositoryProvider =
    Provider<UnitySettingsRepository>((ref) {
  return UnitySettingsRepository();
});

/// Consent service provider
final consentServiceProvider = Provider<ConsentService>((ref) {
  final settingsRepo = ref.watch(unitySettingsRepositoryProvider);
  return ConsentService(settingsRepository: settingsRepo);
});

/// Age verification service provider
final ageVerificationServiceProvider = Provider<AgeVerificationService>((ref) {
  final settingsRepo = ref.watch(unitySettingsRepositoryProvider);
  return AgeVerificationService(settingsRepository: settingsRepo);
});

/// User's Unity settings stream
final unitySettingsProvider = StreamProvider<UnitySettings>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(UnitySettings.defaults(''));
  }

  final repo = ref.watch(unitySettingsRepositoryProvider);
  return repo.getSettingsStream(userId);
});

/// User's consents
final userConsentsProvider = StreamProvider<ConsentCollection>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(const ConsentCollection());
  }

  final repo = ref.watch(unitySettingsRepositoryProvider);
  return repo.getConsentsStream(userId);
});

/// Check if user has all required consents
final hasRequiredConsentsProvider = FutureProvider<bool>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;

  final consentService = ref.watch(consentServiceProvider);
  return consentService.hasRequiredConsents(userId);
});

/// Get missing required consents
final missingConsentsProvider = FutureProvider<List<ConsentType>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final consentService = ref.watch(consentServiceProvider);
  return consentService.getMissingConsents(userId);
});

/// Update settings notifier
class UpdateSettingsNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateSettingsNotifier(this._settingsRepo)
      : super(const AsyncValue.data(null));

  final UnitySettingsRepository _settingsRepo;

  Future<void> updateSetting(String key, dynamic value) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.updateSetting(userId, key, value);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.updateSettings(userId, updates);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> muteCircle(String circleId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.muteCircle(userId, circleId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unmuteCircle(String circleId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.unmuteCircle(userId, circleId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> muteChallenge(String challengeId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.muteChallenge(userId, challengeId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unmuteChallenge(String challengeId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.unmuteChallenge(userId, challengeId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> blockUser(String blockedUserId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.blockUser(userId, blockedUserId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _settingsRepo.unblockUser(userId, blockedUserId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final updateSettingsProvider =
    StateNotifierProvider<UpdateSettingsNotifier, AsyncValue<void>>((ref) {
  final settingsRepo = ref.watch(unitySettingsRepositoryProvider);
  return UpdateSettingsNotifier(settingsRepo);
});

/// Grant consent notifier
class GrantConsentNotifier extends StateNotifier<AsyncValue<void>> {
  GrantConsentNotifier(this._consentService)
      : super(const AsyncValue.data(null));

  final ConsentService _consentService;

  Future<void> grantConsent(
    ConsentType type, {
    String? challengeId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _consentService.grantConsent(
        userId: userId,
        type: type,
        challengeId: challengeId,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> revokeConsent(
    ConsentType type, {
    String? challengeId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _consentService.revokeConsent(
        userId: userId,
        type: type,
        challengeId: challengeId,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ConsentValidationResult> validateAndGrantConsents({
    required List<ConsentGrant> grants,
    String? challengeId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return const ConsentValidationResult(
          success: false,
          errors: ['Not authenticated'],
          grantedConsents: [],
        );
      }

      final result = await _consentService.validateAndGrantConsents(
        userId: userId,
        grants: grants,
        challengeId: challengeId,
      );

      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return ConsentValidationResult(
        success: false,
        errors: [e.toString()],
        grantedConsents: [],
      );
    }
  }
}

final grantConsentProvider =
    StateNotifierProvider<GrantConsentNotifier, AsyncValue<void>>((ref) {
  final consentService = ref.watch(consentServiceProvider);
  return GrantConsentNotifier(consentService);
});

/// Age verification notifier
class AgeVerificationNotifier extends StateNotifier<AsyncValue<AgeVerificationResult?>> {
  AgeVerificationNotifier(this._ageService)
      : super(const AsyncValue.data(null));

  final AgeVerificationService _ageService;

  AgeVerificationResult verifyAge(DateTime birthDate) {
    final result = _ageService.verifyAge(birthDate);
    state = AsyncValue.data(result);
    return result;
  }

  Future<void> recordVerification(DateTime birthDate) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _ageService.recordAgeVerification(
        userId: userId,
        birthDate: birthDate,
      );

      final result = _ageService.verifyAge(birthDate);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final ageVerificationProvider =
    StateNotifierProvider<AgeVerificationNotifier, AsyncValue<AgeVerificationResult?>>(
        (ref) {
  final ageService = ref.watch(ageVerificationServiceProvider);
  return AgeVerificationNotifier(ageService);
});

/// Is user blocked check
final isUserBlockedProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;

  final settingsRepo = ref.watch(unitySettingsRepositoryProvider);
  return settingsRepo.isUserBlocked(userId, targetUserId);
});
