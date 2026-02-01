import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Circle settings configuration
class CircleSettings {
  const CircleSettings({
    this.allowMemberInvites = true,
    this.requireApprovalToJoin = false,
    this.showMemberActivity = true,
    this.allowChallengeCreation = true,
    this.defaultChallengeVisibility = PrivacyLevel.circle,
    this.enableCheers = true,
    this.enableActivityFeed = true,
    this.mutedUntil,
  });

  final bool allowMemberInvites;
  final bool requireApprovalToJoin;
  final bool showMemberActivity;
  final bool allowChallengeCreation;
  final PrivacyLevel defaultChallengeVisibility;
  final bool enableCheers;
  final bool enableActivityFeed;
  final DateTime? mutedUntil;

  factory CircleSettings.fromFirestore(Map<String, dynamic> data) {
    return CircleSettings(
      allowMemberInvites: data['allowMemberInvites'] as bool? ?? true,
      requireApprovalToJoin: data['requireApprovalToJoin'] as bool? ?? false,
      showMemberActivity: data['showMemberActivity'] as bool? ?? true,
      allowChallengeCreation: data['allowChallengeCreation'] as bool? ?? true,
      defaultChallengeVisibility: PrivacyLevel.values.firstWhere(
        (p) => p.name == data['defaultChallengeVisibility'],
        orElse: () => PrivacyLevel.circle,
      ),
      enableCheers: data['enableCheers'] as bool? ?? true,
      enableActivityFeed: data['enableActivityFeed'] as bool? ?? true,
      mutedUntil: (data['mutedUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'allowMemberInvites': allowMemberInvites,
      'requireApprovalToJoin': requireApprovalToJoin,
      'showMemberActivity': showMemberActivity,
      'allowChallengeCreation': allowChallengeCreation,
      'defaultChallengeVisibility': defaultChallengeVisibility.name,
      'enableCheers': enableCheers,
      'enableActivityFeed': enableActivityFeed,
      if (mutedUntil != null) 'mutedUntil': Timestamp.fromDate(mutedUntil!),
    };
  }

  CircleSettings copyWith({
    bool? allowMemberInvites,
    bool? requireApprovalToJoin,
    bool? showMemberActivity,
    bool? allowChallengeCreation,
    PrivacyLevel? defaultChallengeVisibility,
    bool? enableCheers,
    bool? enableActivityFeed,
    DateTime? mutedUntil,
  }) {
    return CircleSettings(
      allowMemberInvites: allowMemberInvites ?? this.allowMemberInvites,
      requireApprovalToJoin:
          requireApprovalToJoin ?? this.requireApprovalToJoin,
      showMemberActivity: showMemberActivity ?? this.showMemberActivity,
      allowChallengeCreation:
          allowChallengeCreation ?? this.allowChallengeCreation,
      defaultChallengeVisibility:
          defaultChallengeVisibility ?? this.defaultChallengeVisibility,
      enableCheers: enableCheers ?? this.enableCheers,
      enableActivityFeed: enableActivityFeed ?? this.enableActivityFeed,
      mutedUntil: mutedUntil ?? this.mutedUntil,
    );
  }
}

/// Represents a Circle (micro-community) in Unity
class Circle {
  const Circle({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.coverImageUrl,
    required this.type,
    this.visibility = CircleVisibility.private,
    this.maxMembers,
    this.theme,
    this.memberCount = 0,
    required this.createdBy,
    this.admins = const [],
    this.lastActivityAt,
    this.totalChallengesCompleted = 0,
    this.activeChallengeCount = 0,
    this.settings = const CircleSettings(),
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.inviteCode,
    this.isArchived = false,
    this.memberIds = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? coverImageUrl;
  final CircleType type;
  final CircleVisibility visibility;
  final int? maxMembers;
  final String? theme;
  final int memberCount;
  final String createdBy;
  final List<String> admins;
  final DateTime? lastActivityAt;
  final int totalChallengesCompleted;
  final int activeChallengeCount;
  final CircleSettings settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final String? inviteCode;
  final bool isArchived;
  final List<String> memberIds;

  /// Whether the circle is full
  bool get isFull {
    if (maxMembers == null) return false;
    return memberCount >= maxMembers!;
  }

  /// Whether the circle can accept new members
  bool get canAcceptMembers => !isFull && !isArchived;

  /// Effective max members based on type
  int get effectiveMaxMembers => maxMembers ?? type.maxMembers;

  /// Whether someone can join directly or needs invite/approval
  bool get requiresInvite =>
      visibility == CircleVisibility.private ||
      visibility == CircleVisibility.inviteOnly;

  factory Circle.fromFirestore(Map<String, dynamic> data, String id) {
    return Circle(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      type: CircleType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => CircleType.squad,
      ),
      visibility: CircleVisibility.values.firstWhere(
        (v) => v.name == data['visibility'],
        orElse: () => CircleVisibility.private,
      ),
      maxMembers: data['maxMembers'] as int?,
      theme: data['theme'] as String?,
      memberCount: data['memberCount'] as int? ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      admins: (data['admins'] as List<dynamic>?)?.cast<String>() ?? [],
      lastActivityAt: (data['lastActivityAt'] as Timestamp?)?.toDate(),
      totalChallengesCompleted: data['totalChallengesCompleted'] as int? ?? 0,
      activeChallengeCount: data['activeChallengeCount'] as int? ?? 0,
      settings: CircleSettings.fromFirestore(
        data['settings'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      inviteCode: data['inviteCode'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      memberIds: (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'type': type.name,
      'visibility': visibility.name,
      if (maxMembers != null) 'maxMembers': maxMembers,
      if (theme != null) 'theme': theme,
      'memberCount': memberCount,
      'createdBy': createdBy,
      'admins': admins,
      if (lastActivityAt != null)
        'lastActivityAt': Timestamp.fromDate(lastActivityAt!),
      'totalChallengesCompleted': totalChallengesCompleted,
      'activeChallengeCount': activeChallengeCount,
      'settings': settings.toFirestore(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tags': tags,
      if (inviteCode != null) 'inviteCode': inviteCode,
      'isArchived': isArchived,
      'memberIds': memberIds,
    };
  }

  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? coverImageUrl,
    CircleType? type,
    CircleVisibility? visibility,
    int? maxMembers,
    String? theme,
    int? memberCount,
    String? createdBy,
    List<String>? admins,
    DateTime? lastActivityAt,
    int? totalChallengesCompleted,
    int? activeChallengeCount,
    CircleSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? inviteCode,
    bool? isArchived,
    List<String>? memberIds,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      maxMembers: maxMembers ?? this.maxMembers,
      theme: theme ?? this.theme,
      memberCount: memberCount ?? this.memberCount,
      createdBy: createdBy ?? this.createdBy,
      admins: admins ?? this.admins,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalChallengesCompleted:
          totalChallengesCompleted ?? this.totalChallengesCompleted,
      activeChallengeCount: activeChallengeCount ?? this.activeChallengeCount,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      inviteCode: inviteCode ?? this.inviteCode,
      isArchived: isArchived ?? this.isArchived,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  /// Add an admin to the circle
  Circle addAdmin(String userId) {
    if (admins.contains(userId)) return this;
    return copyWith(admins: [...admins, userId]);
  }

  /// Remove an admin from the circle
  Circle removeAdmin(String userId) {
    if (userId == createdBy) return this; // Can't remove owner
    return copyWith(admins: admins.where((id) => id != userId).toList());
  }

  /// Check if a user is an admin
  bool isAdmin(String userId) {
    return admins.contains(userId) || userId == createdBy;
  }

  /// Check if a user is the owner
  bool isOwner(String userId) => userId == createdBy;

  /// Increment member count
  Circle incrementMembers() => copyWith(memberCount: memberCount + 1);

  /// Decrement member count
  Circle decrementMembers() =>
      copyWith(memberCount: memberCount > 0 ? memberCount - 1 : 0);

  /// Update last activity timestamp
  Circle touch() => copyWith(lastActivityAt: DateTime.now());
}
