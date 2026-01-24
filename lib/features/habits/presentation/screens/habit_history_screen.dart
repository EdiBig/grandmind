import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../../data/repositories/habit_repository.dart';
import '../widgets/habit_icon_helper.dart';

/// Provider for habit logs with date range
final habitHistoryLogsProvider = FutureProvider.family<List<HabitLog>, HabitHistoryParams>(
  (ref, params) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final repository = ref.watch(habitRepositoryProvider);

    if (params.habitId != null) {
      return repository.getHabitLogs(
        params.habitId!,
        userId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    } else {
      return repository.getUserHabitLogsInRange(
        userId,
        params.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        params.endDate ?? DateTime.now(),
      );
    }
  },
);

class HabitHistoryParams {
  final String? habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  HabitHistoryParams({
    this.habitId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitHistoryParams &&
          runtimeType == other.runtimeType &&
          habitId == other.habitId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(habitId, startDate, endDate);
}

class HabitHistoryScreen extends ConsumerStatefulWidget {
  final String? habitId;
  final DateTime? selectedDate;

  const HabitHistoryScreen({
    super.key,
    this.habitId,
    this.selectedDate,
  });

  @override
  ConsumerState<HabitHistoryScreen> createState() => _HabitHistoryScreenState();
}

class _HabitHistoryScreenState extends ConsumerState<HabitHistoryScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  Habit? _habit;
  Map<String, Habit> _habitsMap = {};
  List<HabitLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _startDate = DateTime(widget.selectedDate!.year, widget.selectedDate!.month, widget.selectedDate!.day);
      _endDate = _startDate.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    } else {
      _endDate = DateTime.now();
      _startDate = _endDate.subtract(const Duration(days: 30));
    }
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

    // Load habits for display
    final habits = await repository.getUserHabits(userId);
    _habitsMap = {for (var h in habits) h.id: h};

    // Load specific habit if provided
    if (widget.habitId != null) {
      _habit = await repository.getHabit(widget.habitId!);
    }

    // Load logs
    if (widget.habitId != null) {
      _logs = await repository.getHabitLogs(
        widget.habitId!,
        userId,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      _logs = await repository.getUserHabitLogsInRange(userId, _startDate, _endDate);
    }

    // Sort by date descending
    _logs.sort((a, b) => b.date.compareTo(a.date));

    setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Future<void> _editLog(HabitLog log) async {
    final habit = _habitsMap[log.habitId];
    if (habit == null) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditLogBottomSheet(
        log: log,
        habit: habit,
      ),
    );

    if (result != null) {
      final repository = ref.read(habitRepositoryProvider);

      if (result['delete'] == true) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await repository.deleteHabitLog(log.id, log.habitId, userId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Log deleted')),
            );
          }
        }
      } else {
        await repository.updateHabitLog(log.id, {
          'count': result['count'],
          'notes': result['notes'],
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log updated')),
          );
        }
      }
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit?.name ?? 'Habit History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Select date range',
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selectedDate != null
                        ? dateFormat.format(_startDate)
                        : '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${_logs.length} entries',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildLogsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habit logs found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date range',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(ThemeData theme) {
    // Group logs by date
    final Map<String, List<HabitLog>> groupedLogs = {};
    final dateFormat = DateFormat('EEEE, MMMM d');

    for (final log in _logs) {
      final dateKey = dateFormat.format(log.date);
      groupedLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedLogs.length,
      itemBuilder: (context, index) {
        final dateKey = groupedLogs.keys.elementAt(index);
        final logsForDate = groupedLogs[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                dateKey,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...logsForDate.map((log) => _buildLogCard(theme, log)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildLogCard(ThemeData theme, HabitLog log) {
    final habit = _habitsMap[log.habitId];
    final color = habit != null ? HabitIconHelper.getColor(habit.color) : AppColors.grey;
    final icon = habit != null ? HabitIconHelper.getIconData(habit.icon) : Icons.check_circle_outline;
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _editLog(log),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit?.name ?? 'Unknown Habit',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeFormat.format(log.completedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (habit != null && habit.targetCount > 0) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${log.count}/${habit.targetCount} ${habit.unit ?? ''}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (log.notes != null && log.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        log.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditLogBottomSheet extends StatefulWidget {
  final HabitLog log;
  final Habit habit;

  const _EditLogBottomSheet({
    required this.log,
    required this.habit,
  });

  @override
  State<_EditLogBottomSheet> createState() => _EditLogBottomSheetState();
}

class _EditLogBottomSheetState extends State<_EditLogBottomSheet> {
  late TextEditingController _countController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: widget.log.count.toString());
    _notesController = TextEditingController(text: widget.log.notes ?? '');
  }

  @override
  void dispose() {
    _countController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = HabitIconHelper.getColor(widget.habit.color);
    final icon = HabitIconHelper.getIconData(widget.habit.icon);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dateFormat.format(widget.log.date)} at ${timeFormat.format(widget.log.completedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Count field (for quantifiable habits)
            if (widget.habit.targetCount > 0) ...[
              Text(
                'Count',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final current = int.tryParse(_countController.text) ?? 0;
                      if (current > 0) {
                        _countController.text = (current - 1).toString();
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        suffix: Text(widget.habit.unit ?? ''),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final current = int.tryParse(_countController.text) ?? 0;
                      _countController.text = (current + 1).toString();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const Spacer(),
                  Text(
                    'Target: ${widget.habit.targetCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Notes field
            Text(
              'Notes (optional)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note about this completion...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Delete button
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Log?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context, {'delete': true});
                            },
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  label: Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
                const Spacer(),
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                // Save button
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'count': int.tryParse(_countController.text) ?? widget.log.count,
                      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
