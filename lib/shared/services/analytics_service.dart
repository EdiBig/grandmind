import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../core/constants/analytics_constants.dart';

/// Centralized analytics service for tracking user behavior
/// Wraps Firebase Analytics with type-safe methods
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final Logger _logger = Logger();

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ Core Logging Method ============

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        _logger.d('Analytics: $name ${parameters ?? ''}');
      }
    } catch (e) {
      _logger.e('Analytics error logging $name', error: e);
    }
  }

  // ============ User Properties ============

  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      _logger.e('Analytics error setting user ID', error: e);
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        _logger.d('Analytics: Set user property $name = $value');
      }
    } catch (e) {
      _logger.e('Analytics error setting user property $name', error: e);
    }
  }

  Future<void> setUserProperties({
    String? subscriptionTier,
    String? goalType,
    String? fitnessLevel,
    String? coachTone,
    bool? onboardingCompleted,
    bool? hasHealthConnected,
  }) async {
    if (subscriptionTier != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.subscriptionTier,
        value: subscriptionTier,
      );
    }
    if (goalType != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.goalType,
        value: goalType,
      );
    }
    if (fitnessLevel != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.fitnessLevel,
        value: fitnessLevel,
      );
    }
    if (coachTone != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.coachTone,
        value: coachTone,
      );
    }
    if (onboardingCompleted != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.onboardingCompleted,
        value: onboardingCompleted.toString(),
      );
    }
    if (hasHealthConnected != null) {
      await setUserProperty(
        name: AnalyticsUserProperties.hasHealthConnected,
        value: hasHealthConnected.toString(),
      );
    }
  }

  // ============ Screen Tracking ============

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // ============ Onboarding Events ============

  Future<void> logOnboardingStarted() async {
    await logEvent(name: AnalyticsEvents.onboardingStarted);
  }

  Future<void> logOnboardingStepCompleted({
    required int step,
    required String stepName,
  }) async {
    await logEvent(
      name: AnalyticsEvents.onboardingStepCompleted,
      parameters: {
        AnalyticsParams.step: step,
        AnalyticsParams.stepName: stepName,
      },
    );
  }

  Future<void> logOnboardingCompleted({
    required String goalType,
    required String fitnessLevel,
    String? coachTone,
  }) async {
    await logEvent(
      name: AnalyticsEvents.onboardingCompleted,
      parameters: {
        AnalyticsParams.goalType: goalType,
        AnalyticsParams.fitnessLevel: fitnessLevel,
        if (coachTone != null) AnalyticsParams.coachTone: coachTone,
      },
    );
    // Also set user properties
    await setUserProperties(
      goalType: goalType,
      fitnessLevel: fitnessLevel,
      coachTone: coachTone,
      onboardingCompleted: true,
    );
  }

  // ============ Authentication Events ============

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logLogout() async {
    await logEvent(name: AnalyticsEvents.logout);
    await setUserId(null);
  }

  Future<void> logPasswordResetRequested() async {
    await logEvent(name: AnalyticsEvents.passwordReset);
  }

  // ============ Workout Events ============

  Future<void> logWorkoutLogged({
    required String workoutType,
    required int durationMinutes,
    int? exerciseCount,
    int? caloriesBurned,
    int? perceivedEffort,
  }) async {
    await logEvent(
      name: AnalyticsEvents.workoutLogged,
      parameters: {
        AnalyticsParams.workoutType: workoutType,
        AnalyticsParams.durationMinutes: durationMinutes,
        AnalyticsParams.hasExercises: (exerciseCount ?? 0) > 0 ? 1 : 0,
        if (exerciseCount != null) AnalyticsParams.exerciseCount: exerciseCount,
        if (caloriesBurned != null)
          AnalyticsParams.caloriesBurned: caloriesBurned,
        if (perceivedEffort != null)
          AnalyticsParams.perceivedEffort: perceivedEffort,
      },
    );
  }

  Future<void> logWorkoutStarted({
    required String workoutId,
    required String workoutType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.workoutStarted,
      parameters: {
        AnalyticsParams.workoutId: workoutId,
        AnalyticsParams.workoutType: workoutType,
      },
    );
  }

  Future<void> logWorkoutCompleted({
    required String workoutId,
    required String workoutType,
    required int durationMinutes,
  }) async {
    await logEvent(
      name: AnalyticsEvents.workoutCompleted,
      parameters: {
        AnalyticsParams.workoutId: workoutId,
        AnalyticsParams.workoutType: workoutType,
        AnalyticsParams.durationMinutes: durationMinutes,
      },
    );
  }

  // ============ Habit Events ============

  Future<void> logHabitCreated({
    required String habitId,
    required String habitName,
    String? category,
  }) async {
    await logEvent(
      name: AnalyticsEvents.habitCreated,
      parameters: {
        AnalyticsParams.habitId: habitId,
        AnalyticsParams.habitName: habitName,
        if (category != null) AnalyticsParams.habitCategory: category,
      },
    );
  }

  Future<void> logHabitCompleted({
    required String habitId,
    required String habitName,
  }) async {
    await logEvent(
      name: AnalyticsEvents.habitCompleted,
      parameters: {
        AnalyticsParams.habitId: habitId,
        AnalyticsParams.habitName: habitName,
      },
    );
  }

  Future<void> logHabitDeleted({required String habitId}) async {
    await logEvent(
      name: AnalyticsEvents.habitDeleted,
      parameters: {AnalyticsParams.habitId: habitId},
    );
  }

  // ============ Mood/Energy Events ============

  Future<void> logMoodLogged({
    required int energyLevel,
    int? moodRating,
  }) async {
    await logEvent(
      name: AnalyticsEvents.moodLogged,
      parameters: {
        AnalyticsParams.energyLevel: energyLevel,
        if (moodRating != null) AnalyticsParams.moodRating: moodRating,
      },
    );
  }

  Future<void> logWeightLogged({required double weight}) async {
    await logEvent(
      name: AnalyticsEvents.weightLogged,
      parameters: {'weight': weight},
    );
  }

  // ============ Health Sync Events ============

  Future<void> logHealthSynced({
    required String source,
    String? dataType,
    int? recordCount,
  }) async {
    await logEvent(
      name: AnalyticsEvents.healthSynced,
      parameters: {
        AnalyticsParams.healthSource: source,
        if (dataType != null) AnalyticsParams.dataType: dataType,
        if (recordCount != null) AnalyticsParams.recordCount: recordCount,
      },
    );
    await setUserProperty(
      name: AnalyticsUserProperties.hasHealthConnected,
      value: 'true',
    );
  }

  // ============ Engagement Events ============

  Future<void> logStreakAchieved({
    required int length,
    required String streakType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.streakAchieved,
      parameters: {
        AnalyticsParams.streakLength: length,
        AnalyticsParams.streakType: streakType,
      },
    );
  }

  Future<void> logStreakBroken({
    required int length,
    required String streakType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.streakBroken,
      parameters: {
        AnalyticsParams.streakLength: length,
        AnalyticsParams.streakType: streakType,
      },
    );
  }

  Future<void> logWeeklySummaryViewed() async {
    await logEvent(name: AnalyticsEvents.weeklySummaryViewed);
  }

  Future<void> logPersonalBestAchieved({required String metric}) async {
    await logEvent(
      name: AnalyticsEvents.personalBestAchieved,
      parameters: {AnalyticsParams.metric: metric},
    );
  }

  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    await logEvent(
      name: AnalyticsEvents.achievementUnlocked,
      parameters: {
        AnalyticsParams.achievementId: achievementId,
        AnalyticsParams.achievementName: achievementName,
      },
    );
  }

  // ============ AI Events ============

  Future<void> logAICoachMessageSent({required int messageLength}) async {
    await logEvent(
      name: AnalyticsEvents.aiCoachMessageSent,
      parameters: {AnalyticsParams.messageLength: messageLength},
    );
  }

  Future<void> logAICoachResponseReceived({
    required int responseTimeMs,
    required int tokensUsed,
    required bool fromCache,
  }) async {
    await logEvent(
      name: AnalyticsEvents.aiCoachResponseReceived,
      parameters: {
        AnalyticsParams.responseTime: responseTimeMs,
        AnalyticsParams.tokensUsed: tokensUsed,
        AnalyticsParams.fromCache: fromCache ? 1 : 0,
      },
    );
  }

  // ============ Navigation Events ============

  Future<void> logTabChanged({
    required String tabName,
    String? previousTab,
  }) async {
    await logEvent(
      name: AnalyticsEvents.tabChanged,
      parameters: {
        AnalyticsParams.tabName: tabName,
        if (previousTab != null) AnalyticsParams.previousTab: previousTab,
      },
    );
  }

  // ============ Monetisation Events ============

  Future<void> logPaywallViewed({required String trigger}) async {
    await logEvent(
      name: AnalyticsEvents.paywallViewed,
      parameters: {AnalyticsParams.trigger: trigger},
    );
  }

  Future<void> logSubscriptionStarted({
    required String plan,
    required double price,
    String currency = 'GBP',
  }) async {
    await logEvent(
      name: AnalyticsEvents.subscriptionStarted,
      parameters: {
        AnalyticsParams.plan: plan,
        AnalyticsParams.price: price,
        AnalyticsParams.currency: currency,
      },
    );
    await setUserProperty(
      name: AnalyticsUserProperties.subscriptionTier,
      value: plan,
    );
  }

  Future<void> logTrialStarted({required String plan}) async {
    await logEvent(
      name: AnalyticsEvents.trialStarted,
      parameters: {AnalyticsParams.plan: plan},
    );
  }

  Future<void> logSubscriptionCancelled({required String plan}) async {
    await logEvent(
      name: AnalyticsEvents.subscriptionCancelled,
      parameters: {AnalyticsParams.plan: plan},
    );
  }

  // ============ Error Events ============

  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await logEvent(
      name: AnalyticsEvents.errorOccurred,
      parameters: {
        AnalyticsParams.errorType: errorType,
        AnalyticsParams.errorMessage:
            errorMessage.length > 100
                ? errorMessage.substring(0, 100)
                : errorMessage,
        if (stackTrace != null)
          AnalyticsParams.stackTrace:
              stackTrace.length > 100 ? stackTrace.substring(0, 100) : stackTrace,
      },
    );
  }
}
