import 'package:kinesa/features/ai/data/models/user_context.dart';
import 'package:kinesa/features/ai/data/services/prompt_builder_service.dart';

/// Test script to demonstrate PromptBuilderService
/// Run with: C:/dev/flutter/bin/dart.bat run scripts/test_prompt_builder.dart
void main() {
  print('\n' + '=' * 70);
  print(' PROMPT BUILDER SERVICE TEST');
  print('=' * 70);

  final promptBuilder = PromptBuilderService();

  // Create sample user context
  final userContext = UserContextBuilder()
    ..userId = 'test_user_123'
    ..displayName = 'Sarah'
    ..age = 28
    ..gender = 'Female'
    ..height = 165
    ..weight = 62
    ..fitnessGoal = 'Weight Loss'
    ..fitnessLevel = 'Intermediate'
    ..coachTone = 'friendly'
    ..physicalLimitations = ['Lower back pain']
    ..preferredWorkoutTypes = ['Cardio', 'Strength Training']
    ..preferredWorkoutDuration = 30
    ..weeklyWorkoutFrequency = 4
    ..lastWorkoutDate = DateTime.now().subtract(Duration(days: 1))
    ..daysSinceLastWorkout = 1
    ..recentWorkouts = [
      RecentWorkout(
        workoutName: 'Full Body Strength',
        date: DateTime.now().subtract(Duration(days: 1)),
        durationMinutes: 35,
        perceivedEffort: 7,
      ),
      RecentWorkout(
        workoutName: 'HIIT Cardio',
        date: DateTime.now().subtract(Duration(days: 3)),
        durationMinutes: 25,
        perceivedEffort: 8,
      ),
    ]
    ..recentPerformanceSummary = 'Good consistency, moderate intensity'
    ..todaySteps = 5234
    ..lastNightSleepHours = 7.5
    ..averageSleepHours = 7.2
    ..currentEnergyLevel = 4
    ..currentMood = 4
    ..habitCompletionRate = 0.75
    ..currentStreak = 12
    ..timestamp = DateTime.now();

  final context = userContext.build();

  print('\n📊 User Context Summary:');
  print('-' * 70);
  print(context.toSummary());
  print('-' * 70);

  // Test 1: Fitness Coach Conversation
  print('\n\n🏋️ TEST 1: FITNESS COACH CONVERSATION');
  print('=' * 70);

  final coachPrompt = promptBuilder.buildFitnessCoachPrompt(
    context: context,
    userMessage: 'What workout should I do today?',
  );

  print('\nPrompt Type: ${coachPrompt.metadata['promptType']}');
  print('Coach Tone: ${coachPrompt.metadata['coachTone']}');
  print('System Prompt Length: ${coachPrompt.systemPrompt.length} chars');
  print('User Prompt Length: ${coachPrompt.userPrompt.length} chars');
  print('Total Length: ${coachPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(coachPrompt)}');

  print('\n--- SYSTEM PROMPT (first 500 chars) ---');
  print(coachPrompt.systemPrompt.substring(0, 500.coerceAtMost(coachPrompt.systemPrompt.length)));
  print('...\n');

  print('--- USER PROMPT ---');
  print(coachPrompt.userPrompt);

  // Test 2: Workout Recommendation
  print('\n\n💪 TEST 2: WORKOUT RECOMMENDATION');
  print('=' * 70);

  final workoutPrompt = promptBuilder.buildWorkoutRecommendationPrompt(
    context: context,
    availableMinutes: 30,
    workoutType: 'Strength Training',
  );

  print('\nPrompt Type: ${workoutPrompt.metadata['promptType']}');
  print('Available Minutes: ${workoutPrompt.metadata['availableMinutes']}');
  print('Workout Type: ${workoutPrompt.metadata['workoutType']}');
  print('Total Length: ${workoutPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(workoutPrompt)}');

  print('\n--- USER PROMPT (Workout Request) ---');
  print(workoutPrompt.userPrompt);

  // Test 3: Form Check
  print('\n\n✓ TEST 3: FORM CHECK');
  print('=' * 70);

  final formPrompt = promptBuilder.buildFormCheckPrompt(
    context: context,
    exercise: 'Deadlift',
  );

  print('\nPrompt Type: ${formPrompt.metadata['promptType']}');
  print('Exercise: ${formPrompt.metadata['exercise']}');
  print('Total Length: ${formPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(formPrompt)}');

  print('\n--- USER PROMPT (Form Check) ---');
  print(formPrompt.userPrompt);

  // Test 4: Mood Insights
  print('\n\n📈 TEST 4: MOOD INSIGHTS');
  print('=' * 70);

  final dataSummary = '''
MOOD SUMMARY (Last 7 days):
- Average mood: 3.8/5
- Trend: Increasing (+0.3 from previous week)
- Low mood days: 1
- High mood days: 4

HABIT SUMMARY:
- Completion rate: 75%
- Current streak: 12 days
- Missed habits: 8 over 7 days

WORKOUT SUMMARY:
- Total workouts: 4
- Average duration: 32 minutes
- Average effort (RPE): 7.2/10
- Workout types: Strength (2), Cardio (2)

HEALTH SUMMARY:
- Average sleep: 7.2 hours
- Average steps: 7,543
- Sleep quality trend: Stable
- Energy correlation with sleep: High (r=0.82)

CORRELATIONS DETECTED:
- Mood 18% higher on workout days
- Energy 25% lower when sleep < 7 hours
- Habit completion 40% better when morning workout done
''';

  final insightsPrompt = promptBuilder.buildMoodInsightsPrompt(
    dataSummary: dataSummary,
    analyzedDays: 7,
  );

  print('\nPrompt Type: ${insightsPrompt.metadata['promptType']}');
  print('Analyzed Days: ${insightsPrompt.metadata['analyzedDays']}');
  print('Total Length: ${insightsPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(insightsPrompt)}');

  print('\n--- USER PROMPT (Mood Insights) ---');
  print(insightsPrompt.userPrompt.substring(0, 400));
  print('...\n');

  // Test 5: Nutrition Plan
  print('\n🥗 TEST 5: NUTRITION PLAN');
  print('=' * 70);

  final nutritionPrompt = promptBuilder.buildNutritionPlanPrompt(
    context: context,
    dietaryRestrictions: ['Lactose Intolerant'],
    preferredFoods: ['Chicken', 'Rice', 'Vegetables'],
  );

  print('\nPrompt Type: ${nutritionPrompt.metadata['promptType']}');
  print('Has Dietary Restrictions: ${nutritionPrompt.metadata['hasDietaryRestrictions']}');
  print('Total Length: ${nutritionPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(nutritionPrompt)}');

  print('\n--- USER PROMPT (Nutrition Plan) ---');
  print(nutritionPrompt.userPrompt);

  // Test 6: Recovery Advice
  print('\n\n😴 TEST 6: RECOVERY ADVICE');
  print('=' * 70);

  final recoveryPrompt = promptBuilder.buildRecoveryAdvicePrompt(
    context: context,
    recoveryScore: 68.5,
    factorScores: {
      'Sleep': 75.0,
      'HRV': 60.0,
      'Workload': 45.0,
      'Subjective': 80.0,
    },
  );

  print('\nPrompt Type: ${recoveryPrompt.metadata['promptType']}');
  print('Recovery Score: ${recoveryPrompt.metadata['recoveryScore']}');
  print('Total Length: ${recoveryPrompt.length} chars');
  print('Estimated Tokens: ${promptBuilder.estimateTokenCount(recoveryPrompt)}');

  print('\n--- USER PROMPT (Recovery Advice) ---');
  print(recoveryPrompt.userPrompt);

  // Test 7: Token Budget Optimization
  print('\n\n⚡ TEST 7: TOKEN BUDGET OPTIMIZATION');
  print('=' * 70);

  final largePrompt = promptBuilder.buildFitnessCoachPrompt(
    context: context,
    userMessage: 'Give me a detailed explanation of progressive overload and how to apply it to my training.',
  );

  print('\nOriginal Prompt:');
  print('  Length: ${largePrompt.length} chars');
  print('  Estimated Tokens: ${promptBuilder.estimateTokenCount(largePrompt)}');

  final optimized = promptBuilder.optimizeForTokenBudget(
    largePrompt,
    maxTokens: 500,
  );

  print('\nOptimized Prompt:');
  print('  Length: ${optimized.length} chars');
  print('  Estimated Tokens: ${promptBuilder.estimateTokenCount(optimized)}');
  print('  Was Optimized: ${optimized.metadata['optimized'] ?? false}');

  if (optimized.metadata['optimized'] == true) {
    print('  Original Tokens: ${optimized.metadata['originalTokens']}');
    final savedTokens = (optimized.metadata['originalTokens'] as int) -
        promptBuilder.estimateTokenCount(optimized);
    print('  Tokens Saved: $savedTokens');
  }

  // Summary
  print('\n\n' + '=' * 70);
  print(' 🎉 PROMPT BUILDER SERVICE TEST COMPLETE!');
  print('=' * 70);

  print('\n✅ All prompt types generated successfully:');
  print('   1. Fitness Coach Conversation');
  print('   2. Workout Recommendation');
  print('   3. Form Check');
  print('   4. Mood Insights');
  print('   5. Nutrition Plan');
  print('   6. Recovery Advice');
  print('   7. Token Budget Optimization');

  print('\n📊 PromptBuilderService is ready for integration!');
  print('\nNext steps:');
  print('• Integrate with ClaudeAPIService');
  print('• Build AI Coach provider with Riverpod');
  print('• Create UI for AI features');
  print('• Implement caching for cost optimization');
  print('');
}

extension on int {
  int coerceAtMost(int maximum) => this < maximum ? this : maximum;
}
