import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/services/prompt_builder_service.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:logger/logger.dart';

/// Use case for sending a message to the AI fitness coach
class SendCoachMessageUseCase {
  final ClaudeAPIService _apiService;
  final PromptBuilderService _promptBuilder;
  final Logger _logger = Logger();

  SendCoachMessageUseCase({
    required ClaudeAPIService apiService,
    required PromptBuilderService promptBuilder,
  })  : _apiService = apiService,
        _promptBuilder = promptBuilder;

  /// Send a message to the AI coach and get a response
  ///
  /// Parameters:
  /// - [userContext]: Current user context (profile, health, activity data)
  /// - [message]: User's message to the coach
  /// - [conversationHistory]: Previous messages in the conversation
  /// - [userId]: User ID for caching and personalization
  ///
  /// Returns: The coach's response as a string
  Future<CoachMessageResult> execute({
    required UserContext userContext,
    required String message,
    List<ClaudeMessage>? conversationHistory,
  }) async {
    try {
      _logger.i('Sending message to AI coach for user: ${userContext.userId}');
      _logger.d('Message: $message');

      // Build the prompt with user context
      final prompt = _promptBuilder.buildFitnessCoachPrompt(
        context: userContext,
        userMessage: message,
        compressContext: conversationHistory != null && conversationHistory.length > 5,
      );

      _logger.d('Prompt built - Estimated tokens: ${_promptBuilder.estimateTokenCount(prompt)}');

      // Send to Claude API
      final response = await _apiService.sendMessage(
        prompt: prompt.userPrompt,
        systemPrompt: prompt.systemPrompt,
        conversationHistory: conversationHistory,
        userId: userContext.userId,
        promptType: 'fitness_coach',
        maxTokens: 800,
      );

      _logger.i('Response received from AI coach');
      _logger.d('Cost: \$${response.cost.toStringAsFixed(4)}');
      _logger.d('From cache: ${response.fromCache}');

      return CoachMessageResult(
        message: response.content,
        fromCache: response.fromCache,
        inputTokens: response.inputTokens,
        outputTokens: response.outputTokens,
        cost: response.cost,
        metadata: {
          'responseId': response.id,
          'model': response.model,
          'stopReason': response.stopReason,
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error sending message to AI coach', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Result from sending a message to the AI coach
class CoachMessageResult {
  final String message;
  final bool fromCache;
  final int inputTokens;
  final int outputTokens;
  final double cost;
  final Map<String, dynamic> metadata;

  const CoachMessageResult({
    required this.message,
    required this.fromCache,
    required this.inputTokens,
    required this.outputTokens,
    required this.cost,
    this.metadata = const {},
  });

  @override
  String toString() {
    return 'CoachMessageResult(tokens: $inputTokens+$outputTokens, cost: \$$cost, cached: $fromCache)';
  }
}
