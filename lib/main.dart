import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'features/ai/presentation/providers/ai_providers.dart';
import 'features/ai/presentation/providers/ai_coach_provider.dart';
import 'features/ai/data/repositories/ai_conversation_repository.dart';
import 'features/nutrition/presentation/providers/nutrition_ai_provider.dart';
import 'features/nutrition/data/services/nutrition_ai_service.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'core/providers/analytics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Critical: UI mode setup (affects first frame)
  if (!kIsWeb && Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Web-specific error filter (not critical but lightweight)
  if (kIsWeb) {
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('AssetManifest.bin.json')) return;
      FlutterError.presentError(details);
    };
  }

  // Critical: Firebase must be initialized before runApp for auth state
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized (hot restart)');
    } else {
      rethrow;
    }
  }

  // Critical: Web auth persistence
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    await AuthRepository().handleWebRedirectResult();
  }

  // Critical: SharedPreferences needed for provider overrides
  final sharedPreferences = await SharedPreferences.getInstance();

  // Note: Non-critical services (Crashlytics, AppCheck, Notifications, FCM,
  // RemoteConfig, AIConfig, HealthSync) are initialized after first frame
  // via DeferredInitService in app.dart

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),

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

        nutritionAIServiceProvider.overrideWith((ref) {
          final apiService = ref.watch(claudeAPIServiceProvider);
          return NutritionAIService(apiService: apiService);
        }),
      ],
      child: const KinesaApp(),
    ),
  );
}
