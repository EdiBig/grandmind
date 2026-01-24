import 'package:hive/hive.dart';

/// Sync status for local records
@HiveType(typeId: 100)
enum SyncStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  synced,
  @HiveField(2)
  conflict,
  @HiveField(3)
  failed,
}

/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  preferLocal,
  preferServer,
  preferNewest,
  manualPrompt,
  fieldMerge,
}

/// A record that tracks sync state for offline-first data
class SyncRecord {
  final String id;
  final String collection;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final DateTime localUpdatedAt;
  final String clientId;
  final DateTime? serverUpdatedAt;
  final int? retryCount;
  final String? errorMessage;
  final bool isDeleted;

  const SyncRecord({
    required this.id,
    required this.collection,
    required this.data,
    required this.status,
    required this.localUpdatedAt,
    required this.clientId,
    this.serverUpdatedAt,
    this.retryCount,
    this.errorMessage,
    this.isDeleted = false,
  });

  /// Create a copy with updated fields
  SyncRecord copyWith({
    String? id,
    String? collection,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? localUpdatedAt,
    String? clientId,
    DateTime? serverUpdatedAt,
    int? retryCount,
    String? errorMessage,
    bool? isDeleted,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      data: data ?? this.data,
      status: status ?? this.status,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      clientId: clientId ?? this.clientId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'data': data,
      'status': status.index,
      'localUpdatedAt': localUpdatedAt.toIso8601String(),
      'clientId': clientId,
      'serverUpdatedAt': serverUpdatedAt?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'isDeleted': isDeleted,
    };
  }

  /// Create from JSON
  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      id: json['id'] as String,
      collection: json['collection'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      status: SyncStatus.values[json['status'] as int],
      localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
      clientId: json['clientId'] as String,
      serverUpdatedAt: json['serverUpdatedAt'] != null
          ? DateTime.parse(json['serverUpdatedAt'] as String)
          : null,
      retryCount: json['retryCount'] as int?,
      errorMessage: json['errorMessage'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SyncRecord(id: $id, collection: $collection, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncRecord &&
        other.id == id &&
        other.collection == collection;
  }

  @override
  int get hashCode => id.hashCode ^ collection.hashCode;
}

/// Hive adapter for SyncRecord
class SyncRecordAdapter extends TypeAdapter<SyncRecord> {
  @override
  final int typeId = 101;

  @override
  SyncRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncRecord(
      id: fields[0] as String,
      collection: fields[1] as String,
      data: Map<String, dynamic>.from(fields[2] as Map),
      status: SyncStatus.values[fields[3] as int],
      localUpdatedAt: DateTime.parse(fields[4] as String),
      clientId: fields[5] as String,
      serverUpdatedAt: fields[6] != null
          ? DateTime.parse(fields[6] as String)
          : null,
      retryCount: fields[7] as int?,
      errorMessage: fields[8] as String?,
      isDeleted: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SyncRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collection)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.status.index)
      ..writeByte(4)
      ..write(obj.localUpdatedAt.toIso8601String())
      ..writeByte(5)
      ..write(obj.clientId)
      ..writeByte(6)
      ..write(obj.serverUpdatedAt?.toIso8601String())
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.errorMessage)
      ..writeByte(9)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Sync history entry for audit logging
class SyncHistoryEntry {
  final String id;
  final String recordId;
  final String collection;
  final String action; // 'create', 'update', 'delete', 'conflict_resolved'
  final DateTime timestamp;
  final SyncStatus previousStatus;
  final SyncStatus newStatus;
  final String? errorMessage;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? serverData;
  final String? resolutionStrategy;

  const SyncHistoryEntry({
    required this.id,
    required this.recordId,
    required this.collection,
    required this.action,
    required this.timestamp,
    required this.previousStatus,
    required this.newStatus,
    this.errorMessage,
    this.localData,
    this.serverData,
    this.resolutionStrategy,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordId': recordId,
      'collection': collection,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'previousStatus': previousStatus.index,
      'newStatus': newStatus.index,
      'errorMessage': errorMessage,
      'localData': localData,
      'serverData': serverData,
      'resolutionStrategy': resolutionStrategy,
    };
  }

  /// Create from JSON
  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SyncHistoryEntry(
      id: json['id'] as String,
      recordId: json['recordId'] as String,
      collection: json['collection'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      previousStatus: SyncStatus.values[json['previousStatus'] as int],
      newStatus: SyncStatus.values[json['newStatus'] as int],
      errorMessage: json['errorMessage'] as String?,
      localData: json['localData'] != null
          ? Map<String, dynamic>.from(json['localData'] as Map)
          : null,
      serverData: json['serverData'] != null
          ? Map<String, dynamic>.from(json['serverData'] as Map)
          : null,
      resolutionStrategy: json['resolutionStrategy'] as String?,
    );
  }

  @override
  String toString() {
    return 'SyncHistoryEntry(recordId: $recordId, action: $action, timestamp: $timestamp)';
  }
}

/// Hive adapter for SyncHistoryEntry
class SyncHistoryEntryAdapter extends TypeAdapter<SyncHistoryEntry> {
  @override
  final int typeId = 102;

  @override
  SyncHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncHistoryEntry(
      id: fields[0] as String,
      recordId: fields[1] as String,
      collection: fields[2] as String,
      action: fields[3] as String,
      timestamp: DateTime.parse(fields[4] as String),
      previousStatus: SyncStatus.values[fields[5] as int],
      newStatus: SyncStatus.values[fields[6] as int],
      errorMessage: fields[7] as String?,
      localData: fields[8] != null
          ? Map<String, dynamic>.from(fields[8] as Map)
          : null,
      serverData: fields[9] != null
          ? Map<String, dynamic>.from(fields[9] as Map)
          : null,
      resolutionStrategy: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncHistoryEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordId)
      ..writeByte(2)
      ..write(obj.collection)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.timestamp.toIso8601String())
      ..writeByte(5)
      ..write(obj.previousStatus.index)
      ..writeByte(6)
      ..write(obj.newStatus.index)
      ..writeByte(7)
      ..write(obj.errorMessage)
      ..writeByte(8)
      ..write(obj.localData)
      ..writeByte(9)
      ..write(obj.serverData)
      ..writeByte(10)
      ..write(obj.resolutionStrategy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
