import 'dart:io' show Platform;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'firebase_options.dart';
import 'core/config/ai_config.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/notifications/data/services/fcm_service.dart';
import 'features/ai/presentation/providers/ai_providers.dart';
import 'features/ai/presentation/providers/ai_coach_provider.dart';
import 'features/ai/data/repositories/ai_conversation_repository.dart';
import 'features/nutrition/presentation/providers/nutrition_ai_provider.dart';
import 'features/nutrition/data/services/nutrition_ai_service.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/health/data/services/health_background_sync.dart';
import 'core/providers/analytics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

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

  // Initialize Crashlytics (not available on web)
  if (!kIsWeb) {
    // Pass all uncaught Flutter errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    await AuthRepository().handleWebRedirectResult();
  }

  if (!kIsWeb) {
    // ignore: deprecated_member_use - providerAndroid/providerApple params available in newer version
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

  // Initialize FCM for push notifications (skip on web)
  if (!kIsWeb) {
    await FCMService().initialize();
  }

  // Initialize SharedPreferences for AI caching
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize AI Config (secure API key storage)
  await AIConfig.initialize();

  await registerHealthBackgroundSync();

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
          final conversationRepository = ref.watch(aiConversationRepositoryProvider);
          final analytics = ref.watch(analyticsProvider);

          return AICoachNotifier(
            sendMessageUseCase: sendMessageUseCase,
            workoutRecommendationUseCase: workoutRecommendationUseCase,
            formCheckUseCase: formCheckUseCase,
            conversationRepository: conversationRepository,
            analytics: analytics,
          );
        }),

        // Override Nutrition AI Service provider with actual implementation
        nutritionAIServiceProvider.overrideWith((ref) {
          final apiService = ref.watch(claudeAPIServiceProvider);
          return NutritionAIService(apiService: apiService);
        }),
      ],
      child: const KinesaApp(),
    ),
  );
}
