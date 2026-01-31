import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../providers/home_nav_provider.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../mood_energy/presentation/providers/mood_energy_providers.dart';
import '../widgets/readiness_ring.dart';
import '../widgets/smart_insight_card.dart';
import '../widgets/bento_metrics_grid.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/todays_plan_section.dart';
import '../widgets/recent_activity_section.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _insightDismissed = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  /// Calculate readiness score based on sleep, energy, and habits
  int _calculateReadinessScore({
    required double sleepHours,
    required int energyLevel,
    required int habitsCompleted,
    required int totalHabits,
  }) {
    // Weights: Sleep 40%, Energy 35%, Habits 25%
    final sleepScore = (sleepHours / 8.0).clamp(0.0, 1.0);
    final energyScore = (energyLevel / 5.0).clamp(0.0, 1.0);
    final habitScore =
        totalHabits > 0 ? (habitsCompleted / totalHabits).clamp(0.0, 1.0) : 0.5;

    final score = (sleepScore * 0.4 + energyScore * 0.35 + habitScore * 0.25) * 100;
    return score.round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final energyLogsAsync = ref.watch(todayEnergyLogsProvider);

    final spacing = context.spacing;
    final sizes = context.sizes;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: sizes.appBarHeight,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Kinesa_App_logo 2.png',
              height: sizes.iconLarge,
              semanticLabel: 'Kinesa logo',
            ),
            SizedBox(width: spacing.sm),
            Text(
              'Kinesa',
              style: TextStyle(
                fontSize: textStyles.titleLarge,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          _buildUserStatusChip(context, userAsync, settings.offlineMode),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: context.colors.textPrimary,
              size: sizes.iconMedium,
            ),
            onPressed: () => context.push(RouteConstants.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(todayEnergyLogsProvider);
          ref.invalidate(todayPlanProvider);
          ref.invalidate(recentActivitiesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, spacing.sm, 0, 100),
          child: MaxWidthContainer(
            maxWidth: 800, // Max width for tablet readability
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HERO LAYER =====
                _buildHeroSection(context, userAsync, statsAsync, energyLogsAsync),

                SizedBox(height: spacing.sectionSpacing),

                // ===== SMART INSIGHT =====
                _buildSmartInsight(context, statsAsync, energyLogsAsync),

                SizedBox(height: spacing.sectionSpacing),

                // ===== BENTO METRICS GRID =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding),
                  child: _buildBentoSection(context, statsAsync, energyLogsAsync),
                ),

                SizedBox(height: spacing.sectionSpacing),

                // ===== QUICK ACTIONS =====
                _buildQuickActionsSection(context),

                SizedBox(height: spacing.sectionSpacing),

                // ===== TODAY'S PLAN =====
                _buildTodaysPlanSection(context),

                SizedBox(height: spacing.sectionSpacing),

                // ===== RECENT ACTIVITY =====
                _buildRecentActivitySection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    AsyncValue<dynamic> userAsync,
    AsyncValue<dynamic> statsAsync,
    AsyncValue<dynamic> energyLogsAsync,
  ) {
    return userAsync.when(
      data: (user) {
        final userName = user?.displayName ??
            user?.email?.split('@').first ??
            'there';

        // Get stats for readiness calculation
        final stats = statsAsync.maybeWhen(
          data: (s) => s,
          orElse: () => null,
        );

        final energyLogs = energyLogsAsync.maybeWhen(
          data: (logs) => logs,
          orElse: () => <dynamic>[],
        );

        final sleepHours = stats?.hoursSlept ?? 0.0;
        final habitsCompleted = stats?.habitsCompleted ?? 0;
        final totalHabits = stats?.totalHabits ?? 0;

        // Get latest energy level
        int energyLevel = 3; // Default
        if (energyLogs.isNotEmpty) {
          final sorted = List.from(energyLogs)
            ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
          energyLevel = sorted.first.energyLevel ?? 3;
        }

        final readinessScore = _calculateReadinessScore(
          sleepHours: sleepHours,
          energyLevel: energyLevel,
          habitsCompleted: habitsCompleted,
          totalHabits: totalHabits,
        );

        return Center(
          child: ReadinessRing(
            score: readinessScore,
            userName: userName,
            onTap: () => context.push(RouteConstants.healthDetails),
          ),
        );
      },
      loading: () => Center(
        child: ReadinessRing(
          score: 0,
          userName: null,
          onTap: null,
        ),
      ),
      error: (_, __) => Center(
        child: ReadinessRing(
          score: 50,
          userName: 'there',
          onTap: () => context.push(RouteConstants.healthDetails),
        ),
      ),
    );
  }

  Widget _buildSmartInsight(
    BuildContext context,
    AsyncValue<dynamic> statsAsync,
    AsyncValue<dynamic> energyLogsAsync,
  ) {
    if (_insightDismissed) {
      return const SizedBox.shrink();
    }

    // Generate insight fresh each time based on current data (live updates)
    final stats = statsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );

    final energyLogs = energyLogsAsync.maybeWhen(
      data: (logs) => logs,
      orElse: () => <dynamic>[],
    );

    SmartInsight? insight;

    if (stats != null) {
      final sleepHours = stats.hoursSlept ?? 0.0;
      final habitsCompleted = stats.habitsCompleted ?? 0;
      final totalHabits = stats.totalHabits ?? 0;
      final workoutsThisWeek = stats.workoutsThisWeek ?? 0;
      final currentStreak = stats.currentStreak ?? 0;

      int energyLevel = 3;
      if (energyLogs.isNotEmpty) {
        final sorted = List.from(energyLogs)
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
        energyLevel = sorted.first.energyLevel ?? 3;
      }

      final readinessScore = _calculateReadinessScore(
        sleepHours: sleepHours,
        energyLevel: energyLevel,
        habitsCompleted: habitsCompleted,
        totalHabits: totalHabits,
      );

      insight = InsightGenerator.generateInsight(
        sleepHours: sleepHours,
        energyLevel: energyLevel,
        workoutsThisWeek: workoutsThisWeek,
        currentStreak: currentStreak,
        habitsCompleted: habitsCompleted,
        totalHabits: totalHabits,
        readinessScore: readinessScore,
      );
    }

    if (insight == null) {
      return const SizedBox.shrink();
    }

    return SmartInsightCard(
      key: ValueKey('insight_${insight.title}'), // Force rebuild when insight changes
      insight: insight,
      onDismiss: () {
        setState(() {
          _insightDismissed = true;
        });
      },
      onAction: () {
        if (insight?.actionRoute != null) {
          context.push(insight!.actionRoute!);
        }
      },
    );
  }

  Widget _buildBentoSection(
    BuildContext context,
    AsyncValue<dynamic> statsAsync,
    AsyncValue<dynamic> energyLogsAsync,
  ) {
    return statsAsync.when(
      data: (stats) {
        final energyLogs = energyLogsAsync.maybeWhen(
          data: (logs) => logs,
          orElse: () => <dynamic>[],
        );

        int energyLevel = 3;
        if (energyLogs.isNotEmpty) {
          final sorted = List.from(energyLogs)
            ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
          energyLevel = sorted.first.energyLevel ?? 3;
        }

        return BentoMetricsGrid(
          sleepHours: stats.hoursSlept ?? 0.0,
          energyLevel: energyLevel,
          steps: stats.stepsToday ?? 0,
          heartRate: null, // TODO: Get from health provider
          habitsCompleted: stats.habitsCompleted ?? 0,
          totalHabits: stats.totalHabits ?? 0,
          workoutsThisWeek: stats.workoutsThisWeek ?? 0,
          sleepDelta: null, // TODO: Calculate sleep delta from average
          onSleepTap: () => context.push(RouteConstants.logSleep),
          onEnergyTap: () => context.push(RouteConstants.logMoodEnergy),
          onStepsTap: () => context.push(RouteConstants.healthDetails),
          onHeartTap: () => context.push(RouteConstants.healthDetails),
          onHabitsTap: () => _openHomeTab(2, RouteConstants.habits),
          onWorkoutsTap: () => _openHomeTab(1, RouteConstants.workouts),
        );
      },
      loading: () => _buildBentoSkeleton(context),
      error: (_, __) => BentoMetricsGrid(
        sleepHours: 0,
        energyLevel: 0,
        steps: 0,
        heartRate: null,
        habitsCompleted: 0,
        totalHabits: 0,
        workoutsThisWeek: 0,
        onSleepTap: () => context.push(RouteConstants.logSleep),
        onEnergyTap: () => context.push(RouteConstants.logMoodEnergy),
        onStepsTap: () => context.push(RouteConstants.healthDetails),
        onHeartTap: () => context.push(RouteConstants.healthDetails),
        onHabitsTap: () => _openHomeTab(2, RouteConstants.habits),
        onWorkoutsTap: () => _openHomeTab(1, RouteConstants.workouts),
      ),
    );
  }

  Widget _buildBentoSkeleton(BuildContext context) {
    final spacing = context.spacing;
    final sizes = context.sizes;
    final largeHeight = sizes.bentoCardMinHeight + 30;
    final smallHeight = sizes.bentoCardMinHeight - 10;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(context, height: largeHeight)),
            SizedBox(width: spacing.gridSpacing),
            Expanded(child: _buildSkeletonCard(context, height: largeHeight)),
          ],
        ),
        SizedBox(height: spacing.gridSpacing),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(context, height: smallHeight)),
            SizedBox(width: spacing.gridSpacing),
            Expanded(child: _buildSkeletonCard(context, height: smallHeight)),
            SizedBox(width: spacing.gridSpacing),
            Expanded(child: _buildSkeletonCard(context, height: smallHeight)),
            SizedBox(width: spacing.gridSpacing),
            Expanded(child: _buildSkeletonCard(context, height: smallHeight)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard(BuildContext context, {required double height}) {
    final sizes = context.sizes;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final actions = [
      QuickAction.logWorkout(() => context.push(RouteConstants.logActivity)),
      QuickAction.aiCoach(() => context.push(RouteConstants.aiCoach)),
      QuickAction.planWeek(() => context.push(RouteConstants.goals)), // Plan → Goals
      QuickAction.unity(() => _openHomeTab(2, RouteConstants.unity)), // Unity tab
      QuickAction.checkIn(() => context.push(RouteConstants.logMoodEnergy)),
      QuickAction.health(() => context.push(RouteConstants.healthDetails)),
      QuickAction.progress(() => _openHomeTab(4, RouteConstants.progress)),
    ];

    return QuickActionsRow(actions: actions);
  }

  Widget _buildTodaysPlanSection(BuildContext context) {
    final planAsync = ref.watch(todayPlanProvider);
    final habits = ref.watch(userHabitsProvider).asData?.value ?? [];
    final habitById = {for (final habit in habits) habit.id: habit};

    return planAsync.when(
      data: (planItems) {
        final tasks = planItems.map((item) {
          return PlanTask(
            id: item.id,
            title: item.title,
            isCompleted: item.isCompleted,
            isActionable: !item.isCompleted,
            route: _getRouteForPlanItem(item.type),
          );
        }).toList();

        return TodaysPlanSection(
          tasks: tasks,
          initiallyExpanded: false,
          onTaskToggle: (task) async {
            final habit = habitById[task.id];
            if (habit != null) {
              final operations = ref.read(habitOperationsProvider.notifier);
              await operations.toggleHabitCompletion(habit);
              ref.invalidate(todayHabitLogsProvider);
              ref.invalidate(todayPlanProvider);
            }
          },
          onTaskTap: (task) {
            if (task.route != null) {
              context.push(task.route!);
            }
          },
        );
      },
      loading: () => TodaysPlanSection(
        tasks: const [],
        initiallyExpanded: false,
      ),
      error: (_, __) => TodaysPlanSection(
        tasks: const [],
        initiallyExpanded: false,
      ),
    );
  }

  String? _getRouteForPlanItem(PlanItemType type) {
    switch (type) {
      case PlanItemType.workout:
        return RouteConstants.workouts;
      case PlanItemType.meditation:
        return RouteConstants.logActivity;
      case PlanItemType.habit:
        return RouteConstants.habits;
      case PlanItemType.walk:
        return RouteConstants.logActivity;
      case PlanItemType.meal:
        return RouteConstants.nutrition;
      case PlanItemType.other:
        return null;
    }
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        final recentActivities = activities.map((activity) {
          return RecentActivity(
            id: activity.id,
            title: activity.title,
            emoji: _getActivityEmoji(activity.type),
            color: _getActivityColor(activity.type),
            timestamp: activity.timestamp,
          );
        }).toList();

        return RecentActivitySection(
          activities: recentActivities,
          onViewAll: () {
            // Navigate to full activity history
            _openHomeTab(4, RouteConstants.progress);
          },
        );
      },
      loading: () => RecentActivitySection(
        activities: const [],
        onViewAll: null,
      ),
      error: (_, __) => RecentActivitySection(
        activities: const [],
        onViewAll: null,
      ),
    );
  }

  String _getActivityEmoji(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return '💪';
      case ActivityType.sleep:
        return '😴';
      case ActivityType.steps:
        return '🚶';
      case ActivityType.habit:
        return '✓';
      case ActivityType.weight:
        return '⚖️';
      case ActivityType.mood:
        return '😊';
      case ActivityType.nutrition:
        return '🍎';
      default:
        return '📊';
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return AppColors.metricWorkouts;
      case ActivityType.sleep:
        return AppColors.metricSleep;
      case ActivityType.steps:
        return AppColors.metricSteps;
      case ActivityType.habit:
        return AppColors.metricHabits;
      case ActivityType.weight:
        return AppColors.metricEnergy;
      case ActivityType.mood:
        return AppColors.metricMood;
      case ActivityType.nutrition:
        return AppColors.metricNutrition;
      default:
        return AppColors.textMutedOnDark;
    }
  }

  void _openHomeTab(int index, String route) {
    ref.read(selectedIndexProvider.notifier).state = index;
    if (context.mounted) {
      context.go(route);
    }
  }

  Widget _buildUserStatusChip(
    BuildContext context,
    AsyncValue<dynamic> userAsync,
    bool offlineMode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return userAsync.when(
      data: (user) {
        final authUser = FirebaseAuth.instance.currentUser;
        final displayName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : authUser?.displayName?.trim().isNotEmpty == true
                ? authUser!.displayName!
                : user?.email?.split('@').first ??
                    authUser?.email?.split('@').first ??
                    'User';
        final photoUrl = user?.photoUrl?.trim().isNotEmpty == true
            ? user!.photoUrl
            : authUser?.photoURL;
        final isOnline = !offlineMode;
        final statusColor = isOnline ? AppColors.success : AppColors.grey;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => context.push(RouteConstants.profile),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: ClipOval(
                          child: photoUrl != null
                              ? Image.network(
                                  photoUrl,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  webHtmlElementStrategy: kIsWeb
                                      ? WebHtmlElementStrategy.prefer
                                      : WebHtmlElementStrategy.never,
                                  errorBuilder: (_, __, ___) => Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
