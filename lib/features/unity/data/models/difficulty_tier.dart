import 'enums.dart';

/// Represents a single difficulty tier configuration
class TierConfig {
  const TierConfig({
    required this.tier,
    required this.name,
    required this.targetValue,
    required this.description,
    this.dailyEquivalent,
  });

  final DifficultyTier tier;
  final String name;
  final double targetValue;
  final String description;
  final double? dailyEquivalent;

  factory TierConfig.fromFirestore(Map<String, dynamic> data) {
    return TierConfig(
      tier: DifficultyTier.values.firstWhere(
        (t) => t.name == data['tier'],
        orElse: () => DifficultyTier.steady,
      ),
      name: data['name'] as String? ?? '',
      targetValue: (data['targetValue'] as num?)?.toDouble() ?? 0,
      description: data['description'] as String? ?? '',
      dailyEquivalent: (data['dailyEquivalent'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tier': tier.name,
      'name': name,
      'targetValue': targetValue,
      'description': description,
      if (dailyEquivalent != null) 'dailyEquivalent': dailyEquivalent,
    };
  }

  TierConfig copyWith({
    DifficultyTier? tier,
    String? name,
    double? targetValue,
    String? description,
    double? dailyEquivalent,
  }) {
    return TierConfig(
      tier: tier ?? this.tier,
      name: name ?? this.name,
      targetValue: targetValue ?? this.targetValue,
      description: description ?? this.description,
      dailyEquivalent: dailyEquivalent ?? this.dailyEquivalent,
    );
  }
}

/// Contains all three difficulty tiers for a challenge
class DifficultyTiers {
  const DifficultyTiers({
    required this.gentle,
    required this.steady,
    required this.intense,
  });

  final TierConfig gentle;
  final TierConfig steady;
  final TierConfig intense;

  /// Create default tiers from a base target value
  factory DifficultyTiers.fromBaseTarget({
    required double baseTarget,
    required String unit,
    int? durationDays,
  }) {
    final dailyBase = durationDays != null && durationDays > 0
        ? baseTarget / durationDays
        : null;

    return DifficultyTiers(
      gentle: TierConfig(
        tier: DifficultyTier.gentle,
        name: 'Gentle',
        targetValue: baseTarget * 0.6,
        description: 'Perfect for building consistency',
        dailyEquivalent: dailyBase != null ? dailyBase * 0.6 : null,
      ),
      steady: TierConfig(
        tier: DifficultyTier.steady,
        name: 'Steady',
        targetValue: baseTarget,
        description: 'A balanced challenge',
        dailyEquivalent: dailyBase,
      ),
      intense: TierConfig(
        tier: DifficultyTier.intense,
        name: 'Intense',
        targetValue: baseTarget * 1.5,
        description: 'Push your limits',
        dailyEquivalent: dailyBase != null ? dailyBase * 1.5 : null,
      ),
    );
  }

  factory DifficultyTiers.fromFirestore(Map<String, dynamic> data) {
    return DifficultyTiers(
      gentle: TierConfig.fromFirestore(
        data['gentle'] as Map<String, dynamic>? ?? {},
      ),
      steady: TierConfig.fromFirestore(
        data['steady'] as Map<String, dynamic>? ?? {},
      ),
      intense: TierConfig.fromFirestore(
        data['intense'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gentle': gentle.toFirestore(),
      'steady': steady.toFirestore(),
      'intense': intense.toFirestore(),
    };
  }

  /// Get the tier config for a specific difficulty
  TierConfig forTier(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.gentle:
        return gentle;
      case DifficultyTier.steady:
        return steady;
      case DifficultyTier.intense:
        return intense;
    }
  }

  /// Get target value for a specific tier
  double targetForTier(DifficultyTier tier) => forTier(tier).targetValue;

  /// Get daily equivalent for a specific tier
  double? dailyEquivalentForTier(DifficultyTier tier) =>
      forTier(tier).dailyEquivalent;
}
