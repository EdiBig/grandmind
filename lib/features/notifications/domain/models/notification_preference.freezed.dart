// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationPreference _$NotificationPreferenceFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreference.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreference {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  ReminderType get type => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<int> get daysOfWeek =>
      throw _privateConstructorUsedError; // 1=Monday, 7=Sunday
  int get hour => throw _privateConstructorUsedError; // 0-23
  int get minute => throw _privateConstructorUsedError; // 0-59
  String? get linkedEntityId =>
      throw _privateConstructorUsedError; // habitId, goalId, etc.
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferenceCopyWith<NotificationPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferenceCopyWith<$Res> {
  factory $NotificationPreferenceCopyWith(NotificationPreference value,
          $Res Function(NotificationPreference) then) =
      _$NotificationPreferenceCopyWithImpl<$Res, NotificationPreference>;
  @useResult
  $Res call(
      {String id,
      String userId,
      ReminderType type,
      bool enabled,
      String title,
      String message,
      List<int> daysOfWeek,
      int hour,
      int minute,
      String? linkedEntityId,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$NotificationPreferenceCopyWithImpl<$Res,
        $Val extends NotificationPreference>
    implements $NotificationPreferenceCopyWith<$Res> {
  _$NotificationPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? title = null,
    Object? message = null,
    Object? daysOfWeek = null,
    Object? hour = null,
    Object? minute = null,
    Object? linkedEntityId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      linkedEntityId: freezed == linkedEntityId
          ? _value.linkedEntityId
          : linkedEntityId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferenceImplCopyWith<$Res>
    implements $NotificationPreferenceCopyWith<$Res> {
  factory _$$NotificationPreferenceImplCopyWith(
          _$NotificationPreferenceImpl value,
          $Res Function(_$NotificationPreferenceImpl) then) =
      __$$NotificationPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      ReminderType type,
      bool enabled,
      String title,
      String message,
      List<int> daysOfWeek,
      int hour,
      int minute,
      String? linkedEntityId,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$NotificationPreferenceImplCopyWithImpl<$Res>
    extends _$NotificationPreferenceCopyWithImpl<$Res,
        _$NotificationPreferenceImpl>
    implements _$$NotificationPreferenceImplCopyWith<$Res> {
  __$$NotificationPreferenceImplCopyWithImpl(
      _$NotificationPreferenceImpl _value,
      $Res Function(_$NotificationPreferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? title = null,
    Object? message = null,
    Object? daysOfWeek = null,
    Object? hour = null,
    Object? minute = null,
    Object? linkedEntityId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$NotificationPreferenceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      linkedEntityId: freezed == linkedEntityId
          ? _value.linkedEntityId
          : linkedEntityId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferenceImpl extends _NotificationPreference {
  const _$NotificationPreferenceImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.enabled,
      required this.title,
      required this.message,
      required final List<int> daysOfWeek,
      required this.hour,
      required this.minute,
      this.linkedEntityId,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _daysOfWeek = daysOfWeek,
        super._();

  factory _$NotificationPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPreferenceImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final ReminderType type;
  @override
  final bool enabled;
  @override
  final String title;
  @override
  final String message;
  final List<int> _daysOfWeek;
  @override
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

// 1=Monday, 7=Sunday
  @override
  final int hour;
// 0-23
  @override
  final int minute;
// 0-59
  @override
  final String? linkedEntityId;
// habitId, goalId, etc.
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationPreference(id: $id, userId: $userId, type: $type, enabled: $enabled, title: $title, message: $message, daysOfWeek: $daysOfWeek, hour: $hour, minute: $minute, linkedEntityId: $linkedEntityId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferenceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.linkedEntityId, linkedEntityId) ||
                other.linkedEntityId == linkedEntityId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      enabled,
      title,
      message,
      const DeepCollectionEquality().hash(_daysOfWeek),
      hour,
      minute,
      linkedEntityId,
      createdAt,
      updatedAt);

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferenceImplCopyWith<_$NotificationPreferenceImpl>
      get copyWith => __$$NotificationPreferenceImplCopyWithImpl<
          _$NotificationPreferenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferenceImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreference extends NotificationPreference {
  const factory _NotificationPreference(
          {required final String id,
          required final String userId,
          required final ReminderType type,
          required final bool enabled,
          required final String title,
          required final String message,
          required final List<int> daysOfWeek,
          required final int hour,
          required final int minute,
          final String? linkedEntityId,
          @TimestampConverter() final DateTime? createdAt,
          @TimestampConverter() final DateTime? updatedAt}) =
      _$NotificationPreferenceImpl;
  const _NotificationPreference._() : super._();

  factory _NotificationPreference.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferenceImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  ReminderType get type;
  @override
  bool get enabled;
  @override
  String get title;
  @override
  String get message;
  @override
  List<int> get daysOfWeek; // 1=Monday, 7=Sunday
  @override
  int get hour; // 0-23
  @override
  int get minute; // 0-59
  @override
  String? get linkedEntityId; // habitId, goalId, etc.
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of NotificationPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferenceImplCopyWith<_$NotificationPreferenceImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationHistory _$NotificationHistoryFromJson(Map<String, dynamic> json) {
  return _NotificationHistory.fromJson(json);
}

/// @nodoc
mixin _$NotificationHistory {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get preferenceId => throw _privateConstructorUsedError;
  ReminderType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get sentAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get readAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get actionedAt => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;

  /// Serializes this NotificationHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationHistoryCopyWith<NotificationHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationHistoryCopyWith<$Res> {
  factory $NotificationHistoryCopyWith(
          NotificationHistory value, $Res Function(NotificationHistory) then) =
      _$NotificationHistoryCopyWithImpl<$Res, NotificationHistory>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String preferenceId,
      ReminderType type,
      String title,
      String message,
      @TimestampConverter() DateTime sentAt,
      @TimestampConverter() DateTime? readAt,
      @TimestampConverter() DateTime? actionedAt,
      String? action});
}

/// @nodoc
class _$NotificationHistoryCopyWithImpl<$Res, $Val extends NotificationHistory>
    implements $NotificationHistoryCopyWith<$Res> {
  _$NotificationHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? preferenceId = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? sentAt = null,
    Object? readAt = freezed,
    Object? actionedAt = freezed,
    Object? action = freezed,
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
      preferenceId: null == preferenceId
          ? _value.preferenceId
          : preferenceId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionedAt: freezed == actionedAt
          ? _value.actionedAt
          : actionedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationHistoryImplCopyWith<$Res>
    implements $NotificationHistoryCopyWith<$Res> {
  factory _$$NotificationHistoryImplCopyWith(_$NotificationHistoryImpl value,
          $Res Function(_$NotificationHistoryImpl) then) =
      __$$NotificationHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String preferenceId,
      ReminderType type,
      String title,
      String message,
      @TimestampConverter() DateTime sentAt,
      @TimestampConverter() DateTime? readAt,
      @TimestampConverter() DateTime? actionedAt,
      String? action});
}

/// @nodoc
class __$$NotificationHistoryImplCopyWithImpl<$Res>
    extends _$NotificationHistoryCopyWithImpl<$Res, _$NotificationHistoryImpl>
    implements _$$NotificationHistoryImplCopyWith<$Res> {
  __$$NotificationHistoryImplCopyWithImpl(_$NotificationHistoryImpl _value,
      $Res Function(_$NotificationHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? preferenceId = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? sentAt = null,
    Object? readAt = freezed,
    Object? actionedAt = freezed,
    Object? action = freezed,
  }) {
    return _then(_$NotificationHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      preferenceId: null == preferenceId
          ? _value.preferenceId
          : preferenceId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReminderType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionedAt: freezed == actionedAt
          ? _value.actionedAt
          : actionedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationHistoryImpl extends _NotificationHistory {
  const _$NotificationHistoryImpl(
      {required this.id,
      required this.userId,
      required this.preferenceId,
      required this.type,
      required this.title,
      required this.message,
      @TimestampConverter() required this.sentAt,
      @TimestampConverter() this.readAt,
      @TimestampConverter() this.actionedAt,
      this.action})
      : super._();

  factory _$NotificationHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String preferenceId;
  @override
  final ReminderType type;
  @override
  final String title;
  @override
  final String message;
  @override
  @TimestampConverter()
  final DateTime sentAt;
  @override
  @TimestampConverter()
  final DateTime? readAt;
  @override
  @TimestampConverter()
  final DateTime? actionedAt;
  @override
  final String? action;

  @override
  String toString() {
    return 'NotificationHistory(id: $id, userId: $userId, preferenceId: $preferenceId, type: $type, title: $title, message: $message, sentAt: $sentAt, readAt: $readAt, actionedAt: $actionedAt, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.preferenceId, preferenceId) ||
                other.preferenceId == preferenceId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.actionedAt, actionedAt) ||
                other.actionedAt == actionedAt) &&
            (identical(other.action, action) || other.action == action));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, preferenceId, type,
      title, message, sentAt, readAt, actionedAt, action);

  /// Create a copy of NotificationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationHistoryImplCopyWith<_$NotificationHistoryImpl> get copyWith =>
      __$$NotificationHistoryImplCopyWithImpl<_$NotificationHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationHistoryImplToJson(
      this,
    );
  }
}

abstract class _NotificationHistory extends NotificationHistory {
  const factory _NotificationHistory(
      {required final String id,
      required final String userId,
      required final String preferenceId,
      required final ReminderType type,
      required final String title,
      required final String message,
      @TimestampConverter() required final DateTime sentAt,
      @TimestampConverter() final DateTime? readAt,
      @TimestampConverter() final DateTime? actionedAt,
      final String? action}) = _$NotificationHistoryImpl;
  const _NotificationHistory._() : super._();

  factory _NotificationHistory.fromJson(Map<String, dynamic> json) =
      _$NotificationHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get preferenceId;
  @override
  ReminderType get type;
  @override
  String get title;
  @override
  String get message;
  @override
  @TimestampConverter()
  DateTime get sentAt;
  @override
  @TimestampConverter()
  DateTime? get readAt;
  @override
  @TimestampConverter()
  DateTime? get actionedAt;
  @override
  String? get action;

  /// Create a copy of NotificationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationHistoryImplCopyWith<_$NotificationHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
