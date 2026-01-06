// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIMessageImpl _$$AIMessageImplFromJson(Map<String, dynamic> json) =>
    _$AIMessageImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fromCache: json['fromCache'] as bool?,
      inputTokens: (json['inputTokens'] as num?)?.toInt(),
      outputTokens: (json['outputTokens'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AIMessageImplToJson(_$AIMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'fromCache': instance.fromCache,
      'inputTokens': instance.inputTokens,
      'outputTokens': instance.outputTokens,
      'cost': instance.cost,
      'metadata': instance.metadata,
    };

_$AIConversationImpl _$$AIConversationImplFromJson(Map<String, dynamic> json) =>
    _$AIConversationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      conversationType: json['conversationType'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => AIMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String?,
      isPinned: json['isPinned'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AIConversationImplToJson(
        _$AIConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'conversationType': instance.conversationType,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'isPinned': instance.isPinned,
      'metadata': instance.metadata,
    };

_$QuickActionImpl _$$QuickActionImplFromJson(Map<String, dynamic> json) =>
    _$QuickActionImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      prompt: json['prompt'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$QuickActionImplToJson(_$QuickActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'prompt': instance.prompt,
      'icon': instance.icon,
      'description': instance.description,
    };
