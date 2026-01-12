import 'package:flutter/material.dart';
import 'package:kinesa/features/ai/data/models/ai_conversation_model.dart';

/// Quick action chips for common AI coach requests
class QuickActionChips extends StatelessWidget {
  final Function(QuickAction) onActionTap;

  const QuickActionChips({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QuickActions.fitnessCoach
                .map((action) => _buildActionChip(context, action))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, QuickAction action) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Text(
        action.icon,
        style: const TextStyle(fontSize: 18),
      ),
      label: Text(action.label),
      tooltip: action.description,
      onPressed: () => onActionTap(action),
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }
}
