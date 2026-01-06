import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'firebase_options.dart';
import 'core/config/ai_config.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/ai/presentation/providers/ai_providers.dart';
import 'features/ai/presentation/providers/ai_coach_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
