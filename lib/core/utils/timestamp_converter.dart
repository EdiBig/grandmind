import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Custom JSON converter to handle Firestore Timestamp to DateTime conversion
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) {
      throw ArgumentError('Cannot convert null to DateTime');
    }

    // If it's already a DateTime, return it
    if (json is DateTime) {
      return json;
    }

    // If it's a Firestore Timestamp, convert it
    if (json is Timestamp) {
      return json.toDate();
    }

    // If it's a String, parse it
    if (json is String) {
      return DateTime.parse(json);
    }

    // If it's a Map (server timestamp), try to get milliseconds
    if (json is Map) {
      if (json.containsKey('_seconds')) {
        final seconds = json['_seconds'] as int;
        final nanoseconds = json['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
    }

    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  dynamic toJson(DateTime object) => Timestamp.fromDate(object);
}

/// Custom JSON converter for nullable DateTime fields
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }

    // If it's already a DateTime, return it
    if (json is DateTime) {
      return json;
    }

    // If it's a Firestore Timestamp, convert it
    if (json is Timestamp) {
      return json.toDate();
    }

    // If it's a String, parse it
    if (json is String) {
      return DateTime.parse(json);
    }

    // If it's a Map (server timestamp), try to get milliseconds
    if (json is Map) {
      if (json.containsKey('_seconds')) {
        final seconds = json['_seconds'] as int;
        final nanoseconds = json['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      }
    }

    return null;
  }

  @override
  dynamic toJson(DateTime? object) => object != null ? Timestamp.fromDate(object) : null;
}
