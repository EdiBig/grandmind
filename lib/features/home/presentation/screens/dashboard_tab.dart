import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../core/constants/route_constants.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../health/presentation/widgets/health_dashboard_card.dart';
import '../../../progress/presentation/widgets/progress_summary_card.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/domain/models/progress_goal.dart';
import '../../../progress/presentation/screens/goals_screen.dart';
import '../../../mood_energy/data/repositories/mood_energy_repository.dart';
import '../../../mood_energy/domain/models/energy_log.dart';
import '../../../mood_energy/presentation/providers/mood_energy_providers.dart';
import '../../../progress/presentation/providers/weekly_summary_provider.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  final TextEditingController _checkInNotesController =
      TextEditingController();
  int? _selectedEnergy;
  final Set<String> _selectedTags = {};
  bool _isSavingCheckIn = false;
  bool _showCheckInForm = false;

  @override
  void dispose() {
    _checkInNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinesa'),
        actions: [
          _buildUserStatusChip(context, userAsync, settings.offlineMode),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildDashboardBackdrop(context),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context, ref),
                const SizedBox(height: 20),
                _buildDailySnapshot(context, ref),
                if (settings.moodEnergyEnabled) ...[
                  const SizedBox(height: 20),
                  _buildDailyCheckIn(context),
                ],
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildFeatureHighlights(context),
                const SizedBox(height: 24),
                _buildMotivationalTip(context, ref),
                const SizedBox(height: 24),
                _buildAICoachCard(context),
                const SizedBox(height: 24),
                _buildTodaySection(context, ref),
                const SizedBox(height: 24),
                _buildRecentActivity(context, ref),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildWelcomeCard(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return userAsync.when(
      data: (user) {
        final coachTone = user?.onboarding?['coachTone'] as String?;
        final email = user?.email;
        final userName = user?.displayName ?? email?.split('@').first;
        final welcomeMessage = MotivationalMessages.getWelcomeMessage(coachTone, userName);
        final subtitleMessage = MotivationalMessages.getSubtitleMessage(coachTone);

        final primary = Theme.of(context).colorScheme.primary;
        final secondary = Theme.of(context).colorScheme.secondary;
        final today = DateFormat('EEE, MMM d').format(DateTime.now());
        final streak = statsAsync.maybeWhen(
          data: (stats) => stats.currentStreak,
          orElse: () => 0,
        );
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary,
                secondary.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      today,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Spacer(),
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '$streak day streak',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                welcomeMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitleMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatusChip(
    BuildContext context,
    AsyncValue<dynamic> userAsync,
    bool offlineMode,
  ) {
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
        final statusColor = isOnline ? Colors.green : Colors.grey;
        final statusText = isOnline ? 'Online' : 'Offline';

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => context.push(RouteConstants.profile),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: ClipOval(
                          child: photoUrl != null
                              ? Image.network(
                                  photoUrl,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  webHtmlElementStrategy: kIsWeb
                                      ? WebHtmlElementStrategy.prefer
                                      : WebHtmlElementStrategy.never,
                                  errorBuilder: (_, __, ___) => Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
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

  Widget _buildDashboardBackdrop(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.surface,
              colors.surface.withValues(alpha: 0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: _buildGlowCircle(
                color: colors.primary.withValues(alpha: 0.2),
                size: 180,
              ),
            ),
            Positioned(
              bottom: 120,
              left: -50,
              child: _buildGlowCircle(
                color: colors.secondary.withValues(alpha: 0.15),
                size: 220,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDailySnapshot(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return statsAsync.when(
      data: (stats) {
        final stepsProgress = _progressValue(stats.stepsToday, 10000);
        final sleepProgress = _progressDouble(stats.hoursSlept, 8);
        final habitsProgress = stats.totalHabits == 0
            ? 0.0
            : stats.habitsCompleted / stats.totalHabits;
        final workoutsProgress = _progressValue(stats.workoutsThisWeek, 5);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Daily Snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Live',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRingMetric(
                      context,
                      icon: Icons.directions_walk,
                      label: 'Steps',
                      value: _formatNumber(stats.stepsToday),
                      progress: stepsProgress,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRingMetric(
                      context,
                      icon: Icons.bedtime,
                      label: 'Sleep',
                      value: '${stats.hoursSlept.toStringAsFixed(1)}h',
                      progress: sleepProgress,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRingMetric(
                      context,
                      icon: Icons.check_circle,
                      label: 'Habits',
                      value:
                          '${stats.habitsCompleted}/${stats.totalHabits == 0 ? '-' : stats.totalHabits}',
                      progress: habitsProgress,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRingMetric(
                      context,
                      icon: Icons.fitness_center,
                      label: 'Workouts',
                      value: '${stats.workoutsThisWeek}',
                      progress: workoutsProgress,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildSnapshotSkeleton(context),
      error: (_, __) => _buildSnapshotSkeleton(context),
    );
  }

  Widget _buildDailyCheckIn(BuildContext context) {
    final logsAsync = ref.watch(todayEnergyLogsProvider);
    return logsAsync.when(
      loading: () => _buildCheckInCard(
        context,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCheckInCard(
        context,
        child: Text(
          'Unable to load today\'s check-in.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
      data: (logs) {
        final latestLog = _latestEnergyLog(logs);
        final hasLog = latestLog != null;
        final showForm = _showCheckInForm || !hasLog;

        return _buildCheckInCard(
          context,
          statusLabel: hasLog ? 'Saved today' : null,
          child: showForm
              ? _buildCheckInForm(context)
              : _buildCheckInSummary(context, latestLog!),
        );
      },
    );
  }

  Widget _buildCheckInCard(
    BuildContext context, {
    required Widget child,
    String? statusLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daily Check-In',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (statusLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckInForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How\'s your energy right now?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(5, (index) {
            final level = index + 1;
            final selected = _selectedEnergy == level;
            return ChoiceChip(
              label: Text('$level'),
              selected: selected,
              onSelected: (_) => setState(() => _selectedEnergy = level),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Add a mood tag',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _buildMoodTags(context),
        ),
        const SizedBox(height: 16),
        Text(
          'Notes (optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _checkInNotesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What\'s contributing to your energy today?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedEnergy == null || _isSavingCheckIn
                ? null
                : () => _saveDailyCheckIn(context),
            child: _isSavingCheckIn
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Check-In'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMoodTags(BuildContext context) {
    const tags = ['Stressed', 'Tired', 'Great', 'Calm', 'Sick'];
    return tags.map((tag) {
      final selected = _selectedTags.contains(tag);
      return FilterChip(
        label: Text(tag),
        selected: selected,
        onSelected: (value) {
          setState(() {
            if (value) {
              _selectedTags.add(tag);
            } else {
              _selectedTags.remove(tag);
            }
          });
        },
      );
    }).toList();
  }

  Widget _buildCheckInSummary(BuildContext context, EnergyLog log) {
    final avg = log.averageEnergy?.toStringAsFixed(1) ?? '--';
    final tags = log.tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy: $avg/5',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: tags.map((tag) => Chip(label: Text(tag))).toList(),
          )
        else
          Text(
            'No mood tags logged yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _showCheckInForm = true),
            child: const Text('Update check-in'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveDailyCheckIn(BuildContext context) async {
    if (_selectedEnergy == null) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to check in.')),
      );
      return;
    }

    setState(() => _isSavingCheckIn = true);
    try {
      final repository = ref.read(moodEnergyRepositoryProvider);
      final log = EnergyLog(
        id: '',
        userId: userId,
        loggedAt: DateTime.now(),
        energyBefore: _selectedEnergy,
        tags: _selectedTags.toList(),
        notes: _checkInNotesController.text.trim().isEmpty
            ? null
            : _checkInNotesController.text.trim(),
        source: 'daily_checkin',
      );
      await repository.logEnergy(log);
      setState(() {
        _checkInNotesController.clear();
        _selectedTags.clear();
        _selectedEnergy = null;
        _showCheckInForm = false;
      });
      ref.invalidate(todayEnergyLogsProvider);
      ref.invalidate(weeklyEnergyLogsProvider);
      ref.invalidate(previousWeeklyEnergyLogsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily check-in saved!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save check-in: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingCheckIn = false);
      }
    }
  }

  EnergyLog? _latestEnergyLog(List<EnergyLog> logs) {
    if (logs.isEmpty) return null;
    final sorted = List<EnergyLog>.from(logs)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return sorted.first;
  }

  Widget _buildSnapshotSkeleton(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSkeletonTile()),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonTile()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSkeletonTile()),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonTile()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonTile() {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildRingMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _DashboardAction(
        label: 'Plan',
        icon: Icons.add_task,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.push(RouteConstants.logActivity),
      ),
      _DashboardAction(
        label: 'Coach',
        icon: Icons.psychology,
        color: Colors.deepPurple,
        onTap: () => context.push(RouteConstants.aiCoach),
      ),
      _DashboardAction(
        label: 'Workouts',
        icon: Icons.fitness_center,
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => context.push(RouteConstants.workouts),
      ),
      _DashboardAction(
        label: 'Progress',
        icon: Icons.show_chart,
        color: Theme.of(context).colorScheme.tertiary,
        onTap: () => context.push(RouteConstants.progress),
      ),
      _DashboardAction(
        label: 'Health',
        icon: Icons.favorite,
        color: Colors.redAccent,
        onTap: () => context.push(RouteConstants.healthDetails),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) =>
                _buildActionCard(context, actions[index]),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: actions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, _DashboardAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: action.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Health',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const HealthDashboardCard(),
        const SizedBox(height: 16),
        const ProgressSummaryCard(),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activeGoalsAsync = ref.watch(activeGoalsProvider);
    final allGoalsAsync = ref.watch(allGoalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Workouts',
                      '${stats.workoutsThisWeek}',
                      'This week',
                      Icons.fitness_center,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Habits',
                      '${stats.habitCompletionRate.toStringAsFixed(0)}%',
                      'Completion',
                      Icons.track_changes,
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGoalStatCard(context, activeGoalsAsync, allGoalsAsync),
            ],
          ),
          loading: () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Workouts',
                      '...',
                      'This week',
                      Icons.fitness_center,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Habits',
                      '...',
                      'Completion',
                      Icons.track_changes,
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGoalStatCard(context, activeGoalsAsync, allGoalsAsync),
            ],
          ),
          error: (_, __) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Workouts',
                      '0',
                      'This week',
                      Icons.fitness_center,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Habits',
                      '0%',
                      'Completion',
                      Icons.track_changes,
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildGoalStatCard(context, activeGoalsAsync, allGoalsAsync),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalStatCard(
    BuildContext context,
    AsyncValue<List<ProgressGoal>> activeGoalsAsync,
    AsyncValue<List<ProgressGoal>> allGoalsAsync,
  ) {
    final color = Theme.of(context).colorScheme.tertiary;

    if (activeGoalsAsync.isLoading || allGoalsAsync.isLoading) {
      return _buildStatCard(
        context,
        'Goals',
        '...',
        'Active goals',
        Icons.flag,
        color,
      );
    }

    if (activeGoalsAsync.hasError || allGoalsAsync.hasError) {
      return _buildStatCard(
        context,
        'Goals',
        '0',
        'Active goals',
        Icons.flag,
        color,
      );
    }

    final activeGoals = activeGoalsAsync.asData?.value ?? [];
    final allGoals = allGoalsAsync.asData?.value ?? [];
    final completedGoals =
        allGoals.where((goal) => goal.status == GoalStatus.completed).length;
    final totalGoals = allGoals.length;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GoalsScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: _buildStatCard(
        context,
        'Goals',
        '${activeGoals.length}',
        totalGoals > 0
            ? '$completedGoals of $totalGoals completed'
            : 'Active goals',
        Icons.flag,
        color,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalTip(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return userAsync.when(
      data: (user) {
        final coachTone = user?.onboarding?['coachTone'] as String?;

        return statsAsync.when(
          data: (stats) {
            final streakMessage = MotivationalMessages.getStreakMessage(stats.currentStreak, coachTone);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Motivation',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streakMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTodaySection(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todayPlanProvider);
    final habits = ref.read(userHabitsProvider).value ?? [];
    final habitById = {for (final habit in habits) habit.id: habit};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Plan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        planAsync.when(
          data: (planItems) {
            if (planItems.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Text(
                    'No activities planned for today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            }

            return Column(
              children: planItems.map((item) {
                final icon = _getPlanItemIcon(item.type);
                final color = _getPlanItemColor(context, item.type);
                final time = item.scheduledTime != null
                    ? DateFormat('h:mm a').format(item.scheduledTime!)
                    : '';
                final habit = item.type == PlanItemType.habit
                    ? habitById[item.id]
                    : null;
                final canCompleteGoal =
                    item.type == PlanItemType.other && !item.isCompleted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTodayItem(
                    context,
                    item.title,
                    time,
                    item.description,
                    icon,
                    color,
                    item.isCompleted,
                    onToggle: habit == null
                        ? (canCompleteGoal
                            ? () async {
                                final operations = ref.read(
                                  progressOperationsProvider.notifier,
                                );
                                await operations.completeGoal(item.id);
                              }
                            : null)
                        : () async {
                            final operations =
                                ref.read(habitOperationsProvider.notifier);
                            await operations.toggleHabitCompletion(habit);
                            ref.invalidate(todayHabitLogsProvider);
                          },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Center(child: Text('Error loading today\'s plan')),
          ),
        ),
      ],
    );
  }

  IconData _getPlanItemIcon(PlanItemType type) {
    switch (type) {
      case PlanItemType.workout:
        return Icons.fitness_center;
      case PlanItemType.meditation:
        return Icons.self_improvement;
      case PlanItemType.walk:
        return Icons.directions_walk;
      case PlanItemType.habit:
        return Icons.track_changes;
      case PlanItemType.meal:
        return Icons.restaurant;
      default:
        return Icons.task_alt;
    }
  }

  Color _getPlanItemColor(BuildContext context, PlanItemType type) {
    switch (type) {
      case PlanItemType.workout:
        return Theme.of(context).colorScheme.primary;
      case PlanItemType.meditation:
        return Theme.of(context).colorScheme.secondary;
      case PlanItemType.walk:
        return Theme.of(context).colorScheme.tertiary;
      case PlanItemType.habit:
        return Colors.green;
      case PlanItemType.meal:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTodayItem(
    BuildContext context,
    String title,
    String time,
    String subtitle,
    IconData icon,
    Color color,
    bool completed,
    {VoidCallback? onToggle}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration:
                                  completed ? TextDecoration.lineThrough : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: completed
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                      onPressed: onToggle,
                      tooltip: onToggle == null ? null : 'Mark complete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Text(
                    'No recent activities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            }

            return Column(
              children: activities.take(3).map((activity) {
                final icon = _getActivityIcon(activity.type);
                final color = _getActivityColor(context, activity.type);
                final timeAgo = _formatTimeAgo(activity.timestamp);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildActivityItem(
                    context,
                    activity.title,
                    timeAgo,
                    icon,
                    color,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Center(child: Text('Error loading activities')),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return Icons.fitness_center;
      case ActivityType.sleep:
        return Icons.bedtime;
      case ActivityType.steps:
        return Icons.directions_walk;
      case ActivityType.habit:
        return Icons.check_circle;
      case ActivityType.weight:
        return Icons.monitor_weight;
      case ActivityType.mood:
        return Icons.sentiment_satisfied;
      case ActivityType.nutrition:
        return Icons.restaurant;
      default:
        return Icons.local_activity;
    }
  }

  Color _getActivityColor(BuildContext context, ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return Theme.of(context).colorScheme.primary;
      case ActivityType.sleep:
        return Theme.of(context).colorScheme.secondary;
      case ActivityType.steps:
        return Theme.of(context).colorScheme.tertiary;
      case ActivityType.habit:
        return Colors.green;
      case ActivityType.weight:
        return Colors.orange;
      case ActivityType.mood:
        return Colors.purple;
      case ActivityType.nutrition:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.aiCoach),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400,
              Colors.deepPurple.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Fitness Coach',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get personalized workout recommendations and expert guidance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Chat Now',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    return NumberFormat.decimalPattern().format(value);
  }

  double _progressValue(int value, int target) {
    if (target == 0) {
      return 0.0;
    }
    return math.min(value / target, 1.0);
  }

  double _progressDouble(double value, double target) {
    if (target == 0) {
      return 0.0;
    }
    return math.min(value / target, 1.0);
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
