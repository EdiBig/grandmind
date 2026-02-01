import '../models/models.dart';

/// Service for adaptive challenge features based on energy/readiness
///
/// Implements the Unity philosophy: "Progress together, at your own pace"
/// Challenges adjust to YOUR energy and capacity.
class AdaptiveChallengeService {
  /// Get daily target adjusted for readiness/energy level
  ///
  /// Readiness score ranges from 0-100:
  /// - <30: Rest day level (40% of base) - Your body needs recovery
  /// - 30-49: Easy day (60% of base) - Take it gentle today
  /// - 50-69: Moderate day (80% of base) - Steady progress
  /// - 70-84: Normal day (100% base) - You're feeling good!
  /// - 85+: Push day (120% of base) - You're ready to challenge yourself!
  double getDailyTarget(double baseTarget, double readinessScore) {
    final multiplier = getTargetMultiplier(readinessScore);
    return baseTarget * multiplier;
  }

  /// Get target multiplier based on readiness score
  double getTargetMultiplier(double readinessScore) {
    if (readinessScore >= 85) {
      return 1.2; // Push day
    } else if (readinessScore >= 70) {
      return 1.0; // Normal day
    } else if (readinessScore >= 50) {
      return 0.8; // Moderate day
    } else if (readinessScore >= 30) {
      return 0.6; // Easy day
    } else {
      return 0.4; // Rest day level
    }
  }

  /// Get progress multiplier for bonus credit on high-energy days
  ///
  /// When you push yourself on a high-energy day, you earn bonus progress.
  /// This rewards effort while respecting that not every day is a push day.
  double getProgressMultiplier(double readinessScore) {
    if (readinessScore >= 90) {
      return 1.2; // 20% bonus
    } else if (readinessScore >= 80) {
      return 1.1; // 10% bonus
    } else {
      return 1.0; // Standard progress
    }
  }

  /// Calculate adaptive progress value
  ///
  /// Takes raw progress value and applies bonus based on readiness.
  double calculateAdaptiveProgress(double rawValue, double readinessScore) {
    final multiplier = getProgressMultiplier(readinessScore);
    return rawValue * multiplier;
  }

  /// Get the day type description based on readiness
  DayType getDayType(double readinessScore) {
    if (readinessScore >= 85) {
      return DayType.push;
    } else if (readinessScore >= 70) {
      return DayType.normal;
    } else if (readinessScore >= 50) {
      return DayType.moderate;
    } else if (readinessScore >= 30) {
      return DayType.easy;
    } else {
      return DayType.rest;
    }
  }

  /// Get personalized message based on readiness and context
  String getReadinessMessage(double readinessScore, {bool hasStreak = false}) {
    final dayType = getDayType(readinessScore);

    switch (dayType) {
      case DayType.push:
        return hasStreak
            ? "You're on fire! Great streak and high energy today."
            : "Energy levels are high - a great day to push yourself!";
      case DayType.normal:
        return hasStreak
            ? "Solid energy. Keep that streak going!"
            : "You're feeling good. A normal day of progress ahead.";
      case DayType.moderate:
        return hasStreak
            ? "Take it steady today. Your streak is safe."
            : "A moderate effort day. Listen to your body.";
      case DayType.easy:
        return hasStreak
            ? "Go easy - your streak won't break from a light day."
            : "Your body wants rest. A gentle day is still progress.";
      case DayType.rest:
        return hasStreak
            ? "Rest is part of the journey. Your streak is protected."
            : "Your body is asking for recovery. Honor that.";
    }
  }

  /// Get suggested activity level based on readiness
  ActivitySuggestion getSuggestedActivity(
    double readinessScore,
    MetricType metricType,
  ) {
    final dayType = getDayType(readinessScore);
    final multiplier = getTargetMultiplier(readinessScore);

    String suggestion;
    String icon;

    switch (dayType) {
      case DayType.push:
        suggestion = 'High intensity - push your limits today';
        icon = '\u{1F525}'; // Fire
        break;
      case DayType.normal:
        suggestion = 'Standard effort - solid progress';
        icon = '\u{1F4AA}'; // Flexed biceps
        break;
      case DayType.moderate:
        suggestion = 'Moderate effort - steady wins the race';
        icon = '\u{1F3C3}'; // Runner
        break;
      case DayType.easy:
        suggestion = 'Light activity - gentle movement';
        icon = '\u{1F6B6}'; // Walker
        break;
      case DayType.rest:
        suggestion = 'Active recovery or complete rest';
        icon = '\u{1F33F}'; // Seedling
        break;
    }

    return ActivitySuggestion(
      dayType: dayType,
      multiplier: multiplier,
      suggestion: suggestion,
      icon: icon,
    );
  }

  /// Determine if user should be encouraged to take a rest day
  bool shouldSuggestRestDay({
    required double readinessScore,
    required int currentStreak,
    required int recentActiveDays,
    required int restDaysUsedThisWeek,
    required int maxRestDaysPerWeek,
  }) {
    // Always respect low readiness
    if (readinessScore < 30) {
      return true;
    }

    // Suggest rest after long streaks without rest
    if (currentStreak >= 7 && restDaysUsedThisWeek == 0) {
      return readinessScore < 60;
    }

    // Check recent activity density
    if (recentActiveDays >= 5 && restDaysUsedThisWeek < maxRestDaysPerWeek) {
      return readinessScore < 50;
    }

    return false;
  }

  /// Get adaptive tier recommendation based on user's history
  DifficultyTier recommendTier({
    required double averageReadiness,
    required double completionRate,
    required int totalChallengesCompleted,
    DifficultyTier? previousTier,
  }) {
    // New users start with gentle or steady
    if (totalChallengesCompleted == 0) {
      if (averageReadiness >= 70) {
        return DifficultyTier.steady;
      }
      return DifficultyTier.gentle;
    }

    // Consider previous performance
    if (completionRate >= 0.9 && averageReadiness >= 75) {
      // High performer - can handle more
      if (previousTier == DifficultyTier.gentle) {
        return DifficultyTier.steady;
      } else if (previousTier == DifficultyTier.steady) {
        return DifficultyTier.intense;
      }
      return DifficultyTier.intense;
    } else if (completionRate >= 0.7) {
      // Good performer - stay or slight increase
      return previousTier ?? DifficultyTier.steady;
    } else if (completionRate >= 0.5) {
      // Moderate performer - consider stepping down
      if (previousTier == DifficultyTier.intense) {
        return DifficultyTier.steady;
      }
      return previousTier ?? DifficultyTier.gentle;
    } else {
      // Struggling - recommend easier tier
      return DifficultyTier.gentle;
    }
  }

  /// Calculate "banked" progress from overachieving days
  ///
  /// When users exceed their daily target, the extra can be "banked"
  /// to help on lower-energy days. This encourages consistency over perfection.
  double calculateBankedProgress({
    required double dailyProgress,
    required double dailyTarget,
    required double currentBankedProgress,
    double maxBankDays = 3.0,
  }) {
    final excess = dailyProgress - dailyTarget;
    if (excess <= 0) return currentBankedProgress;

    // Can bank up to 3 days worth of progress
    final maxBank = dailyTarget * maxBankDays;
    return (currentBankedProgress + excess).clamp(0, maxBank);
  }

  /// Use banked progress to supplement a low-energy day
  BankWithdrawalResult withdrawFromBank({
    required double dailyProgress,
    required double dailyTarget,
    required double bankedProgress,
  }) {
    final shortfall = dailyTarget - dailyProgress;

    if (shortfall <= 0 || bankedProgress <= 0) {
      return BankWithdrawalResult(
        withdrawnAmount: 0,
        remainingBank: bankedProgress,
        effectiveProgress: dailyProgress,
        targetMet: dailyProgress >= dailyTarget,
      );
    }

    // Withdraw what we need, up to what's available
    final withdrawal = shortfall.clamp(0.0, bankedProgress);

    return BankWithdrawalResult(
      withdrawnAmount: withdrawal,
      remainingBank: bankedProgress - withdrawal,
      effectiveProgress: dailyProgress + withdrawal,
      targetMet: dailyProgress + withdrawal >= dailyTarget,
    );
  }
}

/// Types of days based on readiness
enum DayType {
  push,
  normal,
  moderate,
  easy,
  rest,
}

extension DayTypeExtension on DayType {
  String get displayName {
    switch (this) {
      case DayType.push:
        return 'Push Day';
      case DayType.normal:
        return 'Normal Day';
      case DayType.moderate:
        return 'Moderate Day';
      case DayType.easy:
        return 'Easy Day';
      case DayType.rest:
        return 'Rest Day';
    }
  }

  String get description {
    switch (this) {
      case DayType.push:
        return 'High energy - time to challenge yourself';
      case DayType.normal:
        return 'Good energy - steady progress';
      case DayType.moderate:
        return 'Medium energy - take it steady';
      case DayType.easy:
        return 'Low energy - gentle movement';
      case DayType.rest:
        return 'Recovery needed - rest is progress too';
    }
  }

  String get color {
    switch (this) {
      case DayType.push:
        return '#FF5722'; // Orange
      case DayType.normal:
        return '#4CAF50'; // Green
      case DayType.moderate:
        return '#2196F3'; // Blue
      case DayType.easy:
        return '#9C27B0'; // Purple
      case DayType.rest:
        return '#607D8B'; // Blue-grey
    }
  }
}

/// Suggested activity based on readiness
class ActivitySuggestion {
  const ActivitySuggestion({
    required this.dayType,
    required this.multiplier,
    required this.suggestion,
    required this.icon,
  });

  final DayType dayType;
  final double multiplier;
  final String suggestion;
  final String icon;
}

/// Result of withdrawing from progress bank
class BankWithdrawalResult {
  const BankWithdrawalResult({
    required this.withdrawnAmount,
    required this.remainingBank,
    required this.effectiveProgress,
    required this.targetMet,
  });

  final double withdrawnAmount;
  final double remainingBank;
  final double effectiveProgress;
  final bool targetMet;
}
