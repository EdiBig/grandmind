import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Card widget for selecting a difficulty tier
class TierSelectionCard extends StatelessWidget {
  const TierSelectionCard({
    super.key,
    required this.tier,
    required this.tierConfig,
    required this.isSelected,
    required this.onTap,
  });

  final DifficultyTier tier;
  final TierConfig? tierConfig;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTierColor(tier);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    tier.displayName[0],
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tierConfig?.name ?? tier.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tierConfig?.description ?? tier.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (tierConfig != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tierConfig!.targetValue.toStringAsFixed(0),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? color : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.gentle:
        return Colors.green;
      case DifficultyTier.steady:
        return Colors.blue;
      case DifficultyTier.intense:
        return Colors.orange;
    }
  }
}
