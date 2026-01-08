import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

/// Service for exporting user data
class DataExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Export all user data in the specified format (json or csv)
  Future<String> exportUserData(String userId, String format) async {
    if (format == 'json') {
      return await _exportToJson(userId);
    } else if (format == 'csv') {
      return await _exportToCsv(userId);
    } else {
      throw Exception('Unsupported format: $format');
    }
  }

  /// Export user data to JSON format
  Future<String> _exportToJson(String userId) async {
    try {
      final userData = await _collectAllUserData(userId);
      final normalizedData = _normalizeForJson(userData) as Map<String, dynamic>;

      // Convert to JSON
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(normalizedData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/kinesa_data_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export to JSON: $e');
    }
  }

  /// Export user data to CSV format (multiple files)
  Future<String> _exportToCsv(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final folderPath = '${directory.path}/kinesa_export_$timestamp';
      final folder = Directory(folderPath);
      await folder.create();

      // Export workouts to CSV
      await _exportWorkoutsToCsv(userId, folderPath);

      // Export habits to CSV
      await _exportHabitsToCsv(userId, folderPath);

      // Export weight to CSV
      await _exportWeightToCsv(userId, folderPath);

      // Export measurements to CSV
      await _exportMeasurementsToCsv(userId, folderPath);

      return folderPath;
    } catch (e) {
      throw Exception('Failed to export to CSV: $e');
    }
  }

  /// Collect all user data from Firestore
  Future<Map<String, dynamic>> _collectAllUserData(String userId) async {
    final data = <String, dynamic>{};

    // User profile
    final userDoc = await _firestore.collection('users').doc(userId).get();
    data['profile'] = userDoc.data() ?? {};

    // Workouts
    final workoutsSnapshot = await _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .get();
    data['workouts'] = workoutsSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Habits
    final habitsSnapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();
    data['habits'] = habitsSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Habit logs
    final habitLogsSnapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .get();
    data['habit_logs'] = habitLogsSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Weight entries
    final weightSnapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .get();
    data['weight_entries'] = weightSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Measurement entries
    final measurementsSnapshot = await _firestore
        .collection('measurement_entries')
        .where('userId', isEqualTo: userId)
        .get();
    data['measurement_entries'] = measurementsSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Goals
    final goalsSnapshot = await _firestore
        .collection('progress_goals')
        .where('userId', isEqualTo: userId)
        .get();
    data['goals'] = goalsSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Health data
    final healthSnapshot = await _firestore
        .collection('health_data')
        .where('userId', isEqualTo: userId)
        .get();
    data['health_data'] = healthSnapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    data['exported_at'] = DateTime.now().toIso8601String();
    data['user_id'] = userId;

    return data;
  }

  dynamic _normalizeForJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is GeoPoint) {
      return {
        'latitude': value.latitude,
        'longitude': value.longitude,
      };
    }
    if (value is DocumentReference) {
      return value.path;
    }
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), _normalizeForJson(val)),
      );
    }
    if (value is Iterable) {
      return value.map(_normalizeForJson).toList();
    }
    return value;
  }

  /// Export workouts to CSV
  Future<void> _exportWorkoutsToCsv(String userId, String folderPath) async {
    final snapshot = await _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final rows = <List<dynamic>>[
      ['Date', 'Workout', 'Duration (min)', 'Calories', 'Notes'],
    ];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = _formatDate(data['startedAt'] ?? data['date']);

      rows.add([
        date,
        data['workoutName'] ?? data['workoutType'] ?? 'N/A',
        data['duration'] ?? data['durationMinutes'] ?? 0,
        data['caloriesBurned'] ?? 0,
        data['notes'] ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('$folderPath/workouts.csv');
    await file.writeAsString(csv);
  }

  /// Export habits to CSV
  Future<void> _exportHabitsToCsv(String userId, String folderPath) async {
    // Export habits list
    final habitsSnapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();

    if (habitsSnapshot.docs.isNotEmpty) {
      final rows = <List<dynamic>>[
        ['Habit Name', 'Frequency', 'Active', 'Created At'],
      ];

      for (final doc in habitsSnapshot.docs) {
        final data = doc.data();
        final createdAt = _formatDate(data['createdAt']);

        rows.add([
          data['name'] ?? 'N/A',
          data['frequency'] ?? data['frequencyType'] ?? 'N/A',
          data['isActive'] ?? false,
          createdAt,
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final file = File('$folderPath/habits.csv');
      await file.writeAsString(csv);
    }

    // Export habit logs
    final logsSnapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .get();

    if (logsSnapshot.docs.isNotEmpty) {
      final rows = <List<dynamic>>[
        ['Date', 'Habit ID', 'Count', 'Notes'],
      ];

      for (final doc in logsSnapshot.docs) {
        final data = doc.data();
        final date = _formatDate(data['date']);

        rows.add([
          date,
          data['habitId'] ?? 'N/A',
          data['count'] ?? 1,
          data['notes'] ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final file = File('$folderPath/habit_logs.csv');
      await file.writeAsString(csv);
    }
  }

  /// Export weight to CSV
  Future<void> _exportWeightToCsv(String userId, String folderPath) async {
    final snapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final rows = <List<dynamic>>[
      ['Date', 'Weight (kg)', 'Notes'],
    ];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = _formatDate(data['date']);

      rows.add([
        date,
        data['weight'] ?? 0,
        data['notes'] ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('$folderPath/weight.csv');
    await file.writeAsString(csv);
  }

  /// Export measurements to CSV
  Future<void> _exportMeasurementsToCsv(
      String userId, String folderPath) async {
    final snapshot = await _firestore
        .collection('measurement_entries')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final rows = <List<dynamic>>[
      ['Date', 'Chest', 'Waist', 'Hips', 'Arms', 'Legs', 'Neck', 'Shoulders'],
    ];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = _formatDate(data['date']);
      final measurements = data['measurements'] as Map<String, dynamic>? ?? {};

      rows.add([
        date,
        measurements['chest'] ?? '',
        measurements['waist'] ?? '',
        measurements['hips'] ?? '',
        measurements['arms'] ?? '',
        measurements['legs'] ?? '',
        measurements['neck'] ?? '',
        measurements['shoulders'] ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('$folderPath/measurements.csv');
    await file.writeAsString(csv);
  }

  String _formatDate(dynamic rawDate) {
    DateTime? parsed;
    if (rawDate is Timestamp) {
      parsed = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsed = rawDate;
    } else if (rawDate is String) {
      parsed = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      parsed = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is Map) {
      final seconds = rawDate['seconds'];
      if (seconds is int) {
        parsed = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    if (parsed == null) {
      return 'N/A';
    }

    return parsed.toIso8601String().split('T').first;
  }
}
