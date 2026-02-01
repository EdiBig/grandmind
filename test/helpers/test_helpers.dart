/// Shared test utilities for Kinesa tests
///
/// This file provides mock classes and helper functions for testing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinesa/shared/services/analytics_service.dart';
import 'package:kinesa/core/theme/app_theme.dart';

// ========== Mock Classes ==========

/// Mock Firebase Analytics for testing
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

/// Mock Analytics Service for testing repositories that require analytics
class MockAnalyticsService extends Mock implements AnalyticsService {
  MockAnalyticsService() {
    _setupDefaultStubs();
  }

  void _setupDefaultStubs() {
    // Core logging
    when(() => logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    // User properties
    when(() => setUserId(any())).thenAnswer((_) async {});
    when(() => setUserProperty(
          name: any(named: 'name'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => setUserProperties(
          subscriptionTier: any(named: 'subscriptionTier'),
          goalType: any(named: 'goalType'),
          fitnessLevel: any(named: 'fitnessLevel'),
          coachTone: any(named: 'coachTone'),
          onboardingCompleted: any(named: 'onboardingCompleted'),
          hasHealthConnected: any(named: 'hasHealthConnected'),
        )).thenAnswer((_) async {});

    // Authentication events
    when(() => logSignUp(method: any(named: 'method')))
        .thenAnswer((_) async {});
    when(() => logLogin(method: any(named: 'method'))).thenAnswer((_) async {});
    when(() => logLogout()).thenAnswer((_) async {});
    when(() => logPasswordResetRequested()).thenAnswer((_) async {});

    // Habit events
    when(() => logHabitCreated(
          habitId: any(named: 'habitId'),
          habitName: any(named: 'habitName'),
          category: any(named: 'category'),
        )).thenAnswer((_) async {});
    when(() => logHabitCompleted(
          habitId: any(named: 'habitId'),
          habitName: any(named: 'habitName'),
        )).thenAnswer((_) async {});
    when(() => logHabitDeleted(habitId: any(named: 'habitId')))
        .thenAnswer((_) async {});

    // Workout events
    when(() => logWorkoutLogged(
          workoutType: any(named: 'workoutType'),
          durationMinutes: any(named: 'durationMinutes'),
          exerciseCount: any(named: 'exerciseCount'),
          caloriesBurned: any(named: 'caloriesBurned'),
          perceivedEffort: any(named: 'perceivedEffort'),
        )).thenAnswer((_) async {});
    when(() => logWorkoutStarted(
          workoutId: any(named: 'workoutId'),
          workoutType: any(named: 'workoutType'),
        )).thenAnswer((_) async {});
    when(() => logWorkoutCompleted(
          workoutId: any(named: 'workoutId'),
          workoutType: any(named: 'workoutType'),
          durationMinutes: any(named: 'durationMinutes'),
        )).thenAnswer((_) async {});

    // Mood events
    when(() => logMoodLogged(
          energyLevel: any(named: 'energyLevel'),
          moodRating: any(named: 'moodRating'),
        )).thenAnswer((_) async {});

    // Health events
    when(() => logHealthSynced(
          source: any(named: 'source'),
          dataType: any(named: 'dataType'),
          recordCount: any(named: 'recordCount'),
        )).thenAnswer((_) async {});

    // Engagement events
    when(() => logStreakAchieved(
          length: any(named: 'length'),
          streakType: any(named: 'streakType'),
        )).thenAnswer((_) async {});

    // Screen tracking
    when(() => logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
        )).thenAnswer((_) async {});
  }
}

/// Mock Firebase User for testing
class MockFirebaseUser extends Mock implements User {
  final String _uid;
  final String? _email;
  final String? _displayName;

  MockFirebaseUser({
    String uid = 'test-user-id',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
  })  : _uid = uid,
        _email = email,
        _displayName = displayName;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;
}

// ========== Widget Test Helpers ==========

/// Creates a test widget wrapped in necessary providers
///
/// Use this helper for widget tests to ensure consistent test setup.
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: child,
    ),
  );
}

/// Creates a test widget with Scaffold wrapper
Widget createTestWidgetWithScaffold({
  required Widget child,
  List<Override> overrides = const [],
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: child),
    ),
  );
}

// ========== Date Helpers ==========

/// Normalizes a DateTime to start of day (strips time component)
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Creates a DateTime for today at start of day
DateTime today() => normalizeDate(DateTime.now());

/// Creates a DateTime for yesterday at start of day
DateTime yesterday() => today().subtract(const Duration(days: 1));

/// Creates a DateTime for a specific number of days ago
DateTime daysAgo(int days) => today().subtract(Duration(days: days));

/// Creates a list of consecutive dates starting from a given date
List<DateTime> consecutiveDates(DateTime start, int count) {
  return List.generate(
    count,
    (i) => normalizeDate(start.add(Duration(days: i))),
  );
}

// ========== Test ID Generators ==========

/// Generates a unique test ID
String generateTestId([String prefix = 'test']) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

/// Generates a unique user ID for tests
String generateTestUserId() => generateTestId('user');

/// Generates a unique habit ID for tests
String generateTestHabitId() => generateTestId('habit');

/// Generates a unique workout ID for tests
String generateTestWorkoutId() => generateTestId('workout');

/// Generates a unique meal ID for tests
String generateTestMealId() => generateTestId('meal');
