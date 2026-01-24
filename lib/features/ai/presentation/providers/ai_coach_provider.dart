import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/repositories/ai_conversation_repository.dart';
import 'package:kinesa/features/ai/domain/usecases/send_coach_message_usecase.dart';
import 'package:kinesa/features/ai/domain/usecases/get_workout_recommendation_usecase.dart';
import 'package:kinesa/features/ai/domain/usecases/get_form_check_usecase.dart';
import 'package:kinesa/shared/services/analytics_service.dart';
import 'package:logger/logger.dart';

/// State for the AI Coach
class AICoachState {
  final AIConversation? currentConversation;
  final bool isLoading;
  final String? error;
  final bool isStreaming;

  const AICoachState({
    this.currentConversation,
    this.isLoading = false,
    this.error,
    this.isStreaming = false,
  });

  AICoachState copyWith({
    AIConversation? currentConversation,
    bool? isLoading,
    String? error,
    bool? isStreaming,
  }) {
    return AICoachState(
      currentConversation: currentConversation ?? this.currentConversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  /// Check if there's an active conversation
  bool get hasConversation => currentConversation != null;

  /// Get messages from current conversation
  List<AIMessage> get messages => currentConversation?.messages ?? [];

  /// Get total cost of current conversation
  double get totalCost => currentConversation?.totalCost ?? 0.0;
}

/// AI Coach Provider
class AICoachNotifier extends StateNotifier<AICoachState> {
  final SendCoachMessageUseCase _sendMessageUseCase;
  final GetWorkoutRecommendationUseCase _workoutRecommendationUseCase;
  final GetFormCheckUseCase _formCheckUseCase;
  final AIConversationRepository _conversationRepository;
  final AnalyticsService _analytics;
  final Logger _logger = Logger();

  AICoachNotifier({
    required SendCoachMessageUseCase sendMessageUseCase,
    required GetWorkoutRecommendationUseCase workoutRecommendationUseCase,
    required GetFormCheckUseCase formCheckUseCase,
    required AIConversationRepository conversationRepository,
    AnalyticsService? analytics,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _workoutRecommendationUseCase = workoutRecommendationUseCase,
        _formCheckUseCase = formCheckUseCase,
        _conversationRepository = conversationRepository,
        _analytics = analytics ?? AnalyticsService(),
        super(const AICoachState());

  /// Start a new conversation
  void startNewConversation(String userId) {
    _logger.i('Starting new AI coach conversation');

    final conversation = AIConversation(
      id: const Uuid().v4(),
      userId: userId,
      conversationType: 'fitness_coach',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      currentConversation: conversation,
      error: null,
    );
  }

  /// Load the most recent conversation for a user
  Future<void> loadLatestConversation(String userId) async {
    try {
      _logger.i('Loading latest conversation for user: $userId');

      final conversation = await _conversationRepository.getLatestConversation(
        userId: userId,
        conversationType: 'fitness_coach',
      );

      if (conversation != null) {
        _logger.i('Loaded conversation with ${conversation.messages.length} messages');
        state = state.copyWith(
          currentConversation: conversation,
          error: null,
        );
      } else {
        _logger.i('No previous conversation found');
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading conversation', error: e, stackTrace: stackTrace);
    }
  }

  /// Load a specific conversation by ID
  Future<void> loadConversation(String conversationId) async {
    try {
      _logger.i('Loading conversation: $conversationId');

      final conversation = await _conversationRepository.getConversation(conversationId);

      if (conversation != null) {
        state = state.copyWith(
          currentConversation: conversation,
          error: null,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading conversation', error: e, stackTrace: stackTrace);
    }
  }

  /// Save the current conversation to Firestore
  Future<void> _saveConversation() async {
    if (state.currentConversation == null) return;

    try {
      await _conversationRepository.saveConversation(state.currentConversation!);
      _logger.d('Conversation saved: ${state.currentConversation!.id}');
    } catch (e, stackTrace) {
      _logger.e('Error saving conversation', error: e, stackTrace: stackTrace);
    }
  }

  /// Send a message to the AI coach
  Future<void> sendMessage({
    required String message,
    required UserContext userContext,
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

      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      _logger.i('Sending message to AI coach');

      // Track message sent
      await _analytics.logAICoachMessageSent(messageLength: message.length);
      final stopwatch = Stopwatch()..start();

      // Convert conversation messages to ClaudeMessage format
      final conversationHistory = state.messages
          .map((m) => ClaudeMessage(role: m.role, content: m.content))
          .toList();

      // Send to AI coach
      final result = await _sendMessageUseCase.execute(
        userContext: userContext,
        message: message,
        conversationHistory: conversationHistory.length > 1
            ? conversationHistory.sublist(0, conversationHistory.length - 1)
            : null,
      );

      // Add assistant response to conversation
      final assistantMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: result.message,
        timestamp: DateTime.now(),
        fromCache: result.fromCache,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        cost: result.cost,
        metadata: result.metadata,
      );

      _addMessage(assistantMessage);

      state = state.copyWith(isLoading: false);

      // Save conversation to Firestore
      await _saveConversation();

      // Track response received
      stopwatch.stop();
      await _analytics.logAICoachResponseReceived(
        responseTimeMs: stopwatch.elapsedMilliseconds,
        tokensUsed: result.inputTokens + result.outputTokens,
        fromCache: result.fromCache,
      );

      _logger.i('Message exchange complete');
      _logger.d('From cache: ${result.fromCache}');
      _logger.d('Cost: \$${result.cost.toStringAsFixed(4)}');
    } catch (e, stackTrace) {
      _logger.e('Error sending message', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  /// Get a workout recommendation (quick action)
  Future<void> getWorkoutRecommendation({
    required UserContext userContext,
    int? availableMinutes,
    String? workoutType,
  }) async {
    try {
      // Initialize conversation if needed
      if (!state.hasConversation) {
        startNewConversation(userContext.userId);
      }

      // Add user request as a message
      final requestText = 'Recommend a workout'
          '${availableMinutes != null ? " for $availableMinutes minutes" : ""}'
          '${workoutType != null ? " focusing on $workoutType" : ""}.';

      final userMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: requestText,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);

      state = state.copyWith(isLoading: true, error: null);

      _logger.i('Getting workout recommendation');

      // Get workout recommendation
      final result = await _workoutRecommendationUseCase.execute(
        userContext: userContext,
        availableMinutes: availableMinutes,
        workoutType: workoutType,
      );

      // Add recommendation as assistant message
      final assistantMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: result.recommendation,
        timestamp: DateTime.now(),
        fromCache: result.fromCache,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        cost: result.cost,
        metadata: {
          'type': 'workout_recommendation',
          'availableMinutes': availableMinutes,
          'workoutType': workoutType,
        },
      );

      _addMessage(assistantMessage);

      state = state.copyWith(isLoading: false);

      // Save conversation to Firestore
      await _saveConversation();

      _logger.i('Workout recommendation complete');
    } catch (e, stackTrace) {
      _logger.e('Error getting workout recommendation', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get workout recommendation: ${e.toString()}',
      );
    }
  }

  /// Get form check guidance (quick action)
  Future<void> getFormCheck({
    required UserContext userContext,
    required String exercise,
  }) async {
    try {
      // Initialize conversation if needed
      if (!state.hasConversation) {
        startNewConversation(userContext.userId);
      }

      // Add user request as a message
      final requestText = 'Can you give me form guidance for $exercise?';

      final userMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: requestText,
        timestamp: DateTime.now(),
      );

      _addMessage(userMessage);

      state = state.copyWith(isLoading: true, error: null);

      _logger.i('Getting form check for $exercise');

      // Get form check
      final result = await _formCheckUseCase.execute(
        userContext: userContext,
        exercise: exercise,
      );

      // Add guidance as assistant message
      final assistantMessage = AIMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: result.guidance,
        timestamp: DateTime.now(),
        fromCache: result.fromCache,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        cost: result.cost,
        metadata: {
          'type': 'form_check',
          'exercise': exercise,
        },
      );

      _addMessage(assistantMessage);

      state = state.copyWith(isLoading: false);

      // Save conversation to Firestore
      await _saveConversation();

      _logger.i('Form check complete');
    } catch (e, stackTrace) {
      _logger.e('Error getting form check', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get form guidance: ${e.toString()}',
      );
    }
  }

  /// Clear the current conversation
  void clearConversation() {
    _logger.i('Clearing AI coach conversation');
    state = const AICoachState();
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

/// Provider for AI Coach
/// This will need to be initialized with dependencies in the app
final aiCoachProvider =
    StateNotifierProvider<AICoachNotifier, AICoachState>((ref) {
  throw UnimplementedError(
    'aiCoachProvider must be overridden with actual dependencies',
  );
});
