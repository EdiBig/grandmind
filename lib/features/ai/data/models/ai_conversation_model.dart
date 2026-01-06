import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_conversation_model.freezed.dart';
part 'ai_conversation_model.g.dart';

/// Represents a single message in an AI conversation
@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required String role, // 'user' or 'assistant'
    required String content,
    required DateTime timestamp,
    bool? fromCache,
    int? inputTokens,
    int? outputTokens,
    double? cost,
    Map<String, dynamic>? metadata,
  }) = _AIMessage;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}

extension AIMessageExtensions on AIMessage {
  /// Check if this is a user message
  bool get isUser => role == 'user';

  /// Check if this is an assistant message
  bool get isAssistant => role == 'assistant';

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (fromCache != null) 'fromCache': fromCache,
      if (inputTokens != null) 'inputTokens': inputTokens,
      if (outputTokens != null) 'outputTokens': outputTokens,
      if (cost != null) 'cost': cost,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from Firestore document
  static AIMessage fromFirestore(Map<String, dynamic> doc) {
    return AIMessage(
      id: doc['id'] as String,
      role: doc['role'] as String,
      content: doc['content'] as String,
      timestamp: DateTime.parse(doc['timestamp'] as String),
      fromCache: doc['fromCache'] as bool?,
      inputTokens: doc['inputTokens'] as int?,
      outputTokens: doc['outputTokens'] as int?,
      cost: (doc['cost'] as num?)?.toDouble(),
      metadata: doc['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Represents a complete AI conversation
@freezed
class AIConversation with _$AIConversation {
  const factory AIConversation({
    required String id,
    required String userId,
    required String conversationType, // 'fitness_coach', 'nutrition', 'recovery'
    required List<AIMessage> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? title,
    bool? isPinned,
    Map<String, dynamic>? metadata,
  }) = _AIConversation;

  factory AIConversation.fromJson(Map<String, dynamic> json) =>
      _$AIConversationFromJson(json);
}

extension AIConversationExtensions on AIConversation {
  /// Get the last message in the conversation
  AIMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get total number of messages
  int get messageCount => messages.length;

  /// Get total cost of conversation
  double get totalCost {
    return messages
        .where((m) => m.cost != null)
        .fold(0.0, (sum, m) => sum + m.cost!);
  }

  /// Get total tokens used
  int get totalTokens {
    final inputTotal = messages
        .where((m) => m.inputTokens != null)
        .fold(0, (sum, m) => sum + m.inputTokens!);
    final outputTotal = messages
        .where((m) => m.outputTokens != null)
        .fold(0, (sum, m) => sum + m.outputTokens!);
    return inputTotal + outputTotal;
  }

  /// Check if conversation is empty
  bool get isEmpty => messages.isEmpty;

  /// Check if conversation has messages
  bool get isNotEmpty => messages.isNotEmpty;

  /// Get a preview of the conversation (first user message or first 100 chars)
  String get preview {
    if (title != null && title!.isNotEmpty) return title!;

    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );

    if (firstUserMessage.content.length <= 100) {
      return firstUserMessage.content;
    }
    return '${firstUserMessage.content.substring(0, 100)}...';
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'conversationType': conversationType,
      'messages': messages.map((m) => m.toFirestore()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (title != null) 'title': title,
      if (isPinned != null) 'isPinned': isPinned,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from Firestore document
  static AIConversation fromFirestore(Map<String, dynamic> doc) {
    return AIConversation(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      conversationType: doc['conversationType'] as String,
      messages: (doc['messages'] as List)
          .map((m) => AIMessageExtensions.fromFirestore(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(doc['createdAt'] as String),
      updatedAt: DateTime.parse(doc['updatedAt'] as String),
      title: doc['title'] as String?,
      isPinned: doc['isPinned'] as bool?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Quick action suggestion for the AI coach
@freezed
class QuickAction with _$QuickAction {
  const factory QuickAction({
    required String id,
    required String label,
    required String prompt,
    required String icon, // Icon name or emoji
    String? description,
  }) = _QuickAction;

  factory QuickAction.fromJson(Map<String, dynamic> json) =>
      _$QuickActionFromJson(json);
}

/// Predefined quick actions
class QuickActions {
  static const List<QuickAction> fitnessCoach = [
    QuickAction(
      id: 'recommend_workout',
      label: 'Recommend Workout',
      prompt: 'What workout should I do today?',
      icon: '💪',
      description: 'Get a personalized workout recommendation',
    ),
    QuickAction(
      id: 'form_check',
      label: 'Form Check',
      prompt: 'Can you give me form guidance for squats?',
      icon: '✓',
      description: 'Learn proper exercise form',
    ),
    QuickAction(
      id: 'progress_review',
      label: 'Progress Review',
      prompt: 'How am I progressing towards my goals?',
      icon: '📈',
      description: 'Review your fitness progress',
    ),
    QuickAction(
      id: 'rest_day',
      label: 'Rest Day?',
      prompt: 'Should I take a rest day today?',
      icon: '😴',
      description: 'Check if you need recovery',
    ),
  ];
}
