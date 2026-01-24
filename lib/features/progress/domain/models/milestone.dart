import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'milestone.freezed.dart';
part 'milestone.g.dart';

/// Types of milestones a user can achieve
enum MilestoneType {
  weight,       // Weight loss/gain milestones
  streak,       // Consistency milestones
  workout,      // Workout count milestones
  habit,        // Habit completion milestones
  strength,     // Strength PR milestones
  firstTime,    // First time achievements
}

extension MilestoneTypeX on MilestoneType {
  String get displayName {
    switch (this) {
      case MilestoneType.weight:
        return 'Weight';
      case MilestoneType.streak:
        return 'Streak';
      case MilestoneType.workout:
        return 'Workout';
      case MilestoneType.habit:
        return 'Habit';
      case MilestoneType.strength:
        return 'Strength';
      case MilestoneType.firstTime:
        return 'First Time';
    }
  }

  String get icon {
    switch (this) {
      case MilestoneType.weight:
        return 'scale';
      case MilestoneType.streak:
        return 'local_fire_department';
      case MilestoneType.workout:
        return 'fitness_center';
      case MilestoneType.habit:
        return 'check_circle';
      case MilestoneType.strength:
        return 'emoji_events';
      case MilestoneType.firstTime:
        return 'star';
    }
  }
}

/// Represents an achievement milestone
@freezed
class Milestone with _$Milestone {
  const Milestone._();

  const factory Milestone({
    required String id,
    required String userId,
    required MilestoneType type,
    required String title,
    required String description,
    required String badge,      // Badge identifier (e.g., "5kg_lost", "10_day_streak")
    @TimestampConverter() required DateTime achievedAt,
    @Default(false) bool isNew, // Show "New" badge indicator
    Map<String, dynamic>? metadata,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);

  /// Get a shareable message for social
  String get shareMessage {
    return 'I just achieved "$title" on my fitness journey! $description';
  }
}

/// Predefined milestone definitions
class MilestoneDefinitions {
  static const List<MilestoneDef> weightMilestones = [
    MilestoneDef(
      badge: 'first_weigh_in',
      title: 'First Weigh-In',
      description: 'Recorded your first weight entry',
      threshold: 1,
    ),
    MilestoneDef(
      badge: '1kg_lost',
      title: 'First Kilogram Lost',
      description: 'Lost your first kilogram',
      threshold: 1,
    ),
    MilestoneDef(
      badge: '5kg_lost',
      title: '5kg Milestone',
      description: 'Lost 5 kilograms',
      threshold: 5,
    ),
    MilestoneDef(
      badge: '10kg_lost',
      title: '10kg Champion',
      description: 'Lost 10 kilograms',
      threshold: 10,
    ),
    MilestoneDef(
      badge: '20kg_lost',
      title: '20kg Transformation',
      description: 'Lost 20 kilograms - incredible progress!',
      threshold: 20,
    ),
  ];

  static const List<MilestoneDef> streakMilestones = [
    MilestoneDef(
      badge: '3_day_streak',
      title: 'Getting Started',
      description: '3-day activity streak',
      threshold: 3,
    ),
    MilestoneDef(
      badge: '7_day_streak',
      title: 'Week Warrior',
      description: '7-day activity streak',
      threshold: 7,
    ),
    MilestoneDef(
      badge: '14_day_streak',
      title: 'Two Week Streak',
      description: '14-day activity streak',
      threshold: 14,
    ),
    MilestoneDef(
      badge: '30_day_streak',
      title: 'Monthly Champion',
      description: '30-day activity streak',
      threshold: 30,
    ),
    MilestoneDef(
      badge: '100_day_streak',
      title: 'Century Club',
      description: '100-day activity streak - legendary!',
      threshold: 100,
    ),
  ];

  static const List<MilestoneDef> workoutMilestones = [
    MilestoneDef(
      badge: 'first_workout',
      title: 'First Workout',
      description: 'Completed your first workout',
      threshold: 1,
    ),
    MilestoneDef(
      badge: '10_workouts',
      title: '10 Workouts Strong',
      description: 'Completed 10 workouts',
      threshold: 10,
    ),
    MilestoneDef(
      badge: '50_workouts',
      title: 'Fitness Enthusiast',
      description: 'Completed 50 workouts',
      threshold: 50,
    ),
    MilestoneDef(
      badge: '100_workouts',
      title: 'Century Workouts',
      description: 'Completed 100 workouts - amazing dedication!',
      threshold: 100,
    ),
  ];

  static const List<MilestoneDef> habitMilestones = [
    MilestoneDef(
      badge: 'first_habit',
      title: 'Habit Builder',
      description: 'Completed your first habit',
      threshold: 1,
    ),
    MilestoneDef(
      badge: '50_habits',
      title: 'Habit Master',
      description: 'Completed 50 habit entries',
      threshold: 50,
    ),
    MilestoneDef(
      badge: '100_habits',
      title: 'Habit Champion',
      description: 'Completed 100 habit entries',
      threshold: 100,
    ),
  ];
}

/// Definition for a milestone
class MilestoneDef {
  final String badge;
  final String title;
  final String description;
  final int threshold;

  const MilestoneDef({
    required this.badge,
    required this.title,
    required this.description,
    required this.threshold,
  });
}

/// User's milestone progress summary
@freezed
class MilestoneSummary with _$MilestoneSummary {
  const factory MilestoneSummary({
    required List<Milestone> recentMilestones,
    required List<Milestone> allMilestones,
    required int totalCount,
    required int newCount,
    @Default({}) Map<MilestoneType, int> countByType,
  }) = _MilestoneSummary;

  factory MilestoneSummary.fromJson(Map<String, dynamic> json) =>
      _$MilestoneSummaryFromJson(json);

  factory MilestoneSummary.empty() => const MilestoneSummary(
        recentMilestones: [],
        allMilestones: [],
        totalCount: 0,
        newCount: 0,
        countByType: {},
      );
}
