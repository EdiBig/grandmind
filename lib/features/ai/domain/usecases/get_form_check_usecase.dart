import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/services/prompt_builder_service.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:logger/logger.dart';

/// Use case for getting exercise form guidance
class GetFormCheckUseCase {
  final ClaudeAPIService _apiService;
  final PromptBuilderService _promptBuilder;
  final Logger _logger = Logger();

  GetFormCheckUseCase({
    required ClaudeAPIService apiService,
    required PromptBuilderService promptBuilder,
  })  : _apiService = apiService,
        _promptBuilder = promptBuilder;

  /// Get form guidance for a specific exercise
  ///
  /// Parameters:
  /// - [userContext]: Current user context (especially physical limitations)
  /// - [exercise]: Name of the exercise (e.g., "Deadlift", "Squat", "Push-up")
  ///
  /// Returns: Detailed form guidance with safety tips
  Future<FormCheckResult> execute({
    required UserContext userContext,
    required String exercise,
  }) async {
    try {
      _logger.i('Getting form guidance for exercise: $exercise');

      // Build the form check prompt
      final prompt = _promptBuilder.buildFormCheckPrompt(
        context: userContext,
        exercise: exercise,
      );

      _logger.d('Prompt built - Estimated tokens: ${_promptBuilder.estimateTokenCount(prompt)}');

      // Send to Claude API
      final response = await _apiService.sendMessage(
        prompt: prompt.userPrompt,
        systemPrompt: prompt.systemPrompt,
        userId: userContext.userId,
        promptType: 'form_check',
        maxTokens: 600,
      );

      _logger.i('Form guidance received for $exercise');
      _logger.d('Cost: \$${response.cost.toStringAsFixed(4)}');

      return FormCheckResult(
        exercise: exercise,
        guidance: response.content,
        fromCache: response.fromCache,
        inputTokens: response.inputTokens,
        outputTokens: response.outputTokens,
        cost: response.cost,
      );
    } catch (e, stackTrace) {
      _logger.e('Error getting form guidance', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Result from getting form check guidance
class FormCheckResult {
  final String exercise;
  final String guidance;
  final bool fromCache;
  final int inputTokens;
  final int outputTokens;
  final double cost;

  const FormCheckResult({
    required this.exercise,
    required this.guidance,
    required this.fromCache,
    required this.inputTokens,
    required this.outputTokens,
    required this.cost,
  });

  @override
  String toString() {
    return 'FormCheck(exercise: $exercise, cached: $fromCache)';
  }
}
