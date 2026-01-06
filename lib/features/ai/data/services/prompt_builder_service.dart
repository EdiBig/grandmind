import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/core/config/prompt_templates.dart';
import 'package:logger/logger.dart';

/// Service for building context-aware prompts for Claude AI
/// Aggregates user data and creates optimized prompts for different AI features
class PromptBuilderService {
  final Logger _logger = Logger();

  // ============================================================================
  // FITNESS COACH PROMPTS
  // ============================================================================

  /// Build a complete prompt for the AI fitness coach
  BuiltPrompt buildFitnessCoachPrompt({
    required UserContext context,
    required String userMessage,
    bool compressContext = false,
  }) {
    _logger.d('Building fitness coach prompt for user: ${context.userId}');

    // Get coach personality based on user preference
    final coachPersonality = PromptTemplates.getCoachPersonality(context.coachTone);

    // Build system prompt
    final systemPrompt = '''$coachPersonality

${PromptTemplates.fitnessCoachSystemPrompt}''';

    // Build user context summary
    var userContextSummary = '${context.greeting}!\n\n${context.toSummary()}';

    if (compressContext) {
      userContextSummary = PromptTemplates.compressContext(userContextSummary);
    }

    // Build full user prompt
    final userPrompt = '''$userContextSummary

USER MESSAGE:
$userMessage''';

    _logger.d('Prompt built - System: ${systemPrompt.length} chars, User: ${userPrompt.length} chars');

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'fitness_coach',
        'coachTone': context.coachTone ?? 'friendly',
        'compressed': compressContext,
      },
    );
  }

  /// Build prompt specifically for workout recommendation
  BuiltPrompt buildWorkoutRecommendationPrompt({
    required UserContext context,
    int? availableMinutes,
    String? workoutType,
    String? targetMuscleGroup,
  }) {
    _logger.d('Building workout recommendation prompt');

    final coachPersonality = PromptTemplates.getCoachPersonality(context.coachTone);

    final systemPrompt = '''$coachPersonality

${PromptTemplates.fitnessCoachSystemPrompt}''';

    final userPrompt = PromptTemplates.buildWorkoutRecommendationPrompt(
      userContext: context.toSummary(),
      availableMinutes: availableMinutes,
      workoutType: workoutType,
      targetMuscleGroup: targetMuscleGroup,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'workout_recommendation',
        'availableMinutes': availableMinutes,
        'workoutType': workoutType,
      },
    );
  }

  /// Build prompt for form check/guidance
  BuiltPrompt buildFormCheckPrompt({
    required UserContext context,
    required String exercise,
  }) {
    _logger.d('Building form check prompt for exercise: $exercise');

    final coachPersonality = PromptTemplates.getCoachPersonality(context.coachTone);

    final systemPrompt = '''$coachPersonality

${PromptTemplates.fitnessCoachSystemPrompt}''';

    final userPrompt = PromptTemplates.buildFormCheckPrompt(
      userContext: PromptTemplates.compressContext(context.toSummary()),
      exercise: exercise,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'form_check',
        'exercise': exercise,
      },
    );
  }

  /// Build prompt for progress review
  BuiltPrompt buildProgressCheckPrompt({
    required UserContext context,
    required String workoutHistory,
  }) {
    _logger.d('Building progress check prompt');

    final coachPersonality = PromptTemplates.getCoachPersonality(context.coachTone);

    final systemPrompt = '''$coachPersonality

${PromptTemplates.fitnessCoachSystemPrompt}''';

    final userPrompt = PromptTemplates.buildProgressCheckPrompt(
      userContext: PromptTemplates.compressContext(context.toSummary()),
      workoutHistory: workoutHistory,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'progress_check',
      },
    );
  }

  // ============================================================================
  // MOOD & HABIT INSIGHTS PROMPTS
  // ============================================================================

  /// Build prompt for mood and habit insights generation
  BuiltPrompt buildMoodInsightsPrompt({
    required String dataSummary,
    required int analyzedDays,
  }) {
    _logger.d('Building mood insights prompt for $analyzedDays days of data');

    final systemPrompt = PromptTemplates.moodInsightsSystemPrompt;

    final userPrompt = PromptTemplates.buildMoodAnalysisPrompt(
      dataSummary: dataSummary,
      analyzedDays: analyzedDays,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'promptType': 'mood_insights',
        'analyzedDays': analyzedDays,
      },
    );
  }

  // ============================================================================
  // NUTRITION ASSISTANT PROMPTS
  // ============================================================================

  /// Build prompt for nutrition plan generation
  BuiltPrompt buildNutritionPlanPrompt({
    required UserContext context,
    List<String>? dietaryRestrictions,
    List<String>? preferredFoods,
  }) {
    _logger.d('Building nutrition plan prompt');

    final systemPrompt = PromptTemplates.nutritionAssistantSystemPrompt;

    final userPrompt = PromptTemplates.buildNutritionPlanPrompt(
      userContext: context.toSummary(),
      dietaryRestrictions: dietaryRestrictions,
      preferredFoods: preferredFoods,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'nutrition_plan',
        'hasDietaryRestrictions': dietaryRestrictions?.isNotEmpty ?? false,
      },
    );
  }

  /// Build prompt for nutrition conversation
  BuiltPrompt buildNutritionConversationPrompt({
    required UserContext context,
    required String userMessage,
  }) {
    _logger.d('Building nutrition conversation prompt');

    final systemPrompt = PromptTemplates.nutritionAssistantSystemPrompt;

    final userPrompt = '''USER PROFILE:
${PromptTemplates.compressContext(context.toSummary())}

USER MESSAGE:
$userMessage

Provide evidence-based nutrition guidance that supports their fitness goal.''';

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'nutrition_conversation',
      },
    );
  }

  // ============================================================================
  // RECOVERY ADVISOR PROMPTS
  // ============================================================================

  /// Build prompt for recovery advice
  BuiltPrompt buildRecoveryAdvicePrompt({
    required UserContext context,
    required double recoveryScore,
    required Map<String, double> factorScores,
  }) {
    _logger.d('Building recovery advice prompt - Score: $recoveryScore');

    final systemPrompt = PromptTemplates.recoveryAdvisorSystemPrompt;

    final userPrompt = PromptTemplates.buildRecoveryAdvicePrompt(
      userContext: PromptTemplates.compressContext(context.toSummary()),
      recoveryScore: recoveryScore,
      factorScores: factorScores,
    );

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'recovery_advice',
        'recoveryScore': recoveryScore,
      },
    );
  }

  // ============================================================================
  // GENERAL CONVERSATION
  // ============================================================================

  /// Build prompt for general conversation with context
  BuiltPrompt buildGeneralConversationPrompt({
    required UserContext context,
    required String userMessage,
    String? specificRole, // 'coach', 'nutritionist', 'recovery_specialist'
  }) {
    _logger.d('Building general conversation prompt');

    String systemPrompt;
    if (specificRole == 'nutritionist') {
      systemPrompt = PromptTemplates.nutritionAssistantSystemPrompt;
    } else if (specificRole == 'recovery_specialist') {
      systemPrompt = PromptTemplates.recoveryAdvisorSystemPrompt;
    } else {
      // Default to fitness coach
      final coachPersonality = PromptTemplates.getCoachPersonality(context.coachTone);
      systemPrompt = '''$coachPersonality

${PromptTemplates.fitnessCoachSystemPrompt}''';
    }

    final userPrompt = '''USER PROFILE & CURRENT STATE:
${PromptTemplates.compressContext(context.toSummary())}

USER MESSAGE:
$userMessage''';

    return BuiltPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      metadata: {
        'userId': context.userId,
        'promptType': 'general_conversation',
        'role': specificRole ?? 'coach',
      },
    );
  }

  // ============================================================================
  // TOKEN ESTIMATION
  // ============================================================================

  /// Estimate token count for a prompt (rough estimation: ~4 chars per token)
  int estimateTokenCount(BuiltPrompt prompt) {
    final totalChars = prompt.systemPrompt.length + prompt.userPrompt.length;
    final estimatedTokens = (totalChars / 4).ceil();

    _logger.d('Estimated tokens: $estimatedTokens');

    return estimatedTokens;
  }

  /// Check if prompt exceeds token budget
  bool exceedsTokenBudget(BuiltPrompt prompt, {int maxTokens = 4000}) {
    final estimated = estimateTokenCount(prompt);
    final exceeds = estimated > maxTokens;

    if (exceeds) {
      _logger.w('Prompt exceeds token budget: $estimated > $maxTokens');
    }

    return exceeds;
  }

  /// Optimize prompt to fit within token budget
  BuiltPrompt optimizeForTokenBudget(
    BuiltPrompt prompt, {
    int maxTokens = 4000,
  }) {
    if (!exceedsTokenBudget(prompt, maxTokens: maxTokens)) {
      return prompt; // Already within budget
    }

    _logger.i('Optimizing prompt to fit within $maxTokens tokens');

    // Strategy: Compress the user context
    final lines = prompt.userPrompt.split('\n');
    final compressedLines = PromptTemplates.compressContext(
      prompt.userPrompt,
      maxLines: 10,
    );

    return BuiltPrompt(
      systemPrompt: prompt.systemPrompt,
      userPrompt: compressedLines,
      metadata: {
        ...prompt.metadata,
        'optimized': true,
        'originalTokens': estimateTokenCount(prompt),
      },
    );
  }
}

/// Result of building a prompt - contains system and user prompts
class BuiltPrompt {
  final String systemPrompt;
  final String userPrompt;
  final Map<String, dynamic> metadata;

  const BuiltPrompt({
    required this.systemPrompt,
    required this.userPrompt,
    this.metadata = const {},
  });

  /// Get the full prompt for logging/debugging
  String get fullPrompt => '''SYSTEM:
$systemPrompt

USER:
$userPrompt''';

  /// Get prompt length in characters
  int get length => systemPrompt.length + userPrompt.length;

  @override
  String toString() {
    return 'BuiltPrompt(type: ${metadata['promptType']}, length: $length chars)';
  }
}
