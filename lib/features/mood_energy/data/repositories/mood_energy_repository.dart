import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/energy_log.dart';

final moodEnergyRepositoryProvider = Provider<MoodEnergyRepository>((ref) {
  return MoodEnergyRepository();
});

class MoodEnergyRepository {
  static const String _collection = 'mood_energy_logs';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> logEnergy(EnergyLog log) async {
    final data = log.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _firestore.collection(_collection).add(data);
    return docRef.id;
  }

  Future<List<EnergyLog>> getLogsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('loggedAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => EnergyLog.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }
}
