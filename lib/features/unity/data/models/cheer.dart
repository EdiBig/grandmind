import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a cheer/encouragement sent between users
class Cheer {
  const Cheer({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.activityId,
    this.postId,
    this.challengeId,
    this.circleId,
    this.message,
    required this.sentAt,
    this.isAnonymous = false,
    this.isRead = false,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final CheerType type;

  /// Reference to specific activity (if cheering an activity)
  final String? activityId;

  /// Reference to feed post (if cheering a post)
  final String? postId;

  /// Reference to challenge context
  final String? challengeId;

  /// Reference to circle context
  final String? circleId;

  /// Optional personal message
  final String? message;

  final DateTime sentAt;
  final bool isAnonymous;
  final bool isRead;
  final DateTime? readAt;

  /// Display sender name
  String senderDisplayName(String? actualName) {
    if (isAnonymous) return 'Someone';
    return actualName ?? 'A friend';
  }

  factory Cheer.fromFirestore(Map<String, dynamic> data, String id) {
    return Cheer(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      type: CheerType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => CheerType.proudOfYou,
      ),
      activityId: data['activityId'] as String?,
      postId: data['postId'] as String?,
      challengeId: data['challengeId'] as String?,
      circleId: data['circleId'] as String?,
      message: data['message'] as String?,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      isRead: data['isRead'] as bool? ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      if (activityId != null) 'activityId': activityId,
      if (postId != null) 'postId': postId,
      if (challengeId != null) 'challengeId': challengeId,
      if (circleId != null) 'circleId': circleId,
      if (message != null) 'message': message,
      'sentAt': Timestamp.fromDate(sentAt),
      'isAnonymous': isAnonymous,
      'isRead': isRead,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
    };
  }

  Cheer copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    CheerType? type,
    String? activityId,
    String? postId,
    String? challengeId,
    String? circleId,
    String? message,
    DateTime? sentAt,
    bool? isAnonymous,
    bool? isRead,
    DateTime? readAt,
  }) {
    return Cheer(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      activityId: activityId ?? this.activityId,
      postId: postId ?? this.postId,
      challengeId: challengeId ?? this.challengeId,
      circleId: circleId ?? this.circleId,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Mark as read
  Cheer markRead() => copyWith(isRead: true, readAt: DateTime.now());

  /// Create a cheer for an activity
  factory Cheer.forActivity({
    required String senderId,
    required String receiverId,
    required CheerType type,
    required String activityId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) {
    return Cheer(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      activityId: activityId,
      challengeId: challengeId,
      message: message,
      sentAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );
  }

  /// Create a cheer for a post
  factory Cheer.forPost({
    required String senderId,
    required String receiverId,
    required CheerType type,
    required String postId,
    String? circleId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) {
    return Cheer(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      postId: postId,
      circleId: circleId,
      challengeId: challengeId,
      message: message,
      sentAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );
  }

  /// Create a general encouragement cheer
  factory Cheer.encouragement({
    required String senderId,
    required String receiverId,
    required CheerType type,
    String? challengeId,
    String? circleId,
    String? message,
    bool isAnonymous = false,
  }) {
    return Cheer(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      challengeId: challengeId,
      circleId: circleId,
      message: message,
      sentAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );
  }
}

/// Aggregated cheer stats for a user
class CheerStats {
  const CheerStats({
    this.totalReceived = 0,
    this.totalSent = 0,
    this.receivedByType = const {},
    this.sentByType = const {},
    this.uniqueSenders = 0,
    this.uniqueReceivers = 0,
  });

  final int totalReceived;
  final int totalSent;
  final Map<String, int> receivedByType;
  final Map<String, int> sentByType;
  final int uniqueSenders;
  final int uniqueReceivers;

  /// Get count received for a specific cheer type
  int receivedCount(CheerType type) => receivedByType[type.name] ?? 0;

  /// Get count sent for a specific cheer type
  int sentCount(CheerType type) => sentByType[type.name] ?? 0;

  factory CheerStats.fromFirestore(Map<String, dynamic> data) {
    return CheerStats(
      totalReceived: data['totalReceived'] as int? ?? 0,
      totalSent: data['totalSent'] as int? ?? 0,
      receivedByType: (data['receivedByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      sentByType: (data['sentByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      uniqueSenders: data['uniqueSenders'] as int? ?? 0,
      uniqueReceivers: data['uniqueReceivers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalReceived': totalReceived,
      'totalSent': totalSent,
      'receivedByType': receivedByType,
      'sentByType': sentByType,
      'uniqueSenders': uniqueSenders,
      'uniqueReceivers': uniqueReceivers,
    };
  }
}
