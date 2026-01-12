import 'package:cloud_firestore/cloud_firestore.dart';

class UserSavedWorkout {
  const UserSavedWorkout({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.savedAt,
    this.folderName,
    this.notes,
  });

  final String id;
  final String userId;
  final String workoutId;
  final DateTime savedAt;
  final String? folderName;
  final String? notes;

  factory UserSavedWorkout.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return UserSavedWorkout(
      id: id,
      userId: json['userId'] as String? ?? '',
      workoutId: json['workoutId'] as String? ?? '',
      savedAt: _parseSavedAt(json['savedAt']),
      folderName: json['folderName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static DateTime _parseSavedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}
