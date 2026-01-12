import 'package:cloud_firestore/cloud_firestore.dart';

class EnergyLog {
  final String id;
  final String userId;
  final DateTime loggedAt;
  final int? energyBefore;
  final int? energyAfter;
  final List<String> tags;
  final String? notes;
  final String? source;

  EnergyLog({
    required this.id,
    required this.userId,
    required this.loggedAt,
    this.energyBefore,
    this.energyAfter,
    this.tags = const [],
    this.notes,
    this.source,
  });

  double? get averageEnergy {
    final values = <int>[
      if (energyBefore != null) energyBefore!,
      if (energyAfter != null) energyAfter!,
    ];
    if (values.isEmpty) return null;
    final total = values.fold<int>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  factory EnergyLog.fromJson(Map<String, dynamic> json) {
    final loggedAt = _parseTimestamp(json['loggedAt']) ?? DateTime.now();
    return EnergyLog(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      loggedAt: loggedAt,
      energyBefore: (json['energyBefore'] as num?)?.toInt(),
      energyAfter: (json['energyAfter'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((tag) => tag.toString())
          .toList(),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'loggedAt': Timestamp.fromDate(loggedAt),
      if (energyBefore != null) 'energyBefore': energyBefore,
      if (energyAfter != null) 'energyAfter': energyAfter,
      if (tags.isNotEmpty) 'tags': tags,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (source != null) 'source': source,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
