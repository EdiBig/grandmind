import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/measurement_entry.dart';
import '../../domain/models/progress_photo.dart';
import '../../domain/models/progress_goal.dart';

/// Provider for ProgressRepository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== WEIGHT ENTRIES ==========

  /// Create a new weight entry
  Future<String> createWeightEntry(WeightEntry entry) async {
    final entryData = entry.toJson();
    entryData['createdAt'] = FieldValue.serverTimestamp();
    entryData['date'] = Timestamp.fromDate(entry.date);

    final docRef = await _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .add(entryData);
    return docRef.id;
  }

  /// Get weight entries for a user with optional date range
  Future<List<WeightEntry>> getWeightEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date',
          isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
    }

    query = query.orderBy('date', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => WeightEntry.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get weight entries stream
  Stream<List<WeightEntry>> getWeightEntriesStream(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date',
          isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
    }

    query = query.orderBy('date', descending: true);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => WeightEntry.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList());
  }

  /// Get the latest weight entry for a user
  Future<WeightEntry?> getLatestWeight(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return WeightEntry.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Update a weight entry
  Future<void> updateWeightEntry(
      String entryId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .doc(entryId)
        .update(data);
  }

  /// Delete a weight entry
  Future<void> deleteWeightEntry(String entryId) async {
    await _firestore
        .collection(FirebaseConstants.progressWeightCollection)
        .doc(entryId)
        .delete();
  }

  // ========== MEASUREMENTS ==========

  /// Create a new measurement entry
  Future<String> createMeasurementEntry(MeasurementEntry entry) async {
    final entryData = entry.toJson();
    entryData['createdAt'] = FieldValue.serverTimestamp();
    entryData['date'] = Timestamp.fromDate(entry.date);

    final docRef = await _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .add(entryData);
    return docRef.id;
  }

  /// Get measurement entries for a user
  Future<List<MeasurementEntry>> getMeasurementEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date',
          isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => MeasurementEntry.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get measurement entries stream
  Stream<List<MeasurementEntry>> getMeasurementEntriesStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MeasurementEntry.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  /// Get latest measurements
  Future<MeasurementEntry?> getLatestMeasurements(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return MeasurementEntry.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Get baseline (first) measurements
  Future<MeasurementEntry?> getBaselineMeasurements(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return MeasurementEntry.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Update a measurement entry
  Future<void> updateMeasurementEntry(
      String entryId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .doc(entryId)
        .update(data);
  }

  /// Delete a measurement entry
  Future<void> deleteMeasurementEntry(String entryId) async {
    await _firestore
        .collection(FirebaseConstants.progressMeasurementsCollection)
        .doc(entryId)
        .delete();
  }

  // ========== PROGRESS PHOTOS ==========

  /// Create a new progress photo entry
  Future<String> createProgressPhoto(ProgressPhoto photo) async {
    final photoData = photo.toJson();
    photoData['createdAt'] = FieldValue.serverTimestamp();
    photoData['date'] = Timestamp.fromDate(photo.date);

    final docRef = await _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .add(photoData);
    return docRef.id;
  }

  /// Get progress photos for a user
  Future<List<ProgressPhoto>> getProgressPhotos(
    String userId, {
    PhotoAngle? angle,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .where('userId', isEqualTo: userId);

    if (angle != null) {
      query = query.where('angle', isEqualTo: angle.name);
    }

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date',
          isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ProgressPhoto.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get photo for a specific angle and date (enforce one per angle per day)
  Future<ProgressPhoto?> getPhotoForAngleAndDate(
    String userId,
    PhotoAngle angle,
    DateTime date,
  ) async {
    // Normalize date to start of day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .where('userId', isEqualTo: userId)
        .where('angle', isEqualTo: angle.name)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ProgressPhoto.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Get progress photos stream
  Stream<List<ProgressPhoto>> getProgressPhotosStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressPhoto.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  /// Update a progress photo
  Future<void> updateProgressPhoto(
      String photoId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .doc(photoId)
        .update(data);
  }

  /// Delete a progress photo (metadata only, Storage handled separately)
  Future<void> deleteProgressPhoto(String photoId) async {
    await _firestore
        .collection(FirebaseConstants.progressPhotosCollection)
        .doc(photoId)
        .delete();
  }

  // ========== GOALS ==========

  /// Create a new goal
  Future<String> createGoal(ProgressGoal goal) async {
    final goalData = goal.toJson();

    final docRef = await _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .add(goalData);
    return docRef.id;
  }

  /// Get goals for a user
  Future<List<ProgressGoal>> getGoals(
    String userId, {
    GoalStatus? status,
  }) async {
    Query query = _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    query = query.orderBy('startDate', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ProgressGoal.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get active goals stream
  Stream<List<ProgressGoal>> getActiveGoalsStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: GoalStatus.active.name)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressGoal.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  /// Update a goal
  Future<void> updateGoal(String goalId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .doc(goalId)
        .update(data);
  }

  /// Update goal progress and check for completion
  Future<void> updateGoalProgress(String goalId, double newValue) async {
    final goalDoc = await _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .doc(goalId)
        .get();

    if (!goalDoc.exists) return;

    final goal = ProgressGoal.fromJson({
      ...goalDoc.data()!,
      'id': goalDoc.id,
    });

    // Update current value
    final updateData = <String, dynamic>{'currentValue': newValue};

    // Check if goal is completed
    final updatedGoal = goal.copyWith(currentValue: newValue);
    if (updatedGoal.isCompleted && goal.status == GoalStatus.active) {
      updateData['status'] = GoalStatus.completed.name;
      updateData['completedDate'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .doc(goalId)
        .update(updateData);
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _firestore
        .collection(FirebaseConstants.progressGoalsCollection)
        .doc(goalId)
        .delete();
  }
}
