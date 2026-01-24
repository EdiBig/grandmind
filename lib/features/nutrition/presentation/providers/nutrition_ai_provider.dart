import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/repositories/ai_conversation_repository.dart';
import 'package:kinesa/features/nutrition/data/services/nutrition_ai_service.dart';
import 'package:kinesa/features/nutrition/domain/models/meal.dart';
import 'package:kinesa/features/nutrition/domain/models/nutrition_goal.dart';
import 'package:kinesa/features/nutrition/domain/models/daily_nutrition_summary.dart';

/// State for personalized nutrition tips
class NutritionTipsState {
  final List<NutritionTip> tips;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const NutritionTipsState({
    this.tips = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  NutritionTipsState copyWith({
    List<NutritionTip>? tips,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return NutritionTipsState(
      tips: tips ?? this.tips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasTips => tips.isNotEmpty;
}

/// State for the AI Nutritionist chat
class NutritionistChatState {
  final AIConversation? currentConversation;
  final bool isLoading;
  final String? error;

  const NutritionistChatState({
    this.currentConversation,
    this.isLoading = false,
    this.error,
  });

  NutritionistChatState copyWith({
    AIConversation? currentConversation,
    bool? isLoading,
    String? error,
  }) {
    return NutritionistChatState(
      currentConversation: currentConversation ?? this.currentConversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasConversation => currentConversation != null;
  List<AIMessage> get messages => currentConversation?.messages ?? [];
}

/// Provider for nutrition tips
class NutritionTipsNotifier extends StateNotifier<NutritionTipsState> {
  final NutritionAIService _nutritionAIService;
  final Logger _logger = Logger();

  NutritionTipsNotifier({
    required NutritionAIService nutritionAIService,
  })  : _nutritionAIService = nutritionAIService,
        super(const NutritionTipsState());

  /// Generate personalized nutrition tips
  Future<void> generateTips({
    required String userId,
    required List<Meal> recentMeals,
    NutritionGoal? goal,
    DailyNutritionSummary? todaySummary,
    int daysOfData = 7,
  }) async {
    if (state.isLoading) return;

    _logger.i('Generating nutrition tips for user: $userId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tips = await _nutritionAIService.generatePersonalizedTips(
        userId: userId,
        recentMeals: recentMeals,
        goal: goal,
        todaySummary: todaySummary,
        daysOfData: daysOfData,
      );

      state = state.copyWith(
        tips: tips,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.i('Generated ${tips.length} nutrition tips');
    } catch (e, stackTrace) {
      _logger.e('Error generating nutrition tips', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate tips: ${e.toString()}',
      );
    }
  }

  /// Clear tips
  void clearTips() {
    state = const NutritionTipsState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for AI Nutritionist chat
class NutritionistChatNotifier extends StateNotifier<NutritionistChatState> {
  final NutritionAIService _nutritionAIService;
  final AIConversationRepository _conversationRepository;
  final Logger _logger = Logger();

  static const String _conversationType = 'nutritionist';

  NutritionistChatNotifier({
    required NutritionAIService nutritionAIService,
    required AIConversationRepository conversationRepository,
  })  : _nutritionAIService = nutritionAIService,
        _conversationRepository = conversationRepository,
        super(const NutritionistChatState());

  /// Load the most recent conversation or start a new one
  Future<void> loadOrStartConversation(String userId) async {
    _logger.i('Loading or starting nutritionist conversation for user: $userId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try to load the most recent conversation
      final existingConversation = await _conversationRepository.getLatestConversation(
        userId: userId,
        conversationType: _conversationType,
      );

      if (existingConversation != null && existingConversation.messages.isNotEmpty) {
        _logger.i('Loaded existing conversation with ${existingConversation.messages.length} messages');
        state = state.copyWith(
          currentConversation: existingConversation,
          isLoading: false,
        );
      } else {
        // Start a new conversation
        _startNewConversationInternal(userId);
        state = state.copyWith(isLoading: false);
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading conversation', error: e, stackTrace: stackTrace);
      // Fall back to starting a new conversation
      _startNewConversationInternal(userId);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Start a new conversation (clears existing)
  void startNewConversation(String userId) {
    _startNewConversationInternal(userId);
  }

  void _startNewConversationInternal(String userId) {
    _logger.i('Starting new nutritionist conversation');

    final conversation = AIConversation(
      id: const Uuid().v4(),
      userId: userId,
      conversationType: _conversationType,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentConversation: conversation,
      error: null,
    );
  }

  /// Send a message to the AI nutritionist
  Future<void> sendMessage({
    required String message,
    required UserContext userContext,
    NutritionGoal? goal,
    DailyNutritionSummary? todaySummary,
  }) async {
    if (message.trim().isEmpty) return;

    try {
      // Initialize conversation if needed
      if (!state.hasConversation) {
        startNewConversation(userContext.userId);
      }

      // Add user message to conversation
      final userMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);

      state = state.copyWith(isLoading: true, error: null);

      _logger.i('Sending message to AI nutritionist');

      // Convert conversation messages to ClaudeMessage format
      final conversationHistory = state.messages
          .map((m) => ClaudeMessage(role: m.role, content: m.content))
          .toList();

      // Send to AI nutritionist
      final response = await _nutritionAIService.chatWithNutritionist(
        userId: userContext.userId,
        message: message,
        userContext: userContext,
        conversationHistory: conversationHistory.length > 1
            ? conversationHistory.sublist(0, conversationHistory.length - 1)
            : null,
        goal: goal,
        todaySummary: todaySummary,
      );

      // Add assistant response to conversation
      final assistantMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );

      _addMessage(assistantMessage);

      state = state.copyWith(isLoading: false);

      // Persist conversation to Firestore
      await _persistConversation();

      _logger.i('Nutritionist response received');
    } catch (e, stackTrace) {
      _logger.e('Error sending message to nutritionist', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  /// Persist the current conversation to Firestore
  Future<void> _persistConversation() async {
    if (state.currentConversation == null) return;

    try {
      await _conversationRepository.saveConversation(state.currentConversation!);
      _logger.d('Conversation persisted to Firestore');
    } catch (e) {
      _logger.e('Error persisting conversation', error: e);
      // Don't throw - persistence failure shouldn't break the chat
    }
  }

  /// Get meal recommendations based on remaining macros
  Future<void> getMealRecommendations({
    required String userId,
    required UserContext userContext,
    required NutritionGoal goal,
    required DailyNutritionSummary todaySummary,
    String? mealType,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      // Initialize conversation if needed
      if (!state.hasConversation) {
        startNewConversation(userId);
      }

      // Add user request as a message
      final requestText = mealType != null
          ? 'What should I eat for $mealType to meet my remaining macro goals?'
          : 'What should I eat to meet my remaining macro goals for today?';

      final userMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: requestText,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);

      state = state.copyWith(isLoading: true, error: null);

      _logger.i('Getting meal recommendations');

      final response = await _nutritionAIService.generateMealRecommendations(
        userId: userId,
        goal: goal,
        todaySummary: todaySummary,
        mealType: mealType,
        dietaryRestrictions: dietaryRestrictions,
      );

      // Add recommendation as assistant message
      final assistantMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
        metadata: {
          'type': 'meal_recommendations',
          'mealType': mealType,
        },
      );

      _addMessage(assistantMessage);

      state = state.copyWith(isLoading: false);

      // Persist conversation to Firestore
      await _persistConversation();

      _logger.i('Meal recommendations received');
    } catch (e, stackTrace) {
      _logger.e('Error getting meal recommendations', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get recommendations: ${e.toString()}',
      );
    }
  }

  /// Delete the current conversation from Firestore and clear state
  Future<void> deleteConversation() async {
    if (state.currentConversation != null) {
      try {
        await _conversationRepository.deleteConversation(state.currentConversation!.id);
        _logger.i('Deleted conversation from Firestore');
      } catch (e) {
        _logger.e('Error deleting conversation', error: e);
      }
    }
    state = const NutritionistChatState();
  }

  /// Clear the current conversation (local only, keeps Firestore)
  void clearConversation() {
    _logger.i('Clearing nutritionist conversation');
    state = const NutritionistChatState();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Add a message to the current conversation
  void _addMessage(AIMessage message) {
    if (state.currentConversation == null) return;

    final updatedMessages = [...state.messages, message];

    final updatedConversation = state.currentConversation!.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(currentConversation: updatedConversation);
  }
}

/// Base provider for NutritionAIService
final nutritionAIServiceProvider = Provider<NutritionAIService>((ref) {
  throw UnimplementedError(
    'nutritionAIServiceProvider must be overridden with actual dependencies',
  );
});

/// Provider for nutrition tips
final nutritionTipsProvider =
    StateNotifierProvider<NutritionTipsNotifier, NutritionTipsState>((ref) {
  final nutritionAIService = ref.watch(nutritionAIServiceProvider);
  return NutritionTipsNotifier(nutritionAIService: nutritionAIService);
});

/// Provider for AI nutritionist chat
final nutritionistChatProvider =
    StateNotifierProvider<NutritionistChatNotifier, NutritionistChatState>((ref) {
  final nutritionAIService = ref.watch(nutritionAIServiceProvider);
  final conversationRepository = ref.watch(aiConversationRepositoryProvider);
  return NutritionistChatNotifier(
    nutritionAIService: nutritionAIService,
    conversationRepository: conversationRepository,
  );
});
