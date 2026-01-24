import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/progress_providers.dart';
import '../widgets/activity_calendar_widget.dart';
import '../widgets/streak_card.dart';

class ActivityCalendarScreen extends ConsumerStatefulWidget {
  const ActivityCalendarScreen({super.key});

  @override
  ConsumerState<ActivityCalendarScreen> createState() =>
      _ActivityCalendarScreenState();
}

class _ActivityCalendarScreenState
    extends ConsumerState<ActivityCalendarScreen> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    if (!nextMonth.isAfter(DateTime(now.year, now.month + 1, 0))) {
      setState(() {
        _displayMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final streakDataAsync = ref.watch(streakDataProvider);
    final activityAsync = ref.watch(activityCalendarProvider(_displayMonth));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Streak Card
          streakDataAsync.when(
            data: (streakData) => StreakCard(streakData: streakData),
            loading: () => const _SkeletonStreakCard(),
            error: (_, __) => _buildErrorCard(
              context,
              'Unable to load streak data',
              () => ref.invalidate(streakDataProvider),
            ),
          ),
          const SizedBox(height: 24),

          // Month Navigation
          _buildMonthNavigation(context),
          const SizedBox(height: 16),

          // Calendar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: activityAsync.when(
              data: (activityDays) => ActivityCalendarWidget(
                activityDays: activityDays,
                displayMonth: _displayMonth,
                onDayTap: (date, activity) =>
                    _showDayDetails(context, date, activity),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => _buildErrorCard(
                context,
                'Unable to load calendar data',
                () => ref.invalidate(activityCalendarProvider(_displayMonth)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Monthly Summary
          activityAsync.when(
            data: (activityDays) => _buildMonthlySummary(context, activityDays),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth = _displayMonth.year == now.year &&
        _displayMonth.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(Icons.chevron_left, color: colorScheme.primary),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_displayMonth),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: isCurrentMonth ? null : _nextMonth,
          icon: Icon(
            Icons.chevron_right,
            color: isCurrentMonth
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                : colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(
    BuildContext context,
    List<ActivityDay> activityDays,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeDays = activityDays.where((d) => d.hasActivity).length;
    final totalWorkouts = activityDays.fold<int>(
      0,
      (sum, d) => sum + d.workoutCount,
    );
    final totalHabits = activityDays.fold<int>(
      0,
      (sum, d) => sum + d.habitsCompleted,
    );
    final avgScore = activityDays.isEmpty
        ? 0.0
        : activityDays.fold<int>(0, (sum, d) => sum + d.activityScore) /
            activityDays.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  Icons.calendar_today,
                  '$activeDays',
                  'Active Days',
                  colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  Icons.fitness_center,
                  '$totalWorkouts',
                  'Workouts',
                  colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  Icons.check_circle,
                  '$totalHabits',
                  'Habits Done',
                  colorScheme.tertiary,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  Icons.speed,
                  '${avgScore.toInt()}%',
                  'Avg Activity',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    ActivityDay activity,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!activity.hasActivity)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No activity recorded',
                        style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _buildDetailRow(
                ctx,
                Icons.fitness_center,
                'Workouts',
                '${activity.workoutCount}',
                activity.workoutCount > 0,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                ctx,
                Icons.check_circle,
                'Habits Completed',
                '${activity.habitsCompleted}/${activity.habitsTotal}',
                activity.habitsCompleted > 0,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                ctx,
                Icons.monitor_weight,
                'Weight Logged',
                activity.weightLogged ? 'Yes' : 'No',
                activity.weightLogged,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                ctx,
                Icons.straighten,
                'Measurements Logged',
                activity.measurementsLogged ? 'Yes' : 'No',
                activity.measurementsLogged,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: activity.activityScore / 100,
                backgroundColor: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'Activity Score: ${activity.activityScore}%',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isActive,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? color : colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonStreakCard extends StatelessWidget {
  const _SkeletonStreakCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
