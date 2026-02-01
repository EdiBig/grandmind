/// Firebase mock setup utilities for testing
///
/// Provides utilities for setting up Firebase mocks in tests.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ========== Firestore Test Helpers ==========

/// Creates a FakeFirebaseFirestore instance for testing
///
/// This should be used in tests that need Firestore operations.
FakeFirebaseFirestore createFakeFirestore() {
  return FakeFirebaseFirestore();
}

/// Seeds a Firestore collection with test data
///
/// Example:
/// ```dart
/// final firestore = createFakeFirestore();
/// await seedCollection(
///   firestore: firestore,
///   collection: 'habits',
///   documents: [
///     {'id': '1', 'name': 'Test Habit'},
///   ],
/// );
/// ```
Future<void> seedCollection({
  required FakeFirebaseFirestore firestore,
  required String collection,
  required List<Map<String, dynamic>> documents,
}) async {
  for (final doc in documents) {
    final id = doc['id'] as String?;
    final data = Map<String, dynamic>.from(doc)..remove('id');

    if (id != null) {
      await firestore.collection(collection).doc(id).set(data);
    } else {
      await firestore.collection(collection).add(data);
    }
  }
}

/// Seeds a Firestore subcollection with test data
///
/// Example:
/// ```dart
/// await seedSubcollection(
///   firestore: firestore,
///   parentCollection: 'users',
///   parentId: 'user-123',
///   subcollection: 'habits',
///   documents: [...],
/// );
/// ```
Future<void> seedSubcollection({
  required FakeFirebaseFirestore firestore,
  required String parentCollection,
  required String parentId,
  required String subcollection,
  required List<Map<String, dynamic>> documents,
}) async {
  for (final doc in documents) {
    final id = doc['id'] as String?;
    final data = Map<String, dynamic>.from(doc)..remove('id');

    final collectionRef = firestore
        .collection(parentCollection)
        .doc(parentId)
        .collection(subcollection);

    if (id != null) {
      await collectionRef.doc(id).set(data);
    } else {
      await collectionRef.add(data);
    }
  }
}

// ========== Timestamp Helpers ==========

/// Converts a DateTime to a Firestore Timestamp
Timestamp toTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

/// Creates a Timestamp for the start of a given date
Timestamp startOfDayTimestamp(DateTime date) {
  return Timestamp.fromDate(DateTime(date.year, date.month, date.day));
}

/// Creates a Timestamp for the end of a given date
Timestamp endOfDayTimestamp(DateTime date) {
  return Timestamp.fromDate(
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999),
  );
}
