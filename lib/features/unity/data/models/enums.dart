/// Unity Feature Enums
///
/// Core enumerations for the Unity social fitness feature.
/// "Progress together, at your own pace"
library unity_enums;

/// Types of challenges available in Unity
enum ChallengeType {
  /// Accumulate total value over time (e.g., 100,000 steps)
  accumulation,

  /// Complete X times per period (e.g., 3 workouts per week)
  frequency,

  /// Consecutive days of activity
  streak,

  /// Hit specific milestone targets
  milestone,

  /// Build consistent habits
  habit,

  /// Improve personal metrics over time
  improvement,
}

extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.accumulation:
        return 'Accumulation';
      case ChallengeType.frequency:
        return 'Frequency';
      case ChallengeType.streak:
        return 'Streak';
      case ChallengeType.milestone:
        return 'Milestone';
      case ChallengeType.habit:
        return 'Habit';
      case ChallengeType.improvement:
        return 'Improvement';
    }
  }

  String get description {
    switch (this) {
      case ChallengeType.accumulation:
        return 'Accumulate a total over the challenge period';
      case ChallengeType.frequency:
        return 'Complete activities a certain number of times';
      case ChallengeType.streak:
        return 'Maintain consecutive days of activity';
      case ChallengeType.milestone:
        return 'Hit specific milestone targets';
      case ChallengeType.habit:
        return 'Build consistent daily habits';
      case ChallengeType.improvement:
        return 'Improve your personal metrics over time';
    }
  }
}

/// How users participate in a challenge
enum ParticipationType {
  /// Individual challenge, personal goals
  solo,

  /// Partner challenge (2 people)
  duo,

  /// Small group challenge (Circle-based)
  circle,

  /// Larger community challenge
  community,

  /// Platform-wide challenge
  global,
}

extension ParticipationTypeExtension on ParticipationType {
  String get displayName {
    switch (this) {
      case ParticipationType.solo:
        return 'Solo';
      case ParticipationType.duo:
        return 'Duo';
      case ParticipationType.circle:
        return 'Circle';
      case ParticipationType.community:
        return 'Community';
      case ParticipationType.global:
        return 'Global';
    }
  }

  int get minParticipants {
    switch (this) {
      case ParticipationType.solo:
        return 1;
      case ParticipationType.duo:
        return 2;
      case ParticipationType.circle:
        return 3;
      case ParticipationType.community:
        return 10;
      case ParticipationType.global:
        return 50;
    }
  }

  int get maxParticipants {
    switch (this) {
      case ParticipationType.solo:
        return 1;
      case ParticipationType.duo:
        return 2;
      case ParticipationType.circle:
        return 12;
      case ParticipationType.community:
        return 100;
      case ParticipationType.global:
        return 10000;
    }
  }
}

/// Competition style for challenges
enum CompetitionStyle {
  /// Team goals > individual rankings
  collaborative,

  /// Compete against your own previous performance
  personalBest,

  /// Traditional leaderboard-based competition
  competitive,

  /// Mix of collaborative and competitive elements
  hybrid,
}

extension CompetitionStyleExtension on CompetitionStyle {
  String get displayName {
    switch (this) {
      case CompetitionStyle.collaborative:
        return 'Collaborative';
      case CompetitionStyle.personalBest:
        return 'Personal Best';
      case CompetitionStyle.competitive:
        return 'Competitive';
      case CompetitionStyle.hybrid:
        return 'Hybrid';
    }
  }

  String get description {
    switch (this) {
      case CompetitionStyle.collaborative:
        return 'Work together toward a shared goal';
      case CompetitionStyle.personalBest:
        return 'Challenge yourself to beat your personal records';
      case CompetitionStyle.competitive:
        return 'Compete for the top spot on the leaderboard';
      case CompetitionStyle.hybrid:
        return 'Team goals with individual recognition';
    }
  }
}

/// Types of metrics that can be tracked
enum MetricType {
  steps,
  distance,
  duration,
  workouts,
  calories,
  activeMinutes,
  floors,
  heartRateZone,
  sleepHours,
  waterIntake,
  mindfulMinutes,
  standHours,
  exerciseMinutes,
  custom,
}

extension MetricTypeExtension on MetricType {
  String get displayName {
    switch (this) {
      case MetricType.steps:
        return 'Steps';
      case MetricType.distance:
        return 'Distance';
      case MetricType.duration:
        return 'Duration';
      case MetricType.workouts:
        return 'Workouts';
      case MetricType.calories:
        return 'Calories';
      case MetricType.activeMinutes:
        return 'Active Minutes';
      case MetricType.floors:
        return 'Floors';
      case MetricType.heartRateZone:
        return 'Heart Rate Zone';
      case MetricType.sleepHours:
        return 'Sleep Hours';
      case MetricType.waterIntake:
        return 'Water Intake';
      case MetricType.mindfulMinutes:
        return 'Mindful Minutes';
      case MetricType.standHours:
        return 'Stand Hours';
      case MetricType.exerciseMinutes:
        return 'Exercise Minutes';
      case MetricType.custom:
        return 'Custom';
    }
  }

  String get defaultUnit {
    switch (this) {
      case MetricType.steps:
        return 'steps';
      case MetricType.distance:
        return 'km';
      case MetricType.duration:
        return 'min';
      case MetricType.workouts:
        return 'workouts';
      case MetricType.calories:
        return 'kcal';
      case MetricType.activeMinutes:
        return 'min';
      case MetricType.floors:
        return 'floors';
      case MetricType.heartRateZone:
        return 'min';
      case MetricType.sleepHours:
        return 'hours';
      case MetricType.waterIntake:
        return 'ml';
      case MetricType.mindfulMinutes:
        return 'min';
      case MetricType.standHours:
        return 'hours';
      case MetricType.exerciseMinutes:
        return 'min';
      case MetricType.custom:
        return 'units';
    }
  }

  String get icon {
    switch (this) {
      case MetricType.steps:
        return 'directions_walk';
      case MetricType.distance:
        return 'straighten';
      case MetricType.duration:
        return 'timer';
      case MetricType.workouts:
        return 'fitness_center';
      case MetricType.calories:
        return 'local_fire_department';
      case MetricType.activeMinutes:
        return 'directions_run';
      case MetricType.floors:
        return 'stairs';
      case MetricType.heartRateZone:
        return 'favorite';
      case MetricType.sleepHours:
        return 'bedtime';
      case MetricType.waterIntake:
        return 'water_drop';
      case MetricType.mindfulMinutes:
        return 'self_improvement';
      case MetricType.standHours:
        return 'accessibility_new';
      case MetricType.exerciseMinutes:
        return 'sports';
      case MetricType.custom:
        return 'tune';
    }
  }
}

/// User's participation status in a challenge
enum ParticipationStatus {
  /// Invited but hasn't responded
  invited,

  /// Requested to join, awaiting approval
  pending,

  /// Actively participating
  active,

  /// Successfully completed the challenge
  completed,

  /// Voluntarily left the challenge
  withdrawn,

  /// Removed from challenge by admin
  disqualified,

  /// Temporarily paused participation
  paused,

  /// Declined the invitation
  declined,
}

extension ParticipationStatusExtension on ParticipationStatus {
  String get displayName {
    switch (this) {
      case ParticipationStatus.invited:
        return 'Invited';
      case ParticipationStatus.pending:
        return 'Pending';
      case ParticipationStatus.active:
        return 'Active';
      case ParticipationStatus.completed:
        return 'Completed';
      case ParticipationStatus.withdrawn:
        return 'Withdrawn';
      case ParticipationStatus.disqualified:
        return 'Disqualified';
      case ParticipationStatus.paused:
        return 'Paused';
      case ParticipationStatus.declined:
        return 'Declined';
    }
  }

  bool get isActive => this == ParticipationStatus.active;
  bool get isEnded => this == ParticipationStatus.completed ||
                      this == ParticipationStatus.withdrawn ||
                      this == ParticipationStatus.disqualified;
  bool get canContribute => this == ParticipationStatus.active;
}

/// Types of cheers/encouragements
enum CheerType {
  /// General encouragement
  proudOfYou,

  /// Keep pushing forward
  keepGoing,

  /// Acknowledge rest days
  restWell,

  /// Welcome back after break
  welcomeBack,

  /// Celebrate big achievements
  incredible,

  /// General support
  thinkingOfYou,
}

extension CheerTypeExtension on CheerType {
  String get displayName {
    switch (this) {
      case CheerType.proudOfYou:
        return 'Proud of You';
      case CheerType.keepGoing:
        return 'Keep Going';
      case CheerType.restWell:
        return 'Rest Well';
      case CheerType.welcomeBack:
        return 'Welcome Back';
      case CheerType.incredible:
        return 'Incredible';
      case CheerType.thinkingOfYou:
        return 'Thinking of You';
    }
  }

  String get emoji {
    switch (this) {
      case CheerType.proudOfYou:
        return '\u{1F31F}'; // Star
      case CheerType.keepGoing:
        return '\u{1F4AA}'; // Flexed biceps
      case CheerType.restWell:
        return '\u{1F33F}'; // Herb/plant
      case CheerType.welcomeBack:
        return '\u{1F44B}'; // Waving hand
      case CheerType.incredible:
        return '\u{1F525}'; // Fire
      case CheerType.thinkingOfYou:
        return '\u{1F49C}'; // Purple heart
    }
  }

  String get message {
    switch (this) {
      case CheerType.proudOfYou:
        return "I'm proud of you!";
      case CheerType.keepGoing:
        return "Keep going, you've got this!";
      case CheerType.restWell:
        return 'Take the rest you need';
      case CheerType.welcomeBack:
        return 'Great to see you back!';
      case CheerType.incredible:
        return "That's incredible!";
      case CheerType.thinkingOfYou:
        return 'Thinking of you!';
    }
  }
}

/// Types of Circles (micro-communities)
enum CircleType {
  /// 2 people
  duo,

  /// 3-5 people
  squad,

  /// 6-12 people
  crew,

  /// 13+ people
  community,
}

extension CircleTypeExtension on CircleType {
  String get displayName {
    switch (this) {
      case CircleType.duo:
        return 'Duo';
      case CircleType.squad:
        return 'Squad';
      case CircleType.crew:
        return 'Crew';
      case CircleType.community:
        return 'Community';
    }
  }

  int get minMembers {
    switch (this) {
      case CircleType.duo:
        return 2;
      case CircleType.squad:
        return 3;
      case CircleType.crew:
        return 6;
      case CircleType.community:
        return 13;
    }
  }

  int get maxMembers {
    switch (this) {
      case CircleType.duo:
        return 2;
      case CircleType.squad:
        return 5;
      case CircleType.crew:
        return 12;
      case CircleType.community:
        return 50;
    }
  }
}

/// Circle visibility settings
enum CircleVisibility {
  /// Only members can see
  private,

  /// Visible but requires invite to join
  inviteOnly,

  /// Anyone can find and request to join
  public,
}

extension CircleVisibilityExtension on CircleVisibility {
  String get displayName {
    switch (this) {
      case CircleVisibility.private:
        return 'Private';
      case CircleVisibility.inviteOnly:
        return 'Invite Only';
      case CircleVisibility.public:
        return 'Public';
    }
  }

  String get description {
    switch (this) {
      case CircleVisibility.private:
        return 'Only visible to members';
      case CircleVisibility.inviteOnly:
        return 'Discoverable but invite required';
      case CircleVisibility.public:
        return 'Anyone can find and request to join';
    }
  }
}

/// Types of feed posts
enum FeedPostType {
  /// Workout or activity logged
  activity,

  /// Daily check-in
  checkIn,

  /// Milestone or achievement
  celebration,

  /// Text-only post
  text,

  /// Milestone reached
  milestone,
}

extension FeedPostTypeExtension on FeedPostType {
  String get displayName {
    switch (this) {
      case FeedPostType.activity:
        return 'Activity';
      case FeedPostType.checkIn:
        return 'Check-in';
      case FeedPostType.celebration:
        return 'Celebration';
      case FeedPostType.text:
        return 'Post';
      case FeedPostType.milestone:
        return 'Milestone';
    }
  }
}

/// Reasons for taking a rest day
enum RestDayReason {
  /// Planned rest day
  scheduledRest,

  /// Feeling unwell physically
  feelingUnwell,

  /// Mental health day
  mentalHealth,

  /// Life circumstances
  lifeHappens,

  /// Injury prevention/recovery
  injury,

  /// Other reason
  other,
}

extension RestDayReasonExtension on RestDayReason {
  String get displayName {
    switch (this) {
      case RestDayReason.scheduledRest:
        return 'Scheduled Rest';
      case RestDayReason.feelingUnwell:
        return 'Feeling Unwell';
      case RestDayReason.mentalHealth:
        return 'Mental Health Day';
      case RestDayReason.lifeHappens:
        return 'Life Happens';
      case RestDayReason.injury:
        return 'Injury';
      case RestDayReason.other:
        return 'Other';
    }
  }

  String get encouragement {
    switch (this) {
      case RestDayReason.scheduledRest:
        return 'Smart recovery! Your body will thank you.';
      case RestDayReason.feelingUnwell:
        return 'Rest up and feel better soon!';
      case RestDayReason.mentalHealth:
        return 'Taking care of your mind is just as important.';
      case RestDayReason.lifeHappens:
        return "Life comes first. You'll be back when you're ready.";
      case RestDayReason.injury:
        return 'Heal well. Your future self will thank you.';
      case RestDayReason.other:
        return 'Rest is part of the journey.';
    }
  }
}

/// Difficulty tier for challenges
enum DifficultyTier {
  /// Lower intensity, same achievement
  gentle,

  /// Standard intensity
  steady,

  /// Higher intensity for those ready
  intense,
}

extension DifficultyTierExtension on DifficultyTier {
  String get displayName {
    switch (this) {
      case DifficultyTier.gentle:
        return 'Gentle';
      case DifficultyTier.steady:
        return 'Steady';
      case DifficultyTier.intense:
        return 'Intense';
    }
  }

  String get description {
    switch (this) {
      case DifficultyTier.gentle:
        return 'Perfect for building consistency';
      case DifficultyTier.steady:
        return 'A balanced challenge';
      case DifficultyTier.intense:
        return 'Push your limits';
    }
  }

  /// Multiplier relative to base target
  double get targetMultiplier {
    switch (this) {
      case DifficultyTier.gentle:
        return 0.6;
      case DifficultyTier.steady:
        return 1.0;
      case DifficultyTier.intense:
        return 1.5;
    }
  }

  String get badgeColor {
    switch (this) {
      case DifficultyTier.gentle:
        return '#4CAF50'; // Green
      case DifficultyTier.steady:
        return '#2196F3'; // Blue
      case DifficultyTier.intense:
        return '#FF5722'; // Orange
    }
  }
}

/// Member role in a Circle
enum CircleMemberRole {
  member,
  admin,
  owner,
}

extension CircleMemberRoleExtension on CircleMemberRole {
  String get displayName {
    switch (this) {
      case CircleMemberRole.member:
        return 'Member';
      case CircleMemberRole.admin:
        return 'Admin';
      case CircleMemberRole.owner:
        return 'Owner';
    }
  }

  bool get canManageMembers =>
      this == CircleMemberRole.admin || this == CircleMemberRole.owner;
  bool get canEditSettings => this == CircleMemberRole.owner;
  bool get canDeleteCircle => this == CircleMemberRole.owner;
}

/// Challenge status
enum ChallengeStatus {
  draft,
  upcoming,
  active,
  completed,
  cancelled,
}

extension ChallengeStatusExtension on ChallengeStatus {
  String get displayName {
    switch (this) {
      case ChallengeStatus.draft:
        return 'Draft';
      case ChallengeStatus.upcoming:
        return 'Upcoming';
      case ChallengeStatus.active:
        return 'Active';
      case ChallengeStatus.completed:
        return 'Completed';
      case ChallengeStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isJoinable =>
      this == ChallengeStatus.upcoming || this == ChallengeStatus.active;
}

/// Consent types for Unity features
enum ConsentType {
  healthDisclaimer,
  dataSharing,
  rankingsDisplay,
  activityFeed,
  ageVerification,
  parentalConsent,
}

extension ConsentTypeExtension on ConsentType {
  String get displayName {
    switch (this) {
      case ConsentType.healthDisclaimer:
        return 'Health Disclaimer';
      case ConsentType.dataSharing:
        return 'Data Sharing';
      case ConsentType.rankingsDisplay:
        return 'Rankings Display';
      case ConsentType.activityFeed:
        return 'Activity Feed';
      case ConsentType.ageVerification:
        return 'Age Verification';
      case ConsentType.parentalConsent:
        return 'Parental Consent';
    }
  }

  bool get isRequired {
    switch (this) {
      case ConsentType.healthDisclaimer:
      case ConsentType.dataSharing:
      case ConsentType.ageVerification:
        return true;
      case ConsentType.rankingsDisplay:
      case ConsentType.activityFeed:
      case ConsentType.parentalConsent:
        return false;
    }
  }
}

/// Aggregation method for progress calculation
enum AggregationType {
  sum,
  average,
  max,
  min,
  count,
  latest,
}

extension AggregationTypeExtension on AggregationType {
  String get displayName {
    switch (this) {
      case AggregationType.sum:
        return 'Sum';
      case AggregationType.average:
        return 'Average';
      case AggregationType.max:
        return 'Maximum';
      case AggregationType.min:
        return 'Minimum';
      case AggregationType.count:
        return 'Count';
      case AggregationType.latest:
        return 'Latest';
    }
  }
}

/// Privacy level for challenges
enum PrivacyLevel {
  /// Open to everyone
  public,

  /// Only visible to friends
  friends,

  /// Only visible to circle members
  circle,

  /// Only visible to creator
  private,
}

extension PrivacyLevelExtension on PrivacyLevel {
  String get displayName {
    switch (this) {
      case PrivacyLevel.public:
        return 'Public';
      case PrivacyLevel.friends:
        return 'Friends';
      case PrivacyLevel.circle:
        return 'Circle';
      case PrivacyLevel.private:
        return 'Private';
    }
  }
}

/// Frequency period for frequency-based challenges
enum FrequencyPeriod {
  daily,
  weekly,
  monthly,
}

extension FrequencyPeriodExtension on FrequencyPeriod {
  String get displayName {
    switch (this) {
      case FrequencyPeriod.daily:
        return 'Daily';
      case FrequencyPeriod.weekly:
        return 'Weekly';
      case FrequencyPeriod.monthly:
        return 'Monthly';
    }
  }

  int get daysInPeriod {
    switch (this) {
      case FrequencyPeriod.daily:
        return 1;
      case FrequencyPeriod.weekly:
        return 7;
      case FrequencyPeriod.monthly:
        return 30;
    }
  }
}
