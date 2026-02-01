import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Feed Post operations
class FeedRepository {
  FeedRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('circle_feed_posts');

  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('feed_comments');

  /// Stream of circle feed posts
  Stream<List<FeedPost>> getCircleFeedStream(
    String circleId, {
    int limit = 20,
  }) {
    return _posts
        .where('circleId', isEqualTo: circleId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of challenge feed posts
  Stream<List<FeedPost>> getChallengeFeedStream(
    String challengeId, {
    int limit = 20,
  }) {
    return _posts
        .where('challengeId', isEqualTo: challengeId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get a single post
  Future<FeedPost?> getPost(String postId) async {
    final doc = await _posts.doc(postId).get();
    if (!doc.exists) return null;
    return FeedPost.fromFirestore(doc.data()!, doc.id);
  }

  /// Stream a single post
  Stream<FeedPost?> getPostStream(String postId) {
    return _posts.doc(postId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FeedPost.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Create a new post
  Future<String> createPost(FeedPost post) async {
    final docRef = await _posts.add(post.toFirestore());
    return docRef.id;
  }

  /// Update a post
  Future<void> updatePost(FeedPost post) async {
    await _posts.doc(post.id).update(post.toFirestore());
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    // Delete comments first
    final comments = await _comments.where('postId', isEqualTo: postId).get();
    final batch = _firestore.batch();

    for (final comment in comments.docs) {
      batch.delete(comment.reference);
    }

    batch.delete(_posts.doc(postId));
    await batch.commit();
  }

  /// Hide a post (soft delete)
  Future<void> hidePost(String postId) async {
    await _posts.doc(postId).update({
      'isHidden': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unhide a post
  Future<void> unhidePost(String postId) async {
    await _posts.doc(postId).update({
      'isHidden': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Flag a post for moderation
  Future<void> flagPost(String postId, String reason) async {
    await _posts.doc(postId).update({
      'isFlagged': true,
      'flagReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pin a post
  Future<void> pinPost(String postId) async {
    await _posts.doc(postId).update({
      'isPinned': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unpin a post
  Future<void> unpinPost(String postId) async {
    await _posts.doc(postId).update({
      'isPinned': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a cheer to a post
  Future<void> addCheerToPost(String postId, CheerType cheerType) async {
    await _posts.doc(postId).update({
      'cheers.${cheerType.name}': FieldValue.increment(1),
      'totalCheers': FieldValue.increment(1),
    });
  }

  /// Remove a cheer from a post
  Future<void> removeCheerFromPost(String postId, CheerType cheerType) async {
    await _posts.doc(postId).update({
      'cheers.${cheerType.name}': FieldValue.increment(-1),
      'totalCheers': FieldValue.increment(-1),
    });
  }

  /// Get user's posts
  Stream<List<FeedPost>> getUserPostsStream(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get pinned posts for a circle
  Stream<List<FeedPost>> getPinnedPostsStream(String circleId) {
    return _posts
        .where('circleId', isEqualTo: circleId)
        .where('isPinned', isEqualTo: true)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Comment methods

  /// Get comments for a post
  Stream<List<FeedComment>> getCommentsStream(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedComment.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Add a comment
  Future<String> addComment(FeedComment comment) async {
    final batch = _firestore.batch();

    // Add comment
    final commentRef = _comments.doc();
    batch.set(commentRef, comment.toFirestore());

    // Increment comment count on post
    batch.update(_posts.doc(comment.postId), {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
    return commentRef.id;
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    final batch = _firestore.batch();

    batch.delete(_comments.doc(commentId));

    batch.update(_posts.doc(postId), {
      'commentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Hide a comment
  Future<void> hideComment(String commentId) async {
    await _comments.doc(commentId).update({
      'isHidden': true,
    });
  }

  /// Flag a comment
  Future<void> flagComment(String commentId) async {
    await _comments.doc(commentId).update({
      'isFlagged': true,
    });
  }

  /// Create an activity post
  Future<String> createActivityPost({
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    String? circleId,
    String? challengeId,
    required String activityType,
    required double value,
    required String unit,
    String? caption,
    String? workoutId,
    bool isAnonymous = false,
  }) async {
    final post = FeedPost(
      id: '',
      circleId: circleId,
      challengeId: challengeId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAnonymous: isAnonymous,
      type: FeedPostType.activity,
      content: FeedPostContent.activity(
        activityType: activityType,
        value: value,
        unit: unit,
        caption: caption,
        workoutId: workoutId,
      ),
    );

    return createPost(post);
  }

  /// Create a milestone post
  Future<String> createMilestonePost({
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    String? circleId,
    String? challengeId,
    required String milestoneId,
    required String milestoneName,
    double? progress,
    String? caption,
    bool isAnonymous = false,
  }) async {
    final post = FeedPost(
      id: '',
      circleId: circleId,
      challengeId: challengeId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAnonymous: isAnonymous,
      type: FeedPostType.milestone,
      content: FeedPostContent.milestone(
        milestoneId: milestoneId,
        milestoneName: milestoneName,
        caption: caption,
        progress: progress,
      ),
    );

    return createPost(post);
  }

  /// Create a text post
  Future<String> createTextPost({
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    String? circleId,
    String? challengeId,
    required String text,
    List<String>? imageUrls,
    bool isAnonymous = false,
  }) async {
    final post = FeedPost(
      id: '',
      circleId: circleId,
      challengeId: challengeId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAnonymous: isAnonymous,
      type: FeedPostType.text,
      content: FeedPostContent.text(text, images: imageUrls),
    );

    return createPost(post);
  }

  /// Get flagged posts for moderation
  Future<List<FeedPost>> getFlaggedPosts() async {
    final snapshot = await _posts.where('isFlagged', isEqualTo: true).get();
    return snapshot.docs
        .map((doc) => FeedPost.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
