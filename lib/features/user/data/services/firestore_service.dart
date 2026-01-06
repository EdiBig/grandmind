import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

/// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _workoutsCollection = 'workouts';
  static const String _habitsCollection = 'habits';
  static const String _progressCollection = 'progress';

  // User Methods
  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_usersCollection).doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') {
        rethrow;
      }
      final createData = Map<String, dynamic>.from(data);
      createData['createdAt'] = Timestamp.now();
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(createData, SetOptions(merge: true));
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.exists && doc.data() != null)
            ? UserModel.fromFirestore(doc.data()!, doc.id)
            : null);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_usersCollection).doc(userId).delete();
  }

  // Workout Methods
  Future<void> addWorkout(String userId, Map<String, dynamic> workoutData) async {
    workoutData['userId'] = userId;
    workoutData['createdAt'] = Timestamp.now();
    await _firestore.collection(_workoutsCollection).add(workoutData);
  }

  Future<List<Map<String, dynamic>>> getUserWorkouts(String userId) async {
    final snapshot = await _firestore
        .collection(_workoutsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getUserWorkoutsStream(String userId) {
    return _firestore
        .collection(_workoutsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Habit Methods
  Future<void> addHabit(String userId, Map<String, dynamic> habitData) async {
    habitData['userId'] = userId;
    habitData['createdAt'] = Timestamp.now();
    await _firestore.collection(_habitsCollection).add(habitData);
  }

  Future<void> updateHabitProgress(
    String habitId,
    Map<String, dynamic> progressData,
  ) async {
    progressData['updatedAt'] = Timestamp.now();
    await _firestore.collection(_habitsCollection).doc(habitId).update(progressData);
  }

  Future<List<Map<String, dynamic>>> getUserHabits(String userId) async {
    final snapshot = await _firestore
        .collection(_habitsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getUserHabitsStream(String userId) {
    return _firestore
        .collection(_habitsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Progress Methods
  Future<void> logProgress(String userId, Map<String, dynamic> progressData) async {
    progressData['userId'] = userId;
    progressData['timestamp'] = Timestamp.now();
    await _firestore.collection(_progressCollection).add(progressData);
  }

  Future<List<Map<String, dynamic>>> getUserProgress(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(_progressCollection)
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.orderBy('timestamp', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Batch Operations
  Future<void> batchWrite(
    List<Future<void> Function(WriteBatch)> operations,
  ) async {
    final batch = _firestore.batch();
    for (final operation in operations) {
      await operation(batch);
    }
    await batch.commit();
  }
}
