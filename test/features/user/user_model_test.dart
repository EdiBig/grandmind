import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('creates instance with required fields', () {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.createdAt, testDate);
        expect(user.updatedAt, testDate);
        expect(user.hasCompletedOnboarding, isFalse);
      });

      test('creates instance with all optional fields', () {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://photo.url',
          phoneNumber: '+1234567890',
          dateOfBirth: DateTime(1990, 5, 15),
          gender: 'Male',
          height: 175.5,
          weight: 70.0,
          fitnessLevel: 'Intermediate',
          goal: 'Build Muscle',
          onboarding: {'completed': true, 'step': 5},
          preferences: {'units': 'Metric'},
          hasCompletedOnboarding: true,
          signInProvider: 'google.com',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(user.displayName, 'Test User');
        expect(user.photoUrl, 'https://photo.url');
        expect(user.phoneNumber, '+1234567890');
        expect(user.gender, 'Male');
        expect(user.height, 175.5);
        expect(user.weight, 70.0);
        expect(user.fitnessLevel, 'Intermediate');
        expect(user.goal, 'Build Muscle');
        expect(user.hasCompletedOnboarding, isTrue);
        expect(user.signInProvider, 'google.com');
      });
    });

    group('fromFirestore', () {
      test('creates instance from Firestore data with Timestamps', () {
        final firestoreData = {
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://photo.url',
          'phoneNumber': '+1234567890',
          'dateOfBirth': Timestamp.fromDate(DateTime(1990, 5, 15)),
          'gender': 'Male',
          'height': 175.5,
          'weight': 70.0,
          'fitnessLevel': 'Intermediate',
          'goal': 'Build Muscle',
          'onboarding': {'completed': true},
          'preferences': {'units': 'Metric'},
          'hasCompletedOnboarding': true,
          'signInProvider': 'google.com',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoUrl, 'https://photo.url');
        expect(user.gender, 'Male');
        expect(user.height, 175.5);
        expect(user.weight, 70.0);
        expect(user.hasCompletedOnboarding, isTrue);
        expect(user.signInProvider, 'google.com');
      });

      test('handles missing optional fields', () {
        final firestoreData = {
          'email': 'test@example.com',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.height, isNull);
        expect(user.weight, isNull);
        expect(user.hasCompletedOnboarding, isFalse);
      });

      test('handles photoURL as alternative to photoUrl', () {
        final firestoreData = {
          'email': 'test@example.com',
          'photoURL': 'https://photo.url',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.photoUrl, 'https://photo.url');
      });

      test('derives hasCompletedOnboarding from onboarding.completed', () {
        final firestoreData = {
          'email': 'test@example.com',
          'onboarding': {'completed': true, 'step': 5},
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.hasCompletedOnboarding, isTrue);
      });

      test('handles null timestamps by using current time', () {
        final firestoreData = {
          'email': 'test@example.com',
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });

      test('handles DateTime values directly', () {
        final firestoreData = {
          'email': 'test@example.com',
          'createdAt': testDate,
          'updatedAt': testDate,
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.createdAt, testDate);
        expect(user.updatedAt, testDate);
      });

      test('converts numeric height and weight to double', () {
        final firestoreData = {
          'email': 'test@example.com',
          'height': 175, // int
          'weight': 70, // int
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        };

        final user = UserModel.fromFirestore(firestoreData, 'test-id');

        expect(user.height, 175.0);
        expect(user.weight, 70.0);
      });
    });

    group('toFirestore', () {
      test('converts model to Firestore data', () {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://photo.url',
          phoneNumber: '+1234567890',
          dateOfBirth: DateTime(1990, 5, 15),
          gender: 'Male',
          height: 175.5,
          weight: 70.0,
          fitnessLevel: 'Intermediate',
          goal: 'Build Muscle',
          onboarding: {'completed': true},
          preferences: {'units': 'Metric'},
          hasCompletedOnboarding: true,
          signInProvider: 'google.com',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final data = user.toFirestore();

        expect(data['uid'], 'test-id');
        expect(data['email'], 'test@example.com');
        expect(data['displayName'], 'Test User');
        expect(data['photoUrl'], 'https://photo.url');
        expect(data['phoneNumber'], '+1234567890');
        expect(data['gender'], 'Male');
        expect(data['height'], 175.5);
        expect(data['weight'], 70.0);
        expect(data['fitnessLevel'], 'Intermediate');
        expect(data['goal'], 'Build Muscle');
        expect(data['hasCompletedOnboarding'], isTrue);
        expect(data['signInProvider'], 'google.com');
        expect(data['createdAt'], isA<Timestamp>());
        expect(data['updatedAt'], isA<Timestamp>());
      });

      test('converts dateOfBirth to Timestamp', () {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          dateOfBirth: DateTime(1990, 5, 15),
          createdAt: testDate,
          updatedAt: testDate,
        );

        final data = user.toFirestore();

        expect(data['dateOfBirth'], isA<Timestamp>());
      });

      test('handles null optional fields', () {
        final user = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final data = user.toFirestore();

        expect(data['displayName'], isNull);
        expect(data['photoUrl'], isNull);
        expect(data['dateOfBirth'], isNull);
        expect(data['gender'], isNull);
        expect(data['height'], isNull);
        expect(data['weight'], isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Original Name',
          height: 175.0,
          weight: 70.0,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(
          displayName: 'New Name',
          weight: 75.0,
        );

        expect(copy.id, 'test-id'); // Unchanged
        expect(copy.email, 'test@example.com'); // Unchanged
        expect(copy.displayName, 'New Name'); // Changed
        expect(copy.height, 175.0); // Unchanged
        expect(copy.weight, 75.0); // Changed
      });

      test('preserves all fields when no changes specified', () {
        final original = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://photo.url',
          phoneNumber: '+1234567890',
          gender: 'Male',
          height: 175.5,
          weight: 70.0,
          fitnessLevel: 'Intermediate',
          goal: 'Build Muscle',
          hasCompletedOnboarding: true,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.photoUrl, original.photoUrl);
        expect(copy.phoneNumber, original.phoneNumber);
        expect(copy.gender, original.gender);
        expect(copy.height, original.height);
        expect(copy.weight, original.weight);
        expect(copy.fitnessLevel, original.fitnessLevel);
        expect(copy.goal, original.goal);
        expect(copy.hasCompletedOnboarding, original.hasCompletedOnboarding);
      });

      test('allows updating boolean hasCompletedOnboarding', () {
        final original = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          hasCompletedOnboarding: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(hasCompletedOnboarding: true);

        expect(copy.hasCompletedOnboarding, isTrue);
      });

      test('allows updating onboarding map', () {
        final original = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          onboarding: {'completed': false, 'step': 1},
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(
          onboarding: {'completed': true, 'step': 5},
        );

        expect(copy.onboarding?['completed'], isTrue);
        expect(copy.onboarding?['step'], 5);
      });
    });
  });
}
