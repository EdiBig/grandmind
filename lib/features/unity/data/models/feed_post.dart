import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Content for a feed post based on post type
class FeedPostContent {
  const FeedPostContent({
    this.text,
    this.imageUrls = const [],
    this.activityType,
    this.activityValue,
    this.activityUnit,
    this.workoutId,
    this.milestoneId,
    this.milestoneName,
    this.celebrationType,
    this.challengeProgress,
  });

  /// Text content for text posts or captions
  final String? text;

  /// Image URLs attached to the post
  final List<String> imageUrls;

  /// Type of activity (for activity posts)
  final String? activityType;

  /// Value of the activity (e.g., 5000 steps)
  final double? activityValue;

  /// Unit of the activity (e.g., "steps")
  final String? activityUnit;

  /// Reference to workout (for workout posts)
  final String? workoutId;

  /// Reference to milestone (for milestone posts)
  final String? milestoneId;

  /// Name of the milestone
  final String? milestoneName;

  /// Type of celebration
  final String? celebrationType;

  /// Progress percentage at time of post
  final double? challengeProgress;

  factory FeedPostContent.fromFirestore(Map<String, dynamic> data) {
    return FeedPostContent(
      text: data['text'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      activityType: data['activityType'] as String?,
      activityValue: (data['activityValue'] as num?)?.toDouble(),
      activityUnit: data['activityUnit'] as String?,
      workoutId: data['workoutId'] as String?,
      milestoneId: data['milestoneId'] as String?,
      milestoneName: data['milestoneName'] as String?,
      celebrationType: data['celebrationType'] as String?,
      challengeProgress: (data['challengeProgress'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (text != null) 'text': text,
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      if (activityType != null) 'activityType': activityType,
      if (activityValue != null) 'activityValue': activityValue,
      if (activityUnit != null) 'activityUnit': activityUnit,
      if (workoutId != null) 'workoutId': workoutId,
      if (milestoneId != null) 'milestoneId': milestoneId,
      if (milestoneName != null) 'milestoneName': milestoneName,
      if (celebrationType != null) 'celebrationType': celebrationType,
      if (challengeProgress != null) 'challengeProgress': challengeProgress,
    };
  }

  FeedPostContent copyWith({
    String? text,
    List<String>? imageUrls,
    String? activityType,
    double? activityValue,
    String? activityUnit,
    String? workoutId,
    String? milestoneId,
    String? milestoneName,
    String? celebrationType,
    double? challengeProgress,
  }) {
    return FeedPostContent(
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      activityType: activityType ?? this.activityType,
      activityValue: activityValue ?? this.activityValue,
      activityUnit: activityUnit ?? this.activityUnit,
      workoutId: workoutId ?? this.workoutId,
      milestoneId: milestoneId ?? this.milestoneId,
      milestoneName: milestoneName ?? this.milestoneName,
      celebrationType: celebrationType ?? this.celebrationType,
      challengeProgress: challengeProgress ?? this.challengeProgress,
    );
  }

  /// Create content for an activity post
  factory FeedPostContent.activity({
    required String activityType,
    required double value,
    required String unit,
    String? caption,
    String? workoutId,
  }) {
    return FeedPostContent(
      text: caption,
      activityType: activityType,
      activityValue: value,
      activityUnit: unit,
      workoutId: workoutId,
    );
  }

  /// Create content for a milestone post
  factory FeedPostContent.milestone({
    required String milestoneId,
    required String milestoneName,
    String? caption,
    double? progress,
  }) {
    return FeedPostContent(
      text: caption,
      milestoneId: milestoneId,
      milestoneName: milestoneName,
      challengeProgress: progress,
    );
  }

  /// Create content for a text post
  factory FeedPostContent.text(String text, {List<String>? images}) {
    return FeedPostContent(
      text: text,
      imageUrls: images ?? [],
    );
  }
}

/// Represents a post in a Circle or Challenge feed
class FeedPost {
  const FeedPost({
    required this.id,
    this.circleId,
    this.challengeId,
    required this.authorId,
    this.authorName,
    this.authorAvatarUrl,
    this.isAnonymous = false,
    required this.type,
    required this.content,
    this.cheers = const {},
    this.totalCheers = 0,
    this.commentCount = 0,
    this.isHidden = false,
    this.isFlagged = false,
    this.flagReason,
    this.createdAt,
    this.updatedAt,
    this.isPinned = false,
  });

  final String id;
  final String? circleId;
  final String? challengeId;
  final String authorId;
  final String? authorName;
  final String? authorAvatarUrl;
  final bool isAnonymous;
  final FeedPostType type;
  final FeedPostContent content;

  /// Map of cheer type to count
  final Map<String, int> cheers;
  final int totalCheers;
  final int commentCount;
  final bool isHidden;
  final bool isFlagged;
  final String? flagReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPinned;

  /// Display name (anonymous if enabled)
  String get displayAuthorName {
    if (isAnonymous) return 'Anonymous';
    return authorName ?? 'User';
  }

  /// Whether the post has any content
  bool get hasContent =>
      content.text != null ||
      content.imageUrls.isNotEmpty ||
      content.activityType != null;

  factory FeedPost.fromFirestore(Map<String, dynamic> data, String id) {
    // Parse cheers map
    final cheersData = data['cheers'] as Map<String, dynamic>? ?? {};
    final cheersMap = cheersData.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return FeedPost(
      id: id,
      circleId: data['circleId'] as String?,
      challengeId: data['challengeId'] as String?,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String?,
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      type: FeedPostType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => FeedPostType.text,
      ),
      content: FeedPostContent.fromFirestore(
        data['content'] as Map<String, dynamic>? ?? {},
      ),
      cheers: cheersMap,
      totalCheers: data['totalCheers'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      isHidden: data['isHidden'] as bool? ?? false,
      isFlagged: data['isFlagged'] as bool? ?? false,
      flagReason: data['flagReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isPinned: data['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (circleId != null) 'circleId': circleId,
      if (challengeId != null) 'challengeId': challengeId,
      'authorId': authorId,
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      'isAnonymous': isAnonymous,
      'type': type.name,
      'content': content.toFirestore(),
      'cheers': cheers,
      'totalCheers': totalCheers,
      'commentCount': commentCount,
      'isHidden': isHidden,
      'isFlagged': isFlagged,
      if (flagReason != null) 'flagReason': flagReason,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isPinned': isPinned,
    };
  }

  FeedPost copyWith({
    String? id,
    String? circleId,
    String? challengeId,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    bool? isAnonymous,
    FeedPostType? type,
    FeedPostContent? content,
    Map<String, int>? cheers,
    int? totalCheers,
    int? commentCount,
    bool? isHidden,
    bool? isFlagged,
    String? flagReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return FeedPost(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      challengeId: challengeId ?? this.challengeId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      type: type ?? this.type,
      content: content ?? this.content,
      cheers: cheers ?? this.cheers,
      totalCheers: totalCheers ?? this.totalCheers,
      commentCount: commentCount ?? this.commentCount,
      isHidden: isHidden ?? this.isHidden,
      isFlagged: isFlagged ?? this.isFlagged,
      flagReason: flagReason ?? this.flagReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Add a cheer to the post
  FeedPost addCheer(CheerType cheerType) {
    final newCheers = Map<String, int>.from(cheers);
    newCheers[cheerType.name] = (newCheers[cheerType.name] ?? 0) + 1;
    return copyWith(
      cheers: newCheers,
      totalCheers: totalCheers + 1,
    );
  }

  /// Remove a cheer from the post
  FeedPost removeCheer(CheerType cheerType) {
    final newCheers = Map<String, int>.from(cheers);
    final current = newCheers[cheerType.name] ?? 0;
    if (current > 0) {
      newCheers[cheerType.name] = current - 1;
      return copyWith(
        cheers: newCheers,
        totalCheers: totalCheers > 0 ? totalCheers - 1 : 0,
      );
    }
    return this;
  }

  /// Get count for a specific cheer type
  int getCheerCount(CheerType cheerType) => cheers[cheerType.name] ?? 0;

  /// Flag the post
  FeedPost flag(String reason) {
    return copyWith(isFlagged: true, flagReason: reason);
  }

  /// Hide the post
  FeedPost hide() => copyWith(isHidden: true);

  /// Unhide the post
  FeedPost unhide() => copyWith(isHidden: false);

  /// Pin the post
  FeedPost pin() => copyWith(isPinned: true);

  /// Unpin the post
  FeedPost unpin() => copyWith(isPinned: false);
}

/// Represents a comment on a feed post
class FeedComment {
  const FeedComment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.authorName,
    this.authorAvatarUrl,
    this.isAnonymous = false,
    required this.text,
    this.createdAt,
    this.isHidden = false,
    this.isFlagged = false,
  });

  final String id;
  final String postId;
  final String authorId;
  final String? authorName;
  final String? authorAvatarUrl;
  final bool isAnonymous;
  final String text;
  final DateTime? createdAt;
  final bool isHidden;
  final bool isFlagged;

  String get displayAuthorName {
    if (isAnonymous) return 'Anonymous';
    return authorName ?? 'User';
  }

  factory FeedComment.fromFirestore(Map<String, dynamic> data, String id) {
    return FeedComment(
      id: id,
      postId: data['postId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String?,
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isHidden: data['isHidden'] as bool? ?? false,
      isFlagged: data['isFlagged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      'isAnonymous': isAnonymous,
      'text': text,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isHidden': isHidden,
      'isFlagged': isFlagged,
    };
  }
}
