import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../../data/repositories/habit_repository.dart';
import '../widgets/habit_icon_helper.dart';

/// Provider for habit logs in a date range (for calendar view)
final calendarHabitLogsProvider = FutureProvider.family<List<HabitLog>, DateTimeRange>(
  (ref, range) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final repository = ref.watch(habitRepositoryProvider);
    return repository.getUserHabitLogsInRange(userId, range.start, range.end);
  },
);

class HabitCalendarScreen extends ConsumerStatefulWidget {
  final String? habitId; // Optional: filter for specific habit

  const HabitCalendarScreen({super.key, this.habitId});

  @override
  ConsumerState<HabitCalendarScreen> createState() => _HabitCalendarScreenState();
}

class _HabitCalendarScreenState extends ConsumerState<HabitCalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  List<Habit> _habits = [];
  final Map<DateTime, List<HabitLog>> _logsByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final repository = ref.read(habitRepositoryProvider);

    // Load habits
    _habits = await repository.getUserHabits(userId, isActive: true);

    // Load logs for the current month view (with buffer for edge days)
    await _loadLogsForMonth(_focusedMonth);

    setState(() => _isLoading = false);
  }

  Future<void> _loadLogsForMonth(DateTime month) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final repository = ref.read(habitRepositoryProvider);

    // Get first day of month and last day of month with buffer
    final firstDay = DateTime(month.year, month.month, 1).subtract(const Duration(days: 7));
    final lastDay = DateTime(month.year, month.month + 1, 0).add(const Duration(days: 7));

    final logs = await repository.getUserHabitLogsInRange(userId, firstDay, lastDay);

    // Group logs by date
    _logsByDate.clear();
    for (final log in logs) {
      // Filter by habit if specified
      if (widget.habitId != null && log.habitId != widget.habitId) continue;

      final dateKey = DateTime(log.date.year, log.date.month, log.date.day);
      _logsByDate.putIfAbsent(dateKey, () => []).add(log);
    }

    setState(() {});
  }

  void _onMonthChanged(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
      _selectedDay = null;
    });
    _loadLogsForMonth(_focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId != null ? 'Habit Calendar' : 'All Habits Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthHeader(theme),
                _buildWeekdayHeader(theme),
                Expanded(
                  child: _buildCalendarGrid(theme),
                ),
                if (_selectedDay != null) _buildSelectedDayDetails(theme),
              ],
            ),
    );
  }

  Widget _buildMonthHeader(ThemeData theme) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _onMonthChanged(-1),
          ),
          Text(
            '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _focusedMonth.isBefore(DateTime.now())
                ? () => _onMonthChanged(1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // Adjust for Monday start (1 = Monday, 7 = Sunday)
    int startWeekday = firstDayOfMonth.weekday - 1; // 0 = Monday

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - startWeekday;

        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          // Days outside current month
          return const SizedBox.shrink();
        }

        final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset + 1);
        return _buildDayCell(theme, day);
      },
    );
  }

  Widget _buildDayCell(ThemeData theme, DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final logsForDay = _logsByDate[dateKey] ?? [];
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _selectedDay != null && _isSameDay(day, _selectedDay!);
    final isFuture = day.isAfter(DateTime.now());

    // Calculate completion rate for the day
    final totalActiveHabits = widget.habitId != null ? 1 : _habits.length;
    final completedHabits = logsForDay.map((l) => l.habitId).toSet().length;
    final completionRate = totalActiveHabits > 0 ? completedHabits / totalActiveHabits : 0.0;

    // Get intensity color based on completion rate
    Color cellColor;
    if (isFuture) {
      cellColor = theme.colorScheme.surfaceContainerHighest;
    } else if (completionRate >= 1.0) {
      cellColor = AppColors.success.withValues(alpha: 0.9);
    } else if (completionRate >= 0.75) {
      cellColor = AppColors.success.withValues(alpha: 0.7);
    } else if (completionRate >= 0.5) {
      cellColor = AppColors.success.withValues(alpha: 0.5);
    } else if (completionRate > 0) {
      cellColor = AppColors.success.withValues(alpha: 0.3);
    } else {
      cellColor = theme.colorScheme.surfaceContainerHighest;
    }

    return GestureDetector(
      onTap: isFuture ? null : () {
        setState(() {
          _selectedDay = _isSameDay(_selectedDay, day) ? null : day;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isToday
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isFuture
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : completionRate > 0.5
                          ? AppColors.white
                          : theme.colorScheme.onSurface,
                ),
              ),
              if (logsForDay.isNotEmpty && !isFuture)
                Text(
                  '$completedHabits/$totalActiveHabits',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: completionRate > 0.5
                        ? AppColors.white.withValues(alpha: 0.9)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(ThemeData theme) {
    final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final logsForDay = _logsByDate[dateKey] ?? [];

    // Get unique habit IDs that were completed
    final completedHabitIds = logsForDay.map((l) => l.habitId).toSet();

    // Get habits that were NOT completed
    final incompletedHabits = _habits.where((h) =>
      (widget.habitId == null || h.id == widget.habitId) &&
      !completedHabitIds.contains(h.id)
    ).toList();

    // Get habits that were completed with their logs
    final completedHabitsWithLogs = <Habit, HabitLog>{};
    for (final log in logsForDay) {
      final habit = _habits.firstWhere(
        (h) => h.id == log.habitId,
        orElse: () => Habit(
          id: log.habitId,
          userId: log.userId,
          name: 'Unknown Habit',
          description: '',
          frequency: HabitFrequency.daily,
          icon: HabitIcon.other,
          color: HabitColor.blue,
          createdAt: DateTime.now(),
        ),
      );
      if (widget.habitId == null || habit.id == widget.habitId) {
        completedHabitsWithLogs[habit] = log;
      }
    }

    final formattedDate = _formatDate(_selectedDay!);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to history for this day
                    context.push('/habits/history', extra: _selectedDay);
                  },
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('View Details'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (completedHabitsWithLogs.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Completed', Icons.check_circle, AppColors.success),
                  ...completedHabitsWithLogs.entries.map((entry) =>
                    _buildHabitTile(theme, entry.key, entry.value, true)
                  ),
                  const SizedBox(height: 16),
                ],
                if (incompletedHabits.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Missed', Icons.cancel, AppColors.error),
                  ...incompletedHabits.map((habit) =>
                    _buildHabitTile(theme, habit, null, false)
                  ),
                ],
                if (completedHabitsWithLogs.isEmpty && incompletedHabits.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No habits tracked for this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTile(ThemeData theme, Habit habit, HabitLog? log, bool completed) {
    final color = HabitIconHelper.getColor(habit.color);
    final icon = HabitIconHelper.getIconData(habit.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (log != null && habit.targetCount > 0)
                  Text(
                    '${log.count}/${habit.targetCount} ${habit.unit ?? ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? AppColors.success : AppColors.error.withValues(alpha: 0.5),
            size: 24,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final isToday = _isSameDay(date, DateTime.now());
    final isYesterday = _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
