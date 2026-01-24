import 'dart:io' show Platform, Socket;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinesa/firebase_options.dart';
import 'package:kinesa/core/theme/app_theme.dart';
import 'package:kinesa/features/settings/presentation/screens/settings_screen.dart';
import 'package:kinesa/features/settings/presentation/screens/about_screen.dart';
import 'package:kinesa/features/settings/presentation/screens/privacy_screen.dart';
import 'package:kinesa/features/profile/presentation/screens/profile_screen.dart';
import 'package:kinesa/features/notifications/presentation/screens/notification_settings_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String testHost;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    testHost = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    FirebaseAuth.instance.useAuthEmulator(testHost, 9098);
    FirebaseFirestore.instance.useFirestoreEmulator(testHost, 8080);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: false,
    );
  });

  Future<bool> checkEmulatorAvailable() async {
    try {
      final authSocket = await Socket.connect(
        testHost,
        9098,
        timeout: const Duration(seconds: 2),
      );
      authSocket.destroy();
      final fsSocket = await Socket.connect(
        testHost,
        8080,
        timeout: const Duration(seconds: 2),
      );
      fsSocket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    final scrollableFinder = find.byType(Scrollable);
    if (scrollableFinder.evaluate().isEmpty) return;

    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: scrollableFinder.first,
    );
    await tester.pumpAndSettle();
  }

  group('Settings Screen', () {
    testWidgets('Settings screen renders with all sections', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('Theme toggle is accessible', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for theme-related options
      final themeFinder = find.textContaining('Theme');
      final darkModeFinder = find.textContaining('Dark');

      expect(
        themeFinder.evaluate().isNotEmpty || darkModeFinder.evaluate().isNotEmpty,
        isTrue,
        reason: 'Theme settings should be accessible',
      );
    });

    testWidgets('Notifications settings link exists', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for notifications option
      final notificationsFinder = find.textContaining('Notification');
      await scrollTo(tester, notificationsFinder.first);

      expect(notificationsFinder, findsWidgets);
    });

    testWidgets('Sign out button exists', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for sign out option
      final signOutFinder = find.textContaining('Sign Out');
      final logOutFinder = find.textContaining('Log Out');

      if (signOutFinder.evaluate().isEmpty && logOutFinder.evaluate().isEmpty) {
        await scrollTo(tester, find.text('Settings').last);
      }

      expect(
        signOutFinder.evaluate().isNotEmpty || logOutFinder.evaluate().isNotEmpty,
        isTrue,
        reason: 'Sign out option should exist',
      );
    });
  });

  group('Profile Screen', () {
    testWidgets('Profile screen renders user info', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Create user document
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'email': 'test@example.com',
        'displayName': 'Test User',
        'hasCompletedOnboarding': true,
        'createdAt': Timestamp.now(),
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Edit profile button exists', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'email': 'test@example.com',
        'displayName': 'Test User',
        'hasCompletedOnboarding': true,
        'createdAt': Timestamp.now(),
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for edit button or icon
      expect(
        find.byIcon(Icons.edit).evaluate().isNotEmpty ||
            find.text('Edit').evaluate().isNotEmpty ||
            find.text('Edit Profile').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('About Screen', () {
    testWidgets('About screen shows app info', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AboutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show app name
      expect(find.textContaining('Kinesa'), findsWidgets);
    });

    testWidgets('Version info is displayed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AboutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show version info
      expect(
        find.textContaining('Version').evaluate().isNotEmpty ||
            find.textContaining('version').evaluate().isNotEmpty ||
            find.textContaining('1.').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('Privacy Screen', () {
    testWidgets('Privacy screen renders', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PrivacyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyScreen), findsOneWidget);
    });

    testWidgets('Privacy settings are accessible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PrivacyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have privacy-related options
      expect(
        find.textContaining('Privacy').evaluate().isNotEmpty ||
            find.textContaining('Data').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('Notification Settings', () {
    testWidgets('Notification settings screen renders', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });

    testWidgets('Toggle switches are present', (tester) async {
      final emulatorAvailable = await checkEmulatorAvailable();
      if (!emulatorAvailable) {
        return;
      }

      await FirebaseAuth.instance.signInAnonymously();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have toggle switches for notification preferences
      expect(
        find.byType(Switch).evaluate().isNotEmpty ||
            find.byType(SwitchListTile).evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
