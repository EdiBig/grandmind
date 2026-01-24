import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:kinesa/features/ai/data/services/claude_api_service.dart';
import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/core/config/prompt_templates.dart';
import 'package:kinesa/features/nutrition/domain/models/meal.dart';
import 'package:kinesa/features/nutrition/domain/models/nutrition_goal.dart';
import 'package:kinesa/features/nutrition/domain/models/daily_nutrition_summary.dart';

/// Model for AI-generated nutrition tips
class NutritionTip {
  final String icon;
  final String color;
  final String title;
  final String description;
  final String? actionableAdvice;

  const NutritionTip({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.actionableAdvice,
  });

  factory NutritionTip.fromJson(Map<String, dynamic> json) {
    return NutritionTip(
      icon: json['icon'] as String? ?? 'lightbulb',
      color: json['color'] as String? ?? 'amber',
      title: json['title'] as String,
      description: json['description'] as String,
      actionableAdvice: json['actionableAdvice'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'icon': icon,
        'color': color,
        'title': title,
        'description': description,
        if (actionableAdvice != null) 'actionableAdvice': actionableAdvice,
      };
}

/// Service for AI-powered nutrition insights and recommendations
class NutritionAIService {
  final ClaudeAPIService _apiService;
  final Logger _logger = Logger();

  NutritionAIService({
    required ClaudeAPIService apiService,
  }) : _apiService = apiService;

  /// Generate personalized nutrition tips based on user's nutrition data
  Future<List<NutritionTip>> generatePersonalizedTips({
    required String userId,
    required List<Meal> recentMeals,
    required NutritionGoal? goal,
    required DailyNutritionSummary? todaySummary,
    int daysOfData = 7,
  }) async {
    _logger.i('Generating personalized nutrition tips for user: $userId');

    try {
      // Build nutrition context
      final nutritionContext = _buildNutritionContext(
        recentMeals: recentMeals,
        goal: goal,
        todaySummary: todaySummary,
        daysOfData: daysOfData,
      );

      final systemPrompt = '''${PromptTemplates.nutritionAssistantSystemPrompt}

You are analyzing the user's nutrition data to provide personalized, actionable tips.

RESPONSE FORMAT (JSON):
Return exactly 3-5 tips in this JSON format:
{
  "tips": [
    {
      "icon": "icon_name",
      "color": "color_name",
      "title": "Brief title (max 5 words)",
      "description": "2-3 sentences explaining the insight and why it matters.",
      "actionableAdvice": "One specific action they can take."
    }
  ]
}

Available icons: trending_up, water_drop, restaurant, egg, schedule, local_fire_department, fitness_center, bedtime, mood, favorite
Available colors: green, blue, orange, purple, amber, teal, red, pink, indigo

Guidelines:
- Be specific to their actual data, not generic advice
- Celebrate progress and consistency
- Identify areas for improvement compassionately
- Provide actionable, achievable suggestions
- Consider their goals when making recommendations''';

      final userPrompt = '''USER NUTRITION DATA:
$nutritionContext

Generate 3-5 personalized nutrition tips based on this data. Be specific and reference their actual numbers and patterns.''';

      final response = await _apiService.sendMessage(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
        userId: userId,
        promptType: 'nutrition_tips',
        maxTokens: 1024,
      );

      // Parse response
      final tips = _parseTipsResponse(response.content);
      _logger.i('Generated ${tips.length} nutrition tips');

      return tips;
    } catch (e, stackTrace) {
      _logger.e('Error generating nutrition tips', error: e, stackTrace: stackTrace);
      // Return default tips on error
      return _getDefaultTips();
    }
  }

  /// Chat with the AI nutritionist
  Future<String> chatWithNutritionist({
    required String userId,
    required String message,
    required UserContext userContext,
    List<ClaudeMessage>? conversationHistory,
    NutritionGoal? goal,
    DailyNutritionSummary? todaySummary,
  }) async {
    _logger.i('Chat with nutritionist - User: $userId, Message: ${message.substring(0, message.length.clamp(0, 50))}...');

    try {
      // Build context with nutrition data
      final nutritionContext = StringBuffer();
      nutritionContext.writeln(userContext.toSummary());

      if (goal != null) {
        nutritionContext.writeln('\nNUTRITION GOALS:');
        nutritionContext.writeln('- Daily Calories: ${goal.dailyCalories.toStringAsFixed(0)} cal');
        nutritionContext.writeln('- Protein: ${goal.dailyProteinGrams.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Carbs: ${goal.dailyCarbsGrams.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Fat: ${goal.dailyFatGrams.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Water: ${goal.dailyWaterGlasses} glasses');
      }

      if (todaySummary != null) {
        nutritionContext.writeln('\nTODAY\'S INTAKE:');
        nutritionContext.writeln('- Calories: ${todaySummary.totalCalories.toStringAsFixed(0)} cal');
        nutritionContext.writeln('- Protein: ${todaySummary.totalProtein.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Carbs: ${todaySummary.totalCarbs.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Fat: ${todaySummary.totalFat.toStringAsFixed(0)}g');
        nutritionContext.writeln('- Meals logged: ${todaySummary.mealsLogged}');
      }

      final systemPrompt = '''${PromptTemplates.nutritionAssistantSystemPrompt}

USER PROFILE & NUTRITION DATA:
${nutritionContext.toString()}

GUIDELINES:
- Respond naturally to the user's question
- Reference their specific nutrition data when relevant
- Provide evidence-based nutrition guidance
- Be encouraging and supportive
- Keep responses concise unless detail is requested
- If asked about medical conditions, recommend consulting a healthcare provider''';

      final response = await _apiService.sendMessage(
        prompt: message,
        conversationHistory: conversationHistory,
        systemPrompt: systemPrompt,
        userId: userId,
        promptType: 'nutrition_chat',
        maxTokens: 1024,
      );

      return response.content;
    } catch (e, stackTrace) {
      _logger.e('Error in nutritionist chat', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Generate meal recommendations based on remaining macros
  Future<String> generateMealRecommendations({
    required String userId,
    required NutritionGoal goal,
    required DailyNutritionSummary todaySummary,
    String? mealType,
    List<String>? dietaryRestrictions,
  }) async {
    _logger.i('Generating meal recommendations for user: $userId');

    try {
      final remainingCalories = (goal.dailyCalories - todaySummary.totalCalories).clamp(0, double.infinity);
      final remainingProtein = (goal.dailyProteinGrams - todaySummary.totalProtein).clamp(0, double.infinity);
      final remainingCarbs = (goal.dailyCarbsGrams - todaySummary.totalCarbs).clamp(0, double.infinity);
      final remainingFat = (goal.dailyFatGrams - todaySummary.totalFat).clamp(0, double.infinity);

      final systemPrompt = PromptTemplates.nutritionAssistantSystemPrompt;

      final userPrompt = '''REMAINING MACROS FOR TODAY:
- Calories: ${remainingCalories.toStringAsFixed(0)} cal
- Protein: ${remainingProtein.toStringAsFixed(0)}g
- Carbs: ${remainingCarbs.toStringAsFixed(0)}g
- Fat: ${remainingFat.toStringAsFixed(0)}g

${mealType != null ? 'MEAL TYPE: $mealType\n' : ''}
${dietaryRestrictions != null && dietaryRestrictions.isNotEmpty ? 'DIETARY RESTRICTIONS: ${dietaryRestrictions.join(', ')}\n' : ''}

REQUEST:
Suggest 2-3 meal options that would help meet these remaining macro targets. Include:
1. Meal name
2. Brief description
3. Approximate macros (calories, protein, carbs, fat)
4. Why it's a good choice for their remaining targets

Keep suggestions practical and easy to prepare.''';

      final response = await _apiService.sendMessage(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
        userId: userId,
        promptType: 'meal_recommendations',
        maxTokens: 1024,
      );

      return response.content;
    } catch (e, stackTrace) {
      _logger.e('Error generating meal recommendations', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Build nutrition context string from data
  String _buildNutritionContext({
    required List<Meal> recentMeals,
    required NutritionGoal? goal,
    required DailyNutritionSummary? todaySummary,
    required int daysOfData,
  }) {
    final buffer = StringBuffer();

    // Goals
    if (goal != null) {
      buffer.writeln('NUTRITION GOALS:');
      buffer.writeln('- Daily Calories Target: ${goal.dailyCalories.toStringAsFixed(0)} cal');
      buffer.writeln('- Daily Protein Target: ${goal.dailyProteinGrams.toStringAsFixed(0)}g');
      buffer.writeln('- Daily Carbs Target: ${goal.dailyCarbsGrams.toStringAsFixed(0)}g');
      buffer.writeln('- Daily Fat Target: ${goal.dailyFatGrams.toStringAsFixed(0)}g');
      buffer.writeln('- Daily Water Target: ${goal.dailyWaterGlasses} glasses');
      buffer.writeln();
    }

    // Today's summary
    if (todaySummary != null) {
      buffer.writeln('TODAY\'S PROGRESS:');
      buffer.writeln('- Calories: ${todaySummary.totalCalories.toStringAsFixed(0)} cal (${todaySummary.caloriesProgress.toStringAsFixed(0)}% of goal)');
      buffer.writeln('- Protein: ${todaySummary.totalProtein.toStringAsFixed(0)}g (${todaySummary.proteinProgress.toStringAsFixed(0)}% of goal)');
      buffer.writeln('- Carbs: ${todaySummary.totalCarbs.toStringAsFixed(0)}g (${todaySummary.carbsProgress.toStringAsFixed(0)}% of goal)');
      buffer.writeln('- Fat: ${todaySummary.totalFat.toStringAsFixed(0)}g (${todaySummary.fatProgress.toStringAsFixed(0)}% of goal)');
      buffer.writeln('- Meals logged today: ${todaySummary.mealsLogged}');
      buffer.writeln('- Status: ${todaySummary.progressSummary}');
      buffer.writeln();
    }

    // Analyze recent meals
    if (recentMeals.isNotEmpty) {
      buffer.writeln('RECENT MEAL PATTERNS ($daysOfData days):');

      // Calculate averages
      final daysWithMeals = <DateTime>{};
      double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
      final mealTypeCounts = <MealType, int>{};

      for (final meal in recentMeals) {
        final date = DateTime(meal.mealDate.year, meal.mealDate.month, meal.mealDate.day);
        daysWithMeals.add(date);
        totalCalories += meal.totalCalories;
        totalProtein += meal.totalProtein;
        totalCarbs += meal.totalCarbs;
        totalFat += meal.totalFat;
        mealTypeCounts[meal.mealType] = (mealTypeCounts[meal.mealType] ?? 0) + 1;
      }

      final daysCount = daysWithMeals.length.clamp(1, daysOfData);
      buffer.writeln('- Days with logged meals: $daysCount out of $daysOfData');
      buffer.writeln('- Average daily calories: ${(totalCalories / daysCount).toStringAsFixed(0)} cal');
      buffer.writeln('- Average daily protein: ${(totalProtein / daysCount).toStringAsFixed(0)}g');
      buffer.writeln('- Average daily carbs: ${(totalCarbs / daysCount).toStringAsFixed(0)}g');
      buffer.writeln('- Average daily fat: ${(totalFat / daysCount).toStringAsFixed(0)}g');
      buffer.writeln('- Total meals logged: ${recentMeals.length}');

      // Meal type distribution
      buffer.writeln('\nMEAL TYPE DISTRIBUTION:');
      for (final type in MealType.values) {
        final count = mealTypeCounts[type] ?? 0;
        if (count > 0) {
          buffer.writeln('- ${type.displayName}: $count meals');
        }
      }

      // Goal adherence
      if (goal != null) {
        final avgCalories = totalCalories / daysCount;
        final calorieAdherence = (avgCalories / goal.dailyCalories * 100).clamp(0, 200);
        final avgProtein = totalProtein / daysCount;
        final proteinAdherence = (avgProtein / goal.dailyProteinGrams * 100).clamp(0, 200);

        buffer.writeln('\nGOAL ADHERENCE (past $daysCount days):');
        buffer.writeln('- Calorie adherence: ${calorieAdherence.toStringAsFixed(0)}% of target');
        buffer.writeln('- Protein adherence: ${proteinAdherence.toStringAsFixed(0)}% of target');

        if (calorieAdherence < 80) {
          buffer.writeln('- Note: Calorie intake below target');
        } else if (calorieAdherence > 120) {
          buffer.writeln('- Note: Calorie intake above target');
        }

        if (proteinAdherence < 80) {
          buffer.writeln('- Note: Protein intake below target');
        }
      }
    } else {
      buffer.writeln('RECENT MEALS: No meals logged in the past $daysOfData days');
    }

    return buffer.toString();
  }

  /// Parse tips from AI response
  List<NutritionTip> _parseTipsResponse(String response) {
    try {
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        _logger.w('No JSON found in response, using default tips');
        return _getDefaultTips();
      }

      final jsonStr = jsonMatch.group(0)!;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final tipsList = json['tips'] as List<dynamic>?;
      if (tipsList == null || tipsList.isEmpty) {
        return _getDefaultTips();
      }

      return tipsList
          .map((t) => NutritionTip.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error parsing tips response', error: e);
      return _getDefaultTips();
    }
  }

  /// Get default tips when AI is unavailable
  List<NutritionTip> _getDefaultTips() {
    return const [
      NutritionTip(
        icon: 'trending_up',
        color: 'green',
        title: 'Track Consistently',
        description: 'Logging your meals regularly helps identify patterns and improve your nutrition habits over time.',
        actionableAdvice: 'Try logging at least two meals today.',
      ),
      NutritionTip(
        icon: 'water_drop',
        color: 'blue',
        title: 'Stay Hydrated',
        description: 'Proper hydration supports digestion, energy levels, and overall health.',
        actionableAdvice: 'Drink a glass of water with each meal.',
      ),
      NutritionTip(
        icon: 'restaurant',
        color: 'orange',
        title: 'Balance Your Plate',
        description: 'Aim for a mix of protein, carbs, and healthy fats at each meal for sustained energy.',
        actionableAdvice: 'Include a protein source at every meal.',
      ),
    ];
  }
}
