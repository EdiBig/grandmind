import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Widget for selecting difficulty tier
///
/// Shows three options (Gentle, Steady, Intense) with target values
/// and descriptions.
class TierSelector extends StatelessWidget {
  const TierSelector({
    super.key,
    required this.tiers,
    required this.selectedTier,
    required this.onTierSelected,
    this.unit = '',
    this.showDailyEquivalent = true,
  });

  /// The difficulty tiers configuration
  final DifficultyTiers tiers;

  /// Currently selected tier
  final DifficultyTier selectedTier;

  /// Callback when a tier is selected
  final ValueChanged<DifficultyTier> onTierSelected;

  /// Unit to display after target values
  final String unit;

  /// Whether to show daily equivalent
  final bool showDailyEquivalent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TierOptionCard(
          tier: DifficultyTier.gentle,
          config: tiers.gentle,
          isSelected: selectedTier == DifficultyTier.gentle,
          onTap: () => onTierSelected(DifficultyTier.gentle),
          unit: unit,
          showDailyEquivalent: showDailyEquivalent,
        ),
        const SizedBox(height: 12),
        _TierOptionCard(
          tier: DifficultyTier.steady,
          config: tiers.steady,
          isSelected: selectedTier == DifficultyTier.steady,
          onTap: () => onTierSelected(DifficultyTier.steady),
          unit: unit,
          showDailyEquivalent: showDailyEquivalent,
        ),
        const SizedBox(height: 12),
        _TierOptionCard(
          tier: DifficultyTier.intense,
          config: tiers.intense,
          isSelected: selectedTier == DifficultyTier.intense,
          onTap: () => onTierSelected(DifficultyTier.intense),
          unit: unit,
          showDailyEquivalent: showDailyEquivalent,
        ),
      ],
    );
  }
}

class _TierOptionCard extends StatelessWidget {
  const _TierOptionCard({
    required this.tier,
    required this.config,
    required this.isSelected,
    required this.onTap,
    required this.unit,
    required this.showDailyEquivalent,
  });

  final DifficultyTier tier;
  final TierConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final String unit;
  final bool showDailyEquivalent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTierColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.1)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : theme.colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTierIcon(),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            config.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : null,
                            ),
                          ),
                          if (tier == DifficultyTier.steady) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Recommended',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Target value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatValue(config.targetValue),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : null,
                      ),
                    ),
                    Text(
                      unit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showDailyEquivalent && config.dailyEquivalent != null)
                      Text(
                        '~${_formatValue(config.dailyEquivalent!)}/day',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),

                // Selection indicator
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTierColor() {
    switch (tier) {
      case DifficultyTier.gentle:
        return Colors.green;
      case DifficultyTier.steady:
        return Colors.blue;
      case DifficultyTier.intense:
        return Colors.orange;
    }
  }

  IconData _getTierIcon() {
    switch (tier) {
      case DifficultyTier.gentle:
        return Icons.spa;
      case DifficultyTier.steady:
        return Icons.trending_up;
      case DifficultyTier.intense:
        return Icons.local_fire_department;
    }
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Compact tier selector chips for inline use
class TierSelectorChips extends StatelessWidget {
  const TierSelectorChips({
    super.key,
    required this.selectedTier,
    required this.onTierSelected,
  });

  final DifficultyTier selectedTier;
  final ValueChanged<DifficultyTier> onTierSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: DifficultyTier.values.map((tier) {
        final isSelected = tier == selectedTier;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(tier.displayName),
            selected: isSelected,
            onSelected: (_) => onTierSelected(tier),
            selectedColor: _getTierColor(tier).withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? _getTierColor(tier) : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
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

/// Display-only tier badge
class TierBadge extends StatelessWidget {
  const TierBadge({
    super.key,
    required this.tier,
    this.size = TierBadgeSize.medium,
  });

  final DifficultyTier tier;
  final TierBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTierColor();

    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(),
            size: _getIconSize(),
            color: color,
          ),
          SizedBox(width: _getSpacing()),
          Text(
            tier.displayName,
            style: _getTextStyle(theme)?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor() {
    switch (tier) {
      case DifficultyTier.gentle:
        return Colors.green;
      case DifficultyTier.steady:
        return Colors.blue;
      case DifficultyTier.intense:
        return Colors.orange;
    }
  }

  IconData _getTierIcon() {
    switch (tier) {
      case DifficultyTier.gentle:
        return Icons.spa;
      case DifficultyTier.steady:
        return Icons.trending_up;
      case DifficultyTier.intense:
        return Icons.local_fire_department;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case TierBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case TierBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case TierBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case TierBadgeSize.small:
        return 6;
      case TierBadgeSize.medium:
        return 8;
      case TierBadgeSize.large:
        return 10;
    }
  }

  double _getIconSize() {
    switch (size) {
      case TierBadgeSize.small:
        return 12;
      case TierBadgeSize.medium:
        return 16;
      case TierBadgeSize.large:
        return 20;
    }
  }

  double _getSpacing() {
    switch (size) {
      case TierBadgeSize.small:
        return 2;
      case TierBadgeSize.medium:
        return 4;
      case TierBadgeSize.large:
        return 6;
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case TierBadgeSize.small:
        return theme.textTheme.labelSmall;
      case TierBadgeSize.medium:
        return theme.textTheme.labelMedium;
      case TierBadgeSize.large:
        return theme.textTheme.labelLarge;
    }
  }
}

enum TierBadgeSize { small, medium, large }
