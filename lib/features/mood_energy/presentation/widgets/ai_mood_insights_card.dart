import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../data/repositories/mood_energy_repository.dart';
import '../../data/services/mood_energy_insights_service.dart';

/// Provider for generating mood/energy insights
final moodEnergyInsightsProvider =
    FutureProvider.autoDispose<MoodEnergyInsights>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return MoodEnergyInsights.empty();

  final repository = ref.watch(moodEnergyRepositoryProvider);
  final insightsService = ref.watch(moodEnergyInsightsServiceProvider);

  // Get last 30 days of logs
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  final logs = await repository.getLogsInRange(userId, startDate, endDate);

  return insightsService.generateInsights(userId, logs);
});

class AIMoodInsightsCard extends ConsumerStatefulWidget {
  const AIMoodInsightsCard({super.key});

  @override
  ConsumerState<AIMoodInsightsCard> createState() => _AIMoodInsightsCardState();
}

class _AIMoodInsightsCardState extends ConsumerState<AIMoodInsightsCard> {
  bool _isGenerating = false;
  MoodEnergyInsights? _cachedInsights;

  Future<void> _generateInsights() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final repository = ref.read(moodEnergyRepositoryProvider);
      final insightsService = ref.read(moodEnergyInsightsServiceProvider);

      // Get last 30 days of logs
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final logs = await repository.getLogsInRange(userId, startDate, endDate);

      final insights = await insightsService.generateInsights(userId, logs);

      setState(() {
        _cachedInsights = insights;
        _isGenerating = false;
      });

      if (mounted) {
        context.push(RouteConstants.moodEnergyInsights, extra: insights);
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate insights: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _isGenerating ? null : _generateInsights,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Insights',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get AI-powered analysis of your mood & energy patterns',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateInsights,
                  icon: _isGenerating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Insights',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_cachedInsights != null && !_cachedInsights!.isEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    context.push(
                      RouteConstants.moodEnergyInsights,
                      extra: _cachedInsights,
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View Last Insights'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
