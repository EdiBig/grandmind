import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'firebase_options.dart';
import 'core/config/ai_config.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/ai/presentation/providers/ai_providers.dart';
import 'features/ai/presentation/providers/ai_coach_provider.dart';
import 'features/authentication/data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('AssetManifest.bin.json')) {
        return;
      }
      FlutterError.presentError(details);
    };
  }

  // Initialize Firebase (handle duplicate app error for hot restart)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized (hot restart case)
      debugPrint('Firebase already initialized, skipping re-initialization');
    } else {
      // Re-throw other errors
      rethrow;
    }
  }

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    await AuthRepository().handleWebRedirectResult();
  }

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  }

  // Initialize timezone database
  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize SharedPreferences for AI caching
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize AI Config (secure API key storage)
  await AIConfig.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider for AI caching
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),

        // Override AI Coach provider with actual implementation
        aiCoachProvider.overrideWith((ref) {
          final sendMessageUseCase = ref.watch(sendCoachMessageUseCaseProvider);
          final workoutRecommendationUseCase =
              ref.watch(getWorkoutRecommendationUseCaseProvider);
          final formCheckUseCase = ref.watch(getFormCheckUseCaseProvider);

          return AICoachNotifier(
            sendMessageUseCase: sendMessageUseCase,
            workoutRecommendationUseCase: workoutRecommendationUseCase,
            formCheckUseCase: formCheckUseCase,
          );
        }),
      ],
      child: const KinesaApp(),
    ),
  );
}
