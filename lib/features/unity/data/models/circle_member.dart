import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a member of a Circle
class CircleMember {
  const CircleMember({
    required this.userId,
    required this.circleId,
    this.displayName,
    this.avatarUrl,
    this.role = CircleMemberRole.member,
    required this.joinedAt,
    this.lastSeenAt,
    this.notificationsEnabled = true,
    this.isMuted = false,
    this.mutedUntil,
    this.invitedBy,
    this.totalCheersGiven = 0,
    this.totalCheersReceived = 0,
    this.challengesCompleted = 0,
    this.currentStreak = 0,
    this.lastActivityAt,
    this.bio,
    this.status,
  });

  final String userId;
  final String circleId;
  final String? displayName;
  final String? avatarUrl;
  final CircleMemberRole role;
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool notificationsEnabled;
  final bool isMuted;
  final DateTime? mutedUntil;
  final String? invitedBy;
  final int totalCheersGiven;
  final int totalCheersReceived;
  final int challengesCompleted;
  final int currentStreak;
  final DateTime? lastActivityAt;
  final String? bio;
  final String? status;

  /// Whether member has admin privileges
  bool get isAdmin => role.canManageMembers;

  /// Whether member is the owner
  bool get isOwner => role == CircleMemberRole.owner;

  /// Display name to show
  String get effectiveDisplayName => displayName ?? 'Member';

  /// Whether the member is currently muted
  bool get isCurrentlyMuted {
    if (!isMuted) return false;
    if (mutedUntil == null) return true;
    return DateTime.now().isBefore(mutedUntil!);
  }

  factory CircleMember.fromFirestore(Map<String, dynamic> data, String odId) {
    return CircleMember(
      userId: data['userId'] as String? ?? '',
      circleId: data['circleId'] as String? ?? '',
      displayName: data['displayName'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      role: CircleMemberRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => CircleMemberRole.member,
      ),
      joinedAt:
          (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeenAt: (data['lastSeenAt'] as Timestamp?)?.toDate(),
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      isMuted: data['isMuted'] as bool? ?? false,
      mutedUntil: (data['mutedUntil'] as Timestamp?)?.toDate(),
      invitedBy: data['invitedBy'] as String?,
      totalCheersGiven: data['totalCheersGiven'] as int? ?? 0,
      totalCheersReceived: data['totalCheersReceived'] as int? ?? 0,
      challengesCompleted: data['challengesCompleted'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate(),
      bio: data['bio'] as String?,
      status: data['status'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'circleId': circleId,
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      if (lastSeenAt != null) 'lastSeenAt': Timestamp.fromDate(lastSeenAt!),
      'notificationsEnabled': notificationsEnabled,
      'isMuted': isMuted,
      if (mutedUntil != null) 'mutedUntil': Timestamp.fromDate(mutedUntil!),
      if (invitedBy != null) 'invitedBy': invitedBy,
      'totalCheersGiven': totalCheersGiven,
      'totalCheersReceived': totalCheersReceived,
      'challengesCompleted': challengesCompleted,
      'currentStreak': currentStreak,
      if (lastActivityAt != null)
        'lastActivityAt': Timestamp.fromDate(lastActivityAt!),
      if (bio != null) 'bio': bio,
      if (status != null) 'status': status,
    };
  }

  CircleMember copyWith({
    String? userId,
    String? circleId,
    String? displayName,
    String? avatarUrl,
    CircleMemberRole? role,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? notificationsEnabled,
    bool? isMuted,
    DateTime? mutedUntil,
    String? invitedBy,
    int? totalCheersGiven,
    int? totalCheersReceived,
    int? challengesCompleted,
    int? currentStreak,
    DateTime? lastActivityAt,
    String? bio,
    String? status,
  }) {
    return CircleMember(
      userId: userId ?? this.userId,
      circleId: circleId ?? this.circleId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      invitedBy: invitedBy ?? this.invitedBy,
      totalCheersGiven: totalCheersGiven ?? this.totalCheersGiven,
      totalCheersReceived: totalCheersReceived ?? this.totalCheersReceived,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      bio: bio ?? this.bio,
      status: status ?? this.status,
    );
  }

  /// Update last seen to now
  CircleMember markSeen() => copyWith(lastSeenAt: DateTime.now());

  /// Promote to admin
  CircleMember promoteToAdmin() => copyWith(role: CircleMemberRole.admin);

  /// Demote to member
  CircleMember demoteToMember() => copyWith(role: CircleMemberRole.member);

  /// Mute the member
  CircleMember mute({Duration? duration}) {
    return copyWith(
      isMuted: true,
      mutedUntil: duration != null ? DateTime.now().add(duration) : null,
    );
  }

  /// Unmute the member
  CircleMember unmute() => copyWith(isMuted: false, mutedUntil: null);

  /// Increment cheers given
  CircleMember giveCheer() =>
      copyWith(totalCheersGiven: totalCheersGiven + 1);

  /// Increment cheers received
  CircleMember receiveCheer() =>
      copyWith(totalCheersReceived: totalCheersReceived + 1);

  /// Complete a challenge
  CircleMember completeChallenge() =>
      copyWith(challengesCompleted: challengesCompleted + 1);

  /// Update activity
  CircleMember updateActivity() => copyWith(lastActivityAt: DateTime.now());
}

/// Represents a pending invite to a Circle
class CircleInvite {
  const CircleInvite({
    required this.id,
    required this.circleId,
    required this.invitedUserId,
    required this.invitedBy,
    required this.createdAt,
    this.expiresAt,
    this.message,
    this.status = CircleInviteStatus.pending,
    this.respondedAt,
  });

  final String id;
  final String circleId;
  final String invitedUserId;
  final String invitedBy;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? message;
  final CircleInviteStatus status;
  final DateTime? respondedAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isPending => status == CircleInviteStatus.pending && !isExpired;

  factory CircleInvite.fromFirestore(Map<String, dynamic> data, String id) {
    return CircleInvite(
      id: id,
      circleId: data['circleId'] as String? ?? '',
      invitedUserId: data['invitedUserId'] as String? ?? '',
      invitedBy: data['invitedBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      message: data['message'] as String?,
      status: CircleInviteStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => CircleInviteStatus.pending,
      ),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'invitedUserId': invitedUserId,
      'invitedBy': invitedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (message != null) 'message': message,
      'status': status.name,
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
    };
  }

  CircleInvite accept() => CircleInvite(
        id: id,
        circleId: circleId,
        invitedUserId: invitedUserId,
        invitedBy: invitedBy,
        createdAt: createdAt,
        expiresAt: expiresAt,
        message: message,
        status: CircleInviteStatus.accepted,
        respondedAt: DateTime.now(),
      );

  CircleInvite decline() => CircleInvite(
        id: id,
        circleId: circleId,
        invitedUserId: invitedUserId,
        invitedBy: invitedBy,
        createdAt: createdAt,
        expiresAt: expiresAt,
        message: message,
        status: CircleInviteStatus.declined,
        respondedAt: DateTime.now(),
      );
}

enum CircleInviteStatus {
  pending,
  accepted,
  declined,
  expired,
}

extension CircleInviteStatusExtension on CircleInviteStatus {
  String get displayName {
    switch (this) {
      case CircleInviteStatus.pending:
        return 'Pending';
      case CircleInviteStatus.accepted:
        return 'Accepted';
      case CircleInviteStatus.declined:
        return 'Declined';
      case CircleInviteStatus.expired:
        return 'Expired';
    }
  }
}
