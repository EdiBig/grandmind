// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) {
  return _AIMessage.fromJson(json);
}

/// @nodoc
mixin _$AIMessage {
  String get id => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'user' or 'assistant'
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool? get fromCache => throw _privateConstructorUsedError;
  int? get inputTokens => throw _privateConstructorUsedError;
  int? get outputTokens => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIMessageCopyWith<AIMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIMessageCopyWith<$Res> {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) then) =
      _$AIMessageCopyWithImpl<$Res, AIMessage>;
  @useResult
  $Res call(
      {String id,
      String role,
      String content,
      DateTime timestamp,
      bool? fromCache,
      int? inputTokens,
      int? outputTokens,
      double? cost,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AIMessageCopyWithImpl<$Res, $Val extends AIMessage>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
    Object? fromCache = freezed,
    Object? inputTokens = freezed,
    Object? outputTokens = freezed,
    Object? cost = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromCache: freezed == fromCache
          ? _value.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool?,
      inputTokens: freezed == inputTokens
          ? _value.inputTokens
          : inputTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      outputTokens: freezed == outputTokens
          ? _value.outputTokens
          : outputTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIMessageImplCopyWith<$Res>
    implements $AIMessageCopyWith<$Res> {
  factory _$$AIMessageImplCopyWith(
          _$AIMessageImpl value, $Res Function(_$AIMessageImpl) then) =
      __$$AIMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String role,
      String content,
      DateTime timestamp,
      bool? fromCache,
      int? inputTokens,
      int? outputTokens,
      double? cost,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AIMessageImplCopyWithImpl<$Res>
    extends _$AIMessageCopyWithImpl<$Res, _$AIMessageImpl>
    implements _$$AIMessageImplCopyWith<$Res> {
  __$$AIMessageImplCopyWithImpl(
      _$AIMessageImpl _value, $Res Function(_$AIMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? content = null,
    Object? timestamp = null,
    Object? fromCache = freezed,
    Object? inputTokens = freezed,
    Object? outputTokens = freezed,
    Object? cost = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AIMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fromCache: freezed == fromCache
          ? _value.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool?,
      inputTokens: freezed == inputTokens
          ? _value.inputTokens
          : inputTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      outputTokens: freezed == outputTokens
          ? _value.outputTokens
          : outputTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIMessageImpl implements _AIMessage {
  const _$AIMessageImpl(
      {required this.id,
      required this.role,
      required this.content,
      required this.timestamp,
      this.fromCache,
      this.inputTokens,
      this.outputTokens,
      this.cost,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$AIMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String role;
// 'user' or 'assistant'
  @override
  final String content;
  @override
  final DateTime timestamp;
  @override
  final bool? fromCache;
  @override
  final int? inputTokens;
  @override
  final int? outputTokens;
  @override
  final double? cost;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AIMessage(id: $id, role: $role, content: $content, timestamp: $timestamp, fromCache: $fromCache, inputTokens: $inputTokens, outputTokens: $outputTokens, cost: $cost, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache) &&
            (identical(other.inputTokens, inputTokens) ||
                other.inputTokens == inputTokens) &&
            (identical(other.outputTokens, outputTokens) ||
                other.outputTokens == outputTokens) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      role,
      content,
      timestamp,
      fromCache,
      inputTokens,
      outputTokens,
      cost,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      __$$AIMessageImplCopyWithImpl<_$AIMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIMessageImplToJson(
      this,
    );
  }
}

abstract class _AIMessage implements AIMessage {
  const factory _AIMessage(
      {required final String id,
      required final String role,
      required final String content,
      required final DateTime timestamp,
      final bool? fromCache,
      final int? inputTokens,
      final int? outputTokens,
      final double? cost,
      final Map<String, dynamic>? metadata}) = _$AIMessageImpl;

  factory _AIMessage.fromJson(Map<String, dynamic> json) =
      _$AIMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get role; // 'user' or 'assistant'
  @override
  String get content;
  @override
  DateTime get timestamp;
  @override
  bool? get fromCache;
  @override
  int? get inputTokens;
  @override
  int? get outputTokens;
  @override
  double? get cost;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIConversation _$AIConversationFromJson(Map<String, dynamic> json) {
  return _AIConversation.fromJson(json);
}

/// @nodoc
mixin _$AIConversation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get conversationType =>
      throw _privateConstructorUsedError; // 'fitness_coach', 'nutrition', 'recovery'
  List<AIMessage> get messages => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  bool? get isPinned => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AIConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConversationCopyWith<AIConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConversationCopyWith<$Res> {
  factory $AIConversationCopyWith(
          AIConversation value, $Res Function(AIConversation) then) =
      _$AIConversationCopyWithImpl<$Res, AIConversation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String conversationType,
      List<AIMessage> messages,
      DateTime createdAt,
      DateTime updatedAt,
      String? title,
      bool? isPinned,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AIConversationCopyWithImpl<$Res, $Val extends AIConversation>
    implements $AIConversationCopyWith<$Res> {
  _$AIConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? conversationType = null,
    Object? messages = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = freezed,
    Object? isPinned = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationType: null == conversationType
          ? _value.conversationType
          : conversationType // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIMessage>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: freezed == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIConversationImplCopyWith<$Res>
    implements $AIConversationCopyWith<$Res> {
  factory _$$AIConversationImplCopyWith(_$AIConversationImpl value,
          $Res Function(_$AIConversationImpl) then) =
      __$$AIConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String conversationType,
      List<AIMessage> messages,
      DateTime createdAt,
      DateTime updatedAt,
      String? title,
      bool? isPinned,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AIConversationImplCopyWithImpl<$Res>
    extends _$AIConversationCopyWithImpl<$Res, _$AIConversationImpl>
    implements _$$AIConversationImplCopyWith<$Res> {
  __$$AIConversationImplCopyWithImpl(
      _$AIConversationImpl _value, $Res Function(_$AIConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? conversationType = null,
    Object? messages = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? title = freezed,
    Object? isPinned = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AIConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationType: null == conversationType
          ? _value.conversationType
          : conversationType // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIMessage>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: freezed == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConversationImpl implements _AIConversation {
  const _$AIConversationImpl(
      {required this.id,
      required this.userId,
      required this.conversationType,
      required final List<AIMessage> messages,
      required this.createdAt,
      required this.updatedAt,
      this.title,
      this.isPinned,
      final Map<String, dynamic>? metadata})
      : _messages = messages,
        _metadata = metadata;

  factory _$AIConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String conversationType;
// 'fitness_coach', 'nutrition', 'recovery'
  final List<AIMessage> _messages;
// 'fitness_coach', 'nutrition', 'recovery'
  @override
  List<AIMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? title;
  @override
  final bool? isPinned;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AIConversation(id: $id, userId: $userId, conversationType: $conversationType, messages: $messages, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, isPinned: $isPinned, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.conversationType, conversationType) ||
                other.conversationType == conversationType) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      conversationType,
      const DeepCollectionEquality().hash(_messages),
      createdAt,
      updatedAt,
      title,
      isPinned,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      __$$AIConversationImplCopyWithImpl<_$AIConversationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConversationImplToJson(
      this,
    );
  }
}

abstract class _AIConversation implements AIConversation {
  const factory _AIConversation(
      {required final String id,
      required final String userId,
      required final String conversationType,
      required final List<AIMessage> messages,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? title,
      final bool? isPinned,
      final Map<String, dynamic>? metadata}) = _$AIConversationImpl;

  factory _AIConversation.fromJson(Map<String, dynamic> json) =
      _$AIConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get conversationType; // 'fitness_coach', 'nutrition', 'recovery'
  @override
  List<AIMessage> get messages;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get title;
  @override
  bool? get isPinned;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuickAction _$QuickActionFromJson(Map<String, dynamic> json) {
  return _QuickAction.fromJson(json);
}

/// @nodoc
mixin _$QuickAction {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get prompt => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError; // Icon name or emoji
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this QuickAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuickAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuickActionCopyWith<QuickAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuickActionCopyWith<$Res> {
  factory $QuickActionCopyWith(
          QuickAction value, $Res Function(QuickAction) then) =
      _$QuickActionCopyWithImpl<$Res, QuickAction>;
  @useResult
  $Res call(
      {String id,
      String label,
      String prompt,
      String icon,
      String? description});
}

/// @nodoc
class _$QuickActionCopyWithImpl<$Res, $Val extends QuickAction>
    implements $QuickActionCopyWith<$Res> {
  _$QuickActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuickAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? prompt = null,
    Object? icon = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuickActionImplCopyWith<$Res>
    implements $QuickActionCopyWith<$Res> {
  factory _$$QuickActionImplCopyWith(
          _$QuickActionImpl value, $Res Function(_$QuickActionImpl) then) =
      __$$QuickActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String prompt,
      String icon,
      String? description});
}

/// @nodoc
class __$$QuickActionImplCopyWithImpl<$Res>
    extends _$QuickActionCopyWithImpl<$Res, _$QuickActionImpl>
    implements _$$QuickActionImplCopyWith<$Res> {
  __$$QuickActionImplCopyWithImpl(
      _$QuickActionImpl _value, $Res Function(_$QuickActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuickAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? prompt = null,
    Object? icon = null,
    Object? description = freezed,
  }) {
    return _then(_$QuickActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuickActionImpl implements _QuickAction {
  const _$QuickActionImpl(
      {required this.id,
      required this.label,
      required this.prompt,
      required this.icon,
      this.description});

  factory _$QuickActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuickActionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String prompt;
  @override
  final String icon;
// Icon name or emoji
  @override
  final String? description;

  @override
  String toString() {
    return 'QuickAction(id: $id, label: $label, prompt: $prompt, icon: $icon, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuickActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, prompt, icon, description);

  /// Create a copy of QuickAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuickActionImplCopyWith<_$QuickActionImpl> get copyWith =>
      __$$QuickActionImplCopyWithImpl<_$QuickActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuickActionImplToJson(
      this,
    );
  }
}

abstract class _QuickAction implements QuickAction {
  const factory _QuickAction(
      {required final String id,
      required final String label,
      required final String prompt,
      required final String icon,
      final String? description}) = _$QuickActionImpl;

  factory _QuickAction.fromJson(Map<String, dynamic> json) =
      _$QuickActionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get prompt;
  @override
  String get icon; // Icon name or emoji
  @override
  String? get description;

  /// Create a copy of QuickAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuickActionImplCopyWith<_$QuickActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
