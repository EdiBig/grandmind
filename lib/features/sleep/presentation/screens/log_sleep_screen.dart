import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/sleep_log.dart';
import '../providers/sleep_providers.dart';

class LogSleepScreen extends ConsumerStatefulWidget {
  final SleepLog? existingLog;

  const LogSleepScreen({super.key, this.existingLog});

  @override
  ConsumerState<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends ConsumerState<LogSleepScreen> {
  late double _hoursSlept;
  int? _quality;
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  final Set<String> _selectedTags = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  late DateTime _logDate;

  @override
  void initState() {
    super.initState();
    _logDate = widget.existingLog?.logDate ?? DateTime.now();

    if (widget.existingLog != null) {
      _hoursSlept = widget.existingLog!.hoursSlept;
      _quality = widget.existingLog!.quality;
      _selectedTags.addAll(widget.existingLog!.tags);
      _notesController.text = widget.existingLog!.notes ?? '';

      if (widget.existingLog!.bedTime != null) {
        _bedTime = TimeOfDay.fromDateTime(widget.existingLog!.bedTime!);
      }
      if (widget.existingLog!.wakeTime != null) {
        _wakeTime = TimeOfDay.fromDateTime(widget.existingLog!.wakeTime!);
      }
    } else {
      _hoursSlept = 7.0; // Default
      _quality = null;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    setState(() => _isSubmitting = true);

    try {
      final operations = ref.read(sleepOperationsProvider.notifier);

      // Convert TimeOfDay to DateTime
      DateTime? bedDateTime;
      DateTime? wakeDateTime;

      if (_bedTime != null) {
        bedDateTime = DateTime(
          _logDate.year,
          _logDate.month,
          _logDate.day - 1, // Bed time is usually the night before
          _bedTime!.hour,
          _bedTime!.minute,
        );
        // If bed time is after 12pm, it's same day
        if (_bedTime!.hour >= 12) {
          bedDateTime = DateTime(
            _logDate.year,
            _logDate.month,
            _logDate.day - 1,
            _bedTime!.hour,
            _bedTime!.minute,
          );
        }
      }

      if (_wakeTime != null) {
        wakeDateTime = DateTime(
          _logDate.year,
          _logDate.month,
          _logDate.day,
          _wakeTime!.hour,
          _wakeTime!.minute,
        );
      }

      final success = await operations.logSleep(
        hoursSlept: _hoursSlept,
        quality: _quality,
        bedTime: bedDateTime,
        wakeTime: wakeDateTime,
        tags: _selectedTags.toList(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        logDate: _logDate,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingLog == null ? 'Sleep logged!' : 'Sleep updated!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save sleep log'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLog == null ? 'Log Sleep' : 'Edit Sleep'),
        actions: [
          if (widget.existingLog != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector
            _buildDateSelector(context),
            const SizedBox(height: 24),

            // Hours slept slider
            _buildHoursSection(context),
            const SizedBox(height: 32),

            // Sleep quality
            _buildQualitySection(context),
            const SizedBox(height: 32),

            // Bed time & Wake time
            _buildTimesSection(context),
            const SizedBox(height: 32),

            // Context tags
            _buildTagsSection(context),
            const SizedBox(height: 24),

            // Notes
            _buildNotesSection(context),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.metricSleep,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.existingLog == null ? 'Save Sleep Log' : 'Update Sleep Log',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _logDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _logDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep date',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _isToday(_logDate)
                      ? 'Today (${DateFormat('MMM d').format(_logDate)})'
                      : DateFormat('EEEE, MMM d').format(_logDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildHoursSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hours slept',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.metricSleep.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatHours(_hoursSlept),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.metricSleep,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.metricSleep,
            inactiveTrackColor: AppColors.metricSleep.withValues(alpha: 0.2),
            thumbColor: AppColors.metricSleep,
            overlayColor: AppColors.metricSleep.withValues(alpha: 0.1),
            trackHeight: 8,
          ),
          child: Slider(
            value: _hoursSlept,
            min: 0,
            max: 14,
            divisions: 28, // 0.5 hour increments
            onChanged: (value) {
              setState(() => _hoursSlept = value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0h', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('7h', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('14h', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getSleepFeedback(_hoursSlept),
            style: TextStyle(
              color: _getSleepColor(_hoursSlept),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _getSleepFeedback(double hours) {
    if (hours < 5) return 'Very short - try to get more rest';
    if (hours < 6) return 'Below recommended';
    if (hours < 7) return 'Almost there';
    if (hours <= 9) return 'Great! Within recommended range';
    return 'Long sleep - that\'s okay sometimes';
  }

  Color _getSleepColor(double hours) {
    if (hours < 5) return AppColors.error;
    if (hours < 6) return AppColors.warning;
    if (hours < 7) return Colors.orange;
    if (hours <= 9) return AppColors.success;
    return Colors.blue;
  }

  Widget _buildQualitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep quality',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'How did you feel when you woke up?',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: SleepQuality.values.map((quality) {
            final isSelected = _quality == quality.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _quality = isSelected ? null : quality.value;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.metricSleep.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.metricSleep : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      quality.emoji,
                      style: TextStyle(fontSize: isSelected ? 32 : 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quality.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.metricSleep : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleep times (optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                context,
                icon: Icons.bedtime,
                label: 'Bed time',
                time: _bedTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _bedTime ?? const TimeOfDay(hour: 22, minute: 0),
                  );
                  if (picked != null) {
                    setState(() => _bedTime = picked);
                  }
                },
                onClear: () => setState(() => _bedTime = null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeCard(
                context,
                icon: Icons.wb_sunny_outlined,
                label: 'Wake time',
                time: _wakeTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _wakeTime ?? const TimeOfDay(hour: 7, minute: 0),
                  );
                  if (picked != null) {
                    setState(() => _wakeTime = picked);
                  }
                },
                onClear: () => setState(() => _wakeTime = null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: time != null
              ? Border.all(color: AppColors.metricSleep.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.metricSleep),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    time != null ? time.format(context) : 'Tap to set',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: time != null ? FontWeight.w600 : FontWeight.normal,
                      color: time != null ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (time != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What affected your sleep?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Select all that apply',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SleepTags.all.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.metricSleep.withValues(alpha: 0.2),
              checkmarkColor: AppColors.metricSleep,
              side: BorderSide(
                color: isSelected ? AppColors.metricSleep : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any thoughts about your sleep...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metricSleep),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete sleep log?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.existingLog != null) {
                final operations = ref.read(sleepOperationsProvider.notifier);
                final success = await operations.deleteSleepLog(widget.existingLog!.id);
                if (mounted && success) {
                  Navigator.of(context).pop(true);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
