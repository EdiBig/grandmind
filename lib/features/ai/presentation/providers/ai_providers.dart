import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/services/prompt_builder_service.dart';
import 'package:kinesa/features/ai/data/repositories/ai_cache_repository.dart';
import 'package:kinesa/features/ai/domain/usecases/send_coach_message_usecase.dart';
import 'package:kinesa/features/ai/domain/usecases/get_workout_recommendation_usecase.dart';
import 'package:kinesa/features/ai/domain/usecases/get_form_check_usecase.dart';
import 'package:kinesa/features/ai/presentation/providers/ai_coach_provider.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

/// Provider for Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for Dio (HTTP client)
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Provider for AI Cache Repository
final aiCacheRepositoryProvider = Provider<AICacheRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final firestore = ref.watch(firestoreProvider);

  return AICacheRepository(
    prefs: prefs,
    firestore: firestore,
  );
});

/// Provider for Claude API Service
final claudeAPIServiceProvider = Provider<ClaudeAPIService>((ref) {
  final dio = ref.watch(dioProvider);
  final cacheRepo = ref.watch(aiCacheRepositoryProvider);

  return ClaudeAPIService(
    dio: dio,
    cacheRepository: cacheRepo,
  );
});

/// Provider for Prompt Builder Service
final promptBuilderServiceProvider = Provider<PromptBuilderService>((ref) {
  return PromptBuilderService();
});

/// Provider for Send Coach Message Use Case
final sendCoachMessageUseCaseProvider = Provider<SendCoachMessageUseCase>((ref) {
  final apiService = ref.watch(claudeAPIServiceProvider);
  final promptBuilder = ref.watch(promptBuilderServiceProvider);

  return SendCoachMessageUseCase(
    apiService: apiService,
    promptBuilder: promptBuilder,
  );
});

/// Provider for Get Workout Recommendation Use Case
final getWorkoutRecommendationUseCaseProvider =
    Provider<GetWorkoutRecommendationUseCase>((ref) {
  final apiService = ref.watch(claudeAPIServiceProvider);
  final promptBuilder = ref.watch(promptBuilderServiceProvider);

  return GetWorkoutRecommendationUseCase(
    apiService: apiService,
    promptBuilder: promptBuilder,
  );
});

/// Provider for Get Form Check Use Case
final getFormCheckUseCaseProvider = Provider<GetFormCheckUseCase>((ref) {
  final apiService = ref.watch(claudeAPIServiceProvider);
  final promptBuilder = ref.watch(promptBuilderServiceProvider);

  return GetFormCheckUseCase(
    apiService: apiService,
    promptBuilder: promptBuilder,
  );
});

/// Override for AI Coach Provider with actual dependencies
final aiCoachProviderOverride =
    StateNotifierProvider<AICoachNotifier, AICoachState>((ref) {
  final sendMessageUseCase = ref.watch(sendCoachMessageUseCaseProvider);
  final workoutRecommendationUseCase =
      ref.watch(getWorkoutRecommendationUseCaseProvider);
  final formCheckUseCase = ref.watch(getFormCheckUseCaseProvider);

  return AICoachNotifier(
    sendMessageUseCase: sendMessageUseCase,
    workoutRecommendationUseCase: workoutRecommendationUseCase,
    formCheckUseCase: formCheckUseCase,
  );
});
