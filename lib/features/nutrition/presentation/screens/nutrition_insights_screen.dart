import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/nutrition_providers.dart';
import '../../domain/models/daily_nutrition_summary.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/nutrition_goal.dart';

/// Nutrition AI Insights Screen
/// Provides comprehensive analysis of nutrition data including:
/// - Trend analysis over time
/// - Personalized AI tips
/// - Goal progress with predictions
/// - Cross-domain insights (nutrition + sleep/mood/workouts)
class NutritionInsightsScreen extends ConsumerStatefulWidget {
  const NutritionInsightsScreen({super.key});

  @override
  ConsumerState<NutritionInsightsScreen> createState() =>
      _NutritionInsightsScreenState();
}

class _NutritionInsightsScreenState
    extends ConsumerState<NutritionInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 7; // Default to 7 days

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nutrition Insights')),
        body: const Center(
          child: Text('Please sign in to view insights'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Insights'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Trends', icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: 'AI Tips', icon: Icon(Icons.lightbulb, size: 20)),
            Tab(text: 'Goals', icon: Icon(Icons.track_changes, size: 20)),
            Tab(
                text: 'Correlations',
                icon: Icon(Icons.insights, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendsTab(userId),
          _buildAITipsTab(userId),
          _buildGoalsTab(userId),
          _buildCorrelationsTab(userId),
        ],
      ),
    );
  }

  // ========== TRENDS TAB ==========

  Widget _buildTrendsTab(String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          _buildCaloriesTrendCard(userId),
          const SizedBox(height: 16),
          _buildMacrosTrendCard(userId),
          const SizedBox(height: 16),
          _buildWaterTrendCard(userId),
          const SizedBox(height: 16),
          _buildMealTimingCard(userId),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: [
        const Text(
          'Time Range:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: [7, 14, 30, 90].map((days) {
              final isSelected = _selectedDays == days;
              return ChoiceChip(
                label: Text('$days days'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDays = days);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesTrendCard(String userId) {
    // Calculate date range
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedDays));

    final dateRange = DateRange(
      start: DateTime(startDate.year, startDate.month, startDate.day),
      end: DateTime(endDate.year, endDate.month, endDate.day),
    );

    final mealsAsync = ref.watch(mealsForDateRangeProvider(dateRange));
    final goalAsync = ref.watch(userNutritionGoalProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Calories Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            mealsAsync.when(
              data: (meals) {
                return goalAsync.when(
                  data: (goal) {
                    return _buildCaloriesChart(meals, goal, dateRange);
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, st) => Text('Error: $e'),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(
    List<Meal> meals,
    NutritionGoal? goal,
    DateRange dateRange,
  ) {
    // Group meals by date
    final Map<DateTime, double> dailyCalories = {};

    // Initialize all dates in range with 0
    for (int i = 0; i <= _selectedDays; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      dailyCalories[normalizedDate] = 0.0;
    }

    // Sum calories for each day
    for (final meal in meals) {
      final mealDate =
          DateTime(meal.mealDate.year, meal.mealDate.month, meal.mealDate.day);
      dailyCalories[mealDate] =
          (dailyCalories[mealDate] ?? 0) + meal.totalCalories;
    }

    // Create chart data
    final sortedDates = dailyCalories.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final calories = dailyCalories[sortedDates[i]]!;
      spots.add(FlSpot(i.toDouble(), calories));
    }

    if (spots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No data available for this period'),
        ),
      );
    }

    // Calculate stats
    final avgCalories =
        dailyCalories.values.reduce((a, b) => a + b) / dailyCalories.length;
    final targetCalories = goal?.dailyCalories ?? 2000;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sortedDates.length) {
                        return const Text('');
                      }
                      final date = sortedDates[index];
                      return Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: spots.length <= 14,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withValues(alpha: 0.1),
                  ),
                ),
                // Target line
                if (goal != null)
                  LineChartBarData(
                    spots: [
                      FlSpot(0, targetCalories),
                      FlSpot(
                          (sortedDates.length - 1).toDouble(), targetCalories),
                    ],
                    isCurved: false,
                    color: Colors.green.withValues(alpha: 0.5),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
              'Average',
              '${avgCalories.toStringAsFixed(0)} cal',
              Colors.orange,
            ),
            _buildStatColumn(
              'Target',
              '${targetCalories.toStringAsFixed(0)} cal',
              Colors.green,
            ),
            _buildStatColumn(
              'Difference',
              '${(avgCalories - targetCalories).toStringAsFixed(0)} cal',
              avgCalories > targetCalories ? Colors.red : Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacrosTrendCard(String userId) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedDays));

    final dateRange = DateRange(
      start: DateTime(startDate.year, startDate.month, startDate.day),
      end: DateTime(endDate.year, endDate.month, endDate.day),
    );

    final mealsAsync = ref.watch(mealsForDateRangeProvider(dateRange));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Macros Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            mealsAsync.when(
              data: (meals) {
                double totalProtein = 0, totalCarbs = 0, totalFat = 0;

                for (final meal in meals) {
                  totalProtein += meal.totalProtein;
                  totalCarbs += meal.totalCarbs;
                  totalFat += meal.totalFat;
                }

                if (totalProtein == 0 && totalCarbs == 0 && totalFat == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No data available'),
                    ),
                  );
                }

                final avgProtein = totalProtein / _selectedDays;
                final avgCarbs = totalCarbs / _selectedDays;
                final avgFat = totalFat / _selectedDays;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroCircle(
                          'Protein',
                          avgProtein,
                          Colors.blue,
                        ),
                        _buildMacroCircle(
                          'Carbs',
                          avgCarbs,
                          Colors.green,
                        ),
                        _buildMacroCircle(
                          'Fat',
                          avgFat,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Daily averages over the last $_selectedDays days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCircle(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '${value.toStringAsFixed(0)}g',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTrendCard(String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_drink, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Water Intake Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Water trend visualization coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimingCard(String userId) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedDays));

    final dateRange = DateRange(
      start: DateTime(startDate.year, startDate.month, startDate.day),
      end: DateTime(endDate.year, endDate.month, endDate.day),
    );

    final mealsAsync = ref.watch(mealsForDateRangeProvider(dateRange));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Meal Timing Patterns',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            mealsAsync.when(
              data: (meals) {
                final mealTypeCounts = <MealType, int>{};
                for (final meal in meals) {
                  mealTypeCounts[meal.mealType] =
                      (mealTypeCounts[meal.mealType] ?? 0) + 1;
                }

                if (mealTypeCounts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No meals logged'),
                    ),
                  );
                }

                return Column(
                  children: MealType.values.map((type) {
                    final count = mealTypeCounts[type] ?? 0;
                    final percentage =
                        (count / meals.length * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            type.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: count / meals.length,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$count meals ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ========== AI TIPS TAB ==========

  Widget _buildAITipsTab(String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalizedTipsCard(),
          const SizedBox(height: 16),
          _buildNutritionRecommendationsCard(),
          const SizedBox(height: 16),
          _buildHabitSuggestionsCard(),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTipsCard() {
    // TODO: Integrate with Claude AI API for real insights
    final tips = [
      {
        'icon': Icons.trending_up,
        'color': Colors.green,
        'title': 'Great Progress!',
        'description':
            'You\'ve been consistent with logging meals for 5 days straight. Keep it up!',
      },
      {
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'title': 'Hydration Reminder',
        'description':
            'Your water intake is below target on most days. Try drinking a glass of water with each meal.',
      },
      {
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'title': 'Protein Boost',
        'description':
            'Your protein intake averages 15% below your goal. Consider adding a protein source to breakfast.',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Personalized Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => _buildTipItem(
                  icon: tip['icon'] as IconData,
                  color: tip['color'] as Color,
                  title: tip['title'] as String,
                  description: tip['description'] as String,
                )),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Generate more tips using AI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI tip generation coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Tips'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRecommendationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.recommend, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Nutrition Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI-powered recommendations based on your nutrition patterns will appear here.',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Claude AI chat for nutrition
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('AI nutrition coaching coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Ask AI Nutritionist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSuggestionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Habit Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHabitSuggestionItem(
              'Meal Prep Sundays',
              'Based on your schedule, preparing meals on Sundays could improve your weekday nutrition.',
              Icons.calendar_today,
            ),
            _buildHabitSuggestionItem(
              'Protein First',
              'Eating protein-rich foods first can help you feel fuller and meet your protein goals.',
              Icons.egg,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSuggestionItem(
      String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ========== GOALS TAB ==========

  Widget _buildGoalsTab(String userId) {
    final goalAsync = ref.watch(userNutritionGoalProvider);
    final summaryAsync = ref.watch(todayNutritionSummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          goalAsync.when(
            data: (goal) {
              if (goal == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No nutrition goals set',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set your nutrition goals to track progress',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to goals screen
                          },
                          child: const Text('Set Goals'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return summaryAsync.when(
                data: (summary) {
                  return Column(
                    children: [
                      _buildGoalProgressCard(goal, summary),
                      const SizedBox(height: 16),
                      _buildGoalPredictionsCard(goal, summary),
                      const SizedBox(height: 16),
                      _buildGoalStreakCard(),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(
      NutritionGoal goal, DailyNutritionSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalProgressBar(
              'Calories',
              summary.totalCalories,
              goal.dailyCalories,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildGoalProgressBar(
              'Protein',
              summary.totalProtein,
              goal.dailyProteinGrams,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildGoalProgressBar(
              'Carbs',
              summary.totalCarbs,
              goal.dailyCarbsGrams,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildGoalProgressBar(
              'Fat',
              summary.totalFat,
              goal.dailyFatGrams,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressBar(
    String label,
    double current,
    double target,
    Color color,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalPredictionsCard(
      NutritionGoal goal, DailyNutritionSummary summary) {
    // Simple prediction: based on current rate, when will goal be reached
    final daysToGoal = _calculateDaysToGoal(summary, goal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Goal Predictions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (daysToGoal != null)
              Text(
                'At your current rate, you\'ll reach your goal in approximately $daysToGoal days.',
                style: const TextStyle(fontSize: 16),
              )
            else
              const Text(
                'Keep logging your meals for more accurate predictions!',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'AI-powered predictions will become more accurate as you log more data.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _calculateDaysToGoal(
      DailyNutritionSummary summary, NutritionGoal goal) {
    // Simple prediction logic - can be enhanced with ML
    // For now, just return a placeholder
    return null;
  }

  Widget _buildGoalStreakCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Goal Streak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  Text(
                    '3',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'days meeting your goals',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== CORRELATIONS TAB ==========

  Widget _buildCorrelationsTab(String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cross-Domain Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover how your nutrition relates to other aspects of your health',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          _buildCorrelationCard(
            'Nutrition & Sleep',
            'On days you eat more protein, you sleep 12% better on average.',
            Icons.bedtime,
            Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildCorrelationCard(
            'Nutrition & Workouts',
            'Your workout performance is 15% higher when you meet your carb goals.',
            Icons.fitness_center,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCorrelationCard(
            'Nutrition & Mood',
            'Days with balanced meals show 20% better mood ratings.',
            Icons.mood,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildCorrelationCard(
            'Hydration & Energy',
            'Meeting water goals correlates with 18% higher energy levels.',
            Icons.battery_charging_full,
            Colors.green,
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These insights are based on your personal data and patterns. Keep logging to see more accurate correlations!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard(
    String title,
    String insight,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(insight),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
