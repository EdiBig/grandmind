import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/ai_conversation_model.dart';

/// Repository for persisting AI conversations to Firestore
class AIConversationRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  static const String _conversationsCollection = 'ai_conversations';

  AIConversationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save or update a conversation
  Future<void> saveConversation(AIConversation conversation) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversation.id)
          .set(conversation.toFirestore());
      _logger.d('Saved conversation: ${conversation.id}');
    } catch (e, stackTrace) {
      _logger.e('Error saving conversation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a specific conversation by ID
  Future<AIConversation?> getConversation(String conversationId) async {
    try {
      final doc = await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AIConversationExtensions.fromFirestore(doc.data()!);
    } catch (e, stackTrace) {
      _logger.e('Error getting conversation', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get the most recent conversation of a specific type for a user
  Future<AIConversation?> getLatestConversation({
    required String userId,
    required String conversationType,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_conversationsCollection)
          .where('userId', isEqualTo: userId)
          .where('conversationType', isEqualTo: conversationType)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return AIConversationExtensions.fromFirestore(snapshot.docs.first.data());
    } catch (e, stackTrace) {
      _logger.e('Error getting latest conversation', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get all conversations of a specific type for a user
  Stream<List<AIConversation>> getUserConversationsStream({
    required String userId,
    required String conversationType,
    int limit = 20,
  }) {
    return _firestore
        .collection(_conversationsCollection)
        .where('userId', isEqualTo: userId)
        .where('conversationType', isEqualTo: conversationType)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AIConversationExtensions.fromFirestore(doc.data()))
            .toList());
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .delete();
      _logger.d('Deleted conversation: $conversationId');
    } catch (e, stackTrace) {
      _logger.e('Error deleting conversation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete all conversations of a specific type for a user
  Future<void> deleteUserConversations({
    required String userId,
    required String conversationType,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_conversationsCollection)
          .where('userId', isEqualTo: userId)
          .where('conversationType', isEqualTo: conversationType)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _logger.d('Deleted ${snapshot.docs.length} conversations for user: $userId');
    } catch (e, stackTrace) {
      _logger.e('Error deleting user conversations', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update conversation title
  Future<void> updateTitle(String conversationId, String title) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({
        'title': title,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating conversation title', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Toggle pinned status
  Future<void> togglePinned(String conversationId, bool isPinned) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({
        'isPinned': isPinned,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error toggling conversation pinned status', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Provider for AI Conversation Repository
final aiConversationRepositoryProvider = Provider<AIConversationRepository>((ref) {
  return AIConversationRepository();
});
