import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Bottom sheet for selecting cheer type
///
/// Shows a grid of 6 CheerType options with emoji and label,
/// plus an optional message input.
class CheerSelector extends StatefulWidget {
  const CheerSelector({
    super.key,
    required this.onCheerSelected,
    this.showMessageInput = true,
    this.recipientName,
  });

  /// Callback when a cheer is selected
  final void Function(CheerType type, String? message) onCheerSelected;

  /// Whether to show the optional message input
  final bool showMessageInput;

  /// Name of the recipient (for display)
  final String? recipientName;

  /// Show the cheer selector as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required void Function(CheerType type, String? message) onCheerSelected,
    bool showMessageInput = true,
    String? recipientName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CheerSelector(
        onCheerSelected: onCheerSelected,
        showMessageInput: showMessageInput,
        recipientName: recipientName,
      ),
    );
  }

  @override
  State<CheerSelector> createState() => _CheerSelectorState();
}

class _CheerSelectorState extends State<CheerSelector> {
  CheerType? _selectedType;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_selectedType != null) {
      final message = _messageController.text.trim();
      widget.onCheerSelected(
        _selectedType!,
        message.isNotEmpty ? message : null,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.recipientName != null
                ? 'Send a cheer to ${widget.recipientName}'
                : 'Send a cheer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how you want to encourage them',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Cheer type grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: CheerType.values.map((type) {
              return _CheerTypeCard(
                type: type,
                isSelected: _selectedType == type,
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
              );
            }).toList(),
          ),

          // Message input
          if (widget.showMessageInput) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Add a personal message (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              maxLength: 150,
            ),
          ],

          const SizedBox(height: 16),

          // Send button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedType != null ? _handleSend : null,
              child: const Text('Send Cheer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheerTypeCard extends StatelessWidget {
  const _CheerTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final CheerType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                type.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline cheer type selector (horizontal scroll)
class CheerTypeSelector extends StatelessWidget {
  const CheerTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final CheerType? selectedType;
  final ValueChanged<CheerType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CheerType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = CheerType.values[index];
          return _CheerTypeChip(
            type: type,
            isSelected: selectedType == type,
            onTap: () => onTypeSelected(type),
          );
        },
      ),
    );
  }
}

class _CheerTypeChip extends StatelessWidget {
  const _CheerTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final CheerType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              type.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
