import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a challenge invitation
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// Type of invitation
enum InvitationType {
  /// Direct invitation from another user
  direct,

  /// Invitation via shareable link
  link,

  /// System recommendation
  recommendation,
}

/// Model for challenge invitations
class ChallengeInvitation {
  const ChallengeInvitation({
    required this.id,
    required this.challengeId,
    required this.challengeName,
    required this.inviteeId,
    required this.inviterId,
    required this.inviterName,
    required this.type,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
    this.message,
    this.inviteCode,
  });

  final String id;
  final String challengeId;
  final String challengeName;
  final String inviteeId;
  final String inviterId;
  final String inviterName;
  final InvitationType type;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? message;
  final String? inviteCode;

  factory ChallengeInvitation.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeInvitation(
      id: id,
      challengeId: data['challengeId'] as String? ?? '',
      challengeName: data['challengeName'] as String? ?? '',
      inviteeId: data['inviteeId'] as String? ?? '',
      inviterId: data['inviterId'] as String? ?? '',
      inviterName: data['inviterName'] as String? ?? '',
      type: InvitationType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => InvitationType.direct,
      ),
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: _parseTimestamp(data['createdAt']),
      expiresAt: data['expiresAt'] != null
          ? _parseTimestamp(data['expiresAt'])
          : null,
      respondedAt: data['respondedAt'] != null
          ? _parseTimestamp(data['respondedAt'])
          : null,
      message: data['message'] as String?,
      inviteCode: data['inviteCode'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'challengeName': challengeName,
      'inviteeId': inviteeId,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
      if (message != null) 'message': message,
      if (inviteCode != null) 'inviteCode': inviteCode,
    };
  }

  /// Check if invitation is still valid
  bool get isValid {
    if (status != InvitationStatus.pending) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Create a copy with updated status
  ChallengeInvitation copyWith({
    InvitationStatus? status,
    DateTime? respondedAt,
  }) {
    return ChallengeInvitation(
      id: id,
      challengeId: challengeId,
      challengeName: challengeName,
      inviteeId: inviteeId,
      inviterId: inviterId,
      inviterName: inviterName,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message,
      inviteCode: inviteCode,
    );
  }
}

/// Shareable invite link data
class ChallengeInviteLink {
  const ChallengeInviteLink({
    required this.id,
    required this.challengeId,
    required this.creatorId,
    required this.code,
    required this.createdAt,
    this.expiresAt,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
  });

  final String id;
  final String challengeId;
  final String creatorId;
  final String code;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int? maxUses;
  final int usedCount;
  final bool isActive;

  factory ChallengeInviteLink.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeInviteLink(
      id: id,
      challengeId: data['challengeId'] as String? ?? '',
      creatorId: data['creatorId'] as String? ?? '',
      code: data['code'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      expiresAt: data['expiresAt'] != null
          ? _parseTimestamp(data['expiresAt'])
          : null,
      maxUses: data['maxUses'] as int?,
      usedCount: (data['usedCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'creatorId': creatorId,
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (maxUses != null) 'maxUses': maxUses,
      'usedCount': usedCount,
      'isActive': isActive,
    };
  }

  /// Check if link is still valid
  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;
    return true;
  }

  /// Generate shareable URL
  String get shareUrl => 'https://kinesa.app/join/$code';
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}
