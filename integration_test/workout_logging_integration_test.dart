import 'dart:io' show Platform, Socket;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinesa/features/workouts/presentation/screens/workout_logging_screen.dart';
import 'package:kinesa/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> configureFirebaseEmulators() async {
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    FirebaseAuth.instance.useAuthEmulator(host, 9098);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: false,
    );
  }

  Future<void> assertEmulatorAvailable(String host) async {
    try {
      final authSocket =
          await Socket.connect(host, 9098, timeout: const Duration(seconds: 2));
      authSocket.destroy();
      final fsSocket =
          await Socket.connect(host, 8080, timeout: const Duration(seconds: 2));
      fsSocket.destroy();
    } catch (_) {
      fail(
        'Firebase emulators not reachable. Start them with '
        '`firebase emulators:start --only auth,firestore`.',
      );
    }
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Workout logging flow writes to Firestore emulator',
      (tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await configureFirebaseEmulators();
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    await assertEmulatorAvailable(host);
    final credential = await FirebaseAuth.instance.signInAnonymously();
    expect(credential.user, isNotNull);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final smokeRef = FirebaseFirestore.instance.collection('workout_logs').doc();
    await smokeRef.set({
      'userId': userId,
      'workoutName': 'Smoke',
      'workoutId': '',
      'startedAt': Timestamp.fromDate(DateTime.now()),
      'duration': 1,
      'exercises': [],
    });
    final smokeDoc = await smokeRef.get();
    expect(smokeDoc.exists, isTrue, reason: 'Firestore emulator not writable.');

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutLoggingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final strengthFinder = find.text('Strength');
    await scrollTo(tester, strengthFinder);
    await tester.tap(strengthFinder);
    await tester.pumpAndSettle();

    final continueFinder = find.text('Continue to details');
    await scrollTo(tester, continueFinder);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // If type selection did not register, the snackbar will appear.
    if (find.text('Select a workout type to continue').evaluate().isNotEmpty) {
      await tester.tap(strengthFinder);
      await tester.pumpAndSettle();
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();
    }

    expect(find.text('Details'), findsOneWidget);

    final addExerciseField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Add exercise',
    );
    await scrollTo(tester, addExerciseField);
    await tester.enterText(addExerciseField, 'Push Up');
    final addIconFinder = find.byIcon(Icons.add_circle);
    await scrollTo(tester, addIconFinder);
    await tester.tap(addIconFinder);
    await tester.pumpAndSettle();

    final setsField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Sets',
    );
    final repsField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Reps',
    );
    final weightField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Weight',
    );

    await scrollTo(tester, setsField);
    await tester.enterText(setsField, '4');
    await tester.enterText(repsField, '12');
    await tester.enterText(weightField, '50');

    final durationField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.decoration?.hintText?.contains('minutes') ?? false),
    );
    await scrollTo(tester, durationField);
    await tester.enterText(durationField, '45');

    await scrollTo(tester, find.text('3').first);
    await tester.tap(find.text('3').first);
    await tester.tap(find.text('5').last);
    await tester.pump();

    final notesField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'How did it feel?',
    );
    await scrollTo(tester, notesField);
    await tester.enterText(notesField, 'Felt strong');

    await scrollTo(tester, find.text('Tired'));
    await tester.tap(find.text('Tired'));
    await tester.tap(find.text('Great'));
    await tester.pump();

    final saveFinder = find.text('Save Workout');
    await scrollTo(tester, saveFinder);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));

    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .where('workoutName', isEqualTo: 'Strength')
        .get();

    for (var i = 0; i < 5 && query.docs.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      query = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .where('workoutName', isEqualTo: 'Strength')
          .get();
    }

    if (query.docs.isEmpty) {
      final fallback = await FirebaseFirestore.instance
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .get();
      if (fallback.docs.isNotEmpty) {
        // Print for diagnostics in test output.
        for (final doc in fallback.docs) {
          // ignore: avoid_print
          print('Found workout log: ${doc.data()}');
        }
      }
      final errorTextFinder = find.textContaining('Error logging workout');
      if (errorTextFinder.evaluate().isNotEmpty) {
        // ignore: avoid_print
        print('Workout logging error shown in UI.');
        final errorTextWidget =
            tester.widget<Text>(errorTextFinder.first);
        // ignore: avoid_print
        print('SnackBar error text: ${errorTextWidget.data}');
      }
    }

    expect(
      query.docs,
      isNotEmpty,
      reason:
          'No workout_logs found for user $userId. Check emulator connectivity.',
    );
    final doc = query.docs.first.data();
    expect(doc['workoutName'], 'Strength');
    expect(doc['duration'], 45);
    expect(doc['notes'], contains('Felt strong'));
    expect(doc['notes'], contains('Energy before: 3, after: 5'));
    expect(doc['notes'], contains('Context: Tired, Great'));
  });
}
