import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/services/prompt_builder_service.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:logger/logger.dart';

/// Use case for getting personalized workout recommendations
class GetWorkoutRecommendationUseCase {
  final ClaudeAPIService _apiService;
  final PromptBuilderService _promptBuilder;
  final Logger _logger = Logger();

  GetWorkoutRecommendationUseCase({
    required ClaudeAPIService apiService,
    required PromptBuilderService promptBuilder,
  })  : _apiService = apiService,
        _promptBuilder = promptBuilder;

  /// Get a personalized workout recommendation
  ///
  /// Parameters:
  /// - [userContext]: Current user context (profile, health, activity data)
  /// - [availableMinutes]: Time available for workout (optional)
  /// - [workoutType]: Preferred workout type (optional, e.g., "Strength Training", "Cardio")
  /// - [targetMuscleGroup]: Specific muscle group to target (optional)
  ///
  /// Returns: Detailed workout recommendation
  Future<WorkoutRecommendationResult> execute({
    required UserContext userContext,
    int? availableMinutes,
    String? workoutType,
    String? targetMuscleGroup,
  }) async {
    try {
      _logger.i('Getting workout recommendation for user: ${userContext.userId}');
      _logger.d('Available time: ${availableMinutes ?? "not specified"} minutes');
      _logger.d('Workout type: ${workoutType ?? "any"}');

      // Build the workout recommendation prompt
      final prompt = _promptBuilder.buildWorkoutRecommendationPrompt(
        context: userContext,
        availableMinutes: availableMinutes,
        workoutType: workoutType,
        targetMuscleGroup: targetMuscleGroup,
      );

      _logger.d('Prompt built - Estimated tokens: ${_promptBuilder.estimateTokenCount(prompt)}');

      // Send to Claude API
      final response = await _apiService.sendMessage(
        prompt: prompt.userPrompt,
        systemPrompt: prompt.systemPrompt,
        userId: userContext.userId,
        promptType: 'workout_recommendation',
        maxTokens: 1200, // Longer for detailed workout plans
      );

      _logger.i('Workout recommendation received');
      _logger.d('Cost: \$${response.cost.toStringAsFixed(4)}');

      return WorkoutRecommendationResult(
        recommendation: response.content,
        availableMinutes: availableMinutes,
        workoutType: workoutType,
        targetMuscleGroup: targetMuscleGroup,
        fromCache: response.fromCache,
        inputTokens: response.inputTokens,
        outputTokens: response.outputTokens,
        cost: response.cost,
      );
    } catch (e, stackTrace) {
      _logger.e('Error getting workout recommendation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Result from getting a workout recommendation
class WorkoutRecommendationResult {
  final String recommendation;
  final int? availableMinutes;
  final String? workoutType;
  final String? targetMuscleGroup;
  final bool fromCache;
  final int inputTokens;
  final int outputTokens;
  final double cost;

  const WorkoutRecommendationResult({
    required this.recommendation,
    this.availableMinutes,
    this.workoutType,
    this.targetMuscleGroup,
    required this.fromCache,
    required this.inputTokens,
    required this.outputTokens,
    required this.cost,
  });

  @override
  String toString() {
    return 'WorkoutRecommendation(type: $workoutType, time: ${availableMinutes}min, cached: $fromCache)';
  }
}
