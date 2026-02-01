import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Card widget for logging a rest day
///
/// Includes reason selector, optional note input, and encouraging message.
class RestDayCard extends StatefulWidget {
  const RestDayCard({
    super.key,
    required this.onSubmit,
    this.allowedReasons,
    this.restDaysRemaining,
    this.maxRestDaysPerWeek = 2,
  });

  /// Callback when rest day is submitted
  final void Function(RestDayReason reason, String? note) onSubmit;

  /// Allowed reasons (if null, all reasons are available)
  final List<RestDayReason>? allowedReasons;

  /// Number of rest days remaining this week
  final int? restDaysRemaining;

  /// Maximum rest days allowed per week
  final int maxRestDaysPerWeek;

  @override
  State<RestDayCard> createState() => _RestDayCardState();
}

class _RestDayCardState extends State<RestDayCard> {
  RestDayReason? _selectedReason;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<RestDayReason> get _availableReasons =>
      widget.allowedReasons ?? RestDayReason.values;

  void _handleSubmit() {
    if (_selectedReason != null) {
      final note = _noteController.text.trim();
      widget.onSubmit(_selectedReason!, note.isNotEmpty ? note : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Rest Day',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.restDaysRemaining != null)
                        Text(
                          '${widget.restDaysRemaining} of ${widget.maxRestDaysPerWeek} remaining this week',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Encouraging message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rest days are part of progress. Your streak is protected!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reason selector
            Text(
              'What type of rest day?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return _ReasonChip(
                  reason: reason,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedReason = reason;
                    });
                  },
                );
              }).toList(),
            ),

            // Selected reason encouragement
            if (_selectedReason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text(
                      '\u{1F33F}', // Herb/plant emoji
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedReason!.encouragement,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Optional note
            Text(
              'Add a note (optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'How are you feeling?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              maxLength: 200,
            ),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedReason != null ? _handleSubmit : null,
                child: const Text('Log Rest Day'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final RestDayReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.green
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getReasonIcon(reason),
                size: 18,
                color: isSelected ? Colors.green : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                reason.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getReasonIcon(RestDayReason reason) {
    switch (reason) {
      case RestDayReason.scheduledRest:
        return Icons.calendar_today;
      case RestDayReason.feelingUnwell:
        return Icons.sick;
      case RestDayReason.mentalHealth:
        return Icons.psychology;
      case RestDayReason.lifeHappens:
        return Icons.home;
      case RestDayReason.injury:
        return Icons.healing;
      case RestDayReason.other:
        return Icons.more_horiz;
    }
  }
}

/// Compact rest day button for quick access
class RestDayButton extends StatelessWidget {
  const RestDayButton({
    super.key,
    required this.onTap,
    this.restDaysRemaining,
  });

  final VoidCallback onTap;
  final int? restDaysRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.spa, size: 18),
      label: Text(
        restDaysRemaining != null
            ? 'Rest Day ($restDaysRemaining left)'
            : 'Rest Day',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.green,
        side: const BorderSide(color: Colors.green),
      ),
    );
  }
}

/// Rest day status indicator
class RestDayIndicator extends StatelessWidget {
  const RestDayIndicator({
    super.key,
    required this.reason,
  });

  final RestDayReason reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.spa,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            'Rest Day',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${reason.displayName})',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}
