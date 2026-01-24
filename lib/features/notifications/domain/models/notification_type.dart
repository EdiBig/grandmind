/// Enumeration of notification types in the app
enum NotificationType {
  workoutReminder,
  habitCheckIn,
  moodEnergyCheckIn,
  motivational,
  achievement,
  goalMilestone,
  inactivityNudge,
  custom;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case NotificationType.workoutReminder:
        return 'Workout Reminder';
      case NotificationType.habitCheckIn:
        return 'Habit Check-in';
      case NotificationType.moodEnergyCheckIn:
        return 'Mood & Energy Check-in';
      case NotificationType.motivational:
        return 'Motivational Message';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.goalMilestone:
        return 'Goal Milestone';
      case NotificationType.inactivityNudge:
        return 'Activity Nudge';
      case NotificationType.custom:
        return 'Custom Notification';
    }
  }

  /// Get description for each type
  String get description {
    switch (this) {
      case NotificationType.workoutReminder:
        return 'Reminders for scheduled workouts';
      case NotificationType.habitCheckIn:
        return 'Daily reminders to check in on habits';
      case NotificationType.moodEnergyCheckIn:
        return 'Daily reminders to log your mood and energy';
      case NotificationType.motivational:
        return 'Motivational messages to keep you going';
      case NotificationType.achievement:
        return 'Celebrate your achievements';
      case NotificationType.goalMilestone:
        return 'Notify when you reach goal milestones';
      case NotificationType.inactivityNudge:
        return 'Gentle nudges when you\'ve been inactive';
      case NotificationType.custom:
        return 'Custom notifications';
    }
  }
}
