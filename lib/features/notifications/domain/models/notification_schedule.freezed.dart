// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationSchedule _$NotificationScheduleFromJson(Map<String, dynamic> json) {
  return _NotificationSchedule.fromJson(json);
}

/// @nodoc
mixin _$NotificationSchedule {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get scheduledTime => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  String? get recurrencePattern =>
      throw _privateConstructorUsedError; // 'daily', 'weekly', 'monthly'
  List<int>? get daysOfWeek =>
      throw _privateConstructorUsedError; // For weekly recurrence: 1 = Monday, 7 = Sunday
  TimeOfDayData? get timeOfDay => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this NotificationSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationScheduleCopyWith<NotificationSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationScheduleCopyWith<$Res> {
  factory $NotificationScheduleCopyWith(NotificationSchedule value,
          $Res Function(NotificationSchedule) then) =
      _$NotificationScheduleCopyWithImpl<$Res, NotificationSchedule>;
  @useResult
  $Res call(
      {String id,
      String userId,
      NotificationType type,
      String title,
      String body,
      @TimestampConverter() DateTime scheduledTime,
      bool isRecurring,
      String? recurrencePattern,
      List<int>? daysOfWeek,
      TimeOfDayData? timeOfDay,
      bool isActive,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? updatedAt,
      Map<String, dynamic>? metadata});

  $TimeOfDayDataCopyWith<$Res>? get timeOfDay;
}

/// @nodoc
class _$NotificationScheduleCopyWithImpl<$Res,
        $Val extends NotificationSchedule>
    implements $NotificationScheduleCopyWith<$Res> {
  _$NotificationScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledTime = null,
    Object? isRecurring = null,
    Object? recurrencePattern = freezed,
    Object? daysOfWeek = freezed,
    Object? timeOfDay = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOfWeek: freezed == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDayData?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayDataCopyWith<$Res>? get timeOfDay {
    if (_value.timeOfDay == null) {
      return null;
    }

    return $TimeOfDayDataCopyWith<$Res>(_value.timeOfDay!, (value) {
      return _then(_value.copyWith(timeOfDay: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationScheduleImplCopyWith<$Res>
    implements $NotificationScheduleCopyWith<$Res> {
  factory _$$NotificationScheduleImplCopyWith(_$NotificationScheduleImpl value,
          $Res Function(_$NotificationScheduleImpl) then) =
      __$$NotificationScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      NotificationType type,
      String title,
      String body,
      @TimestampConverter() DateTime scheduledTime,
      bool isRecurring,
      String? recurrencePattern,
      List<int>? daysOfWeek,
      TimeOfDayData? timeOfDay,
      bool isActive,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? updatedAt,
      Map<String, dynamic>? metadata});

  @override
  $TimeOfDayDataCopyWith<$Res>? get timeOfDay;
}

/// @nodoc
class __$$NotificationScheduleImplCopyWithImpl<$Res>
    extends _$NotificationScheduleCopyWithImpl<$Res, _$NotificationScheduleImpl>
    implements _$$NotificationScheduleImplCopyWith<$Res> {
  __$$NotificationScheduleImplCopyWithImpl(_$NotificationScheduleImpl _value,
      $Res Function(_$NotificationScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledTime = null,
    Object? isRecurring = null,
    Object? recurrencePattern = freezed,
    Object? daysOfWeek = freezed,
    Object? timeOfDay = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NotificationScheduleImpl(
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
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOfWeek: freezed == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      timeOfDay: freezed == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as TimeOfDayData?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationScheduleImpl extends _NotificationSchedule {
  const _$NotificationScheduleImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.title,
      required this.body,
      @TimestampConverter() required this.scheduledTime,
      this.isRecurring = false,
      this.recurrencePattern,
      final List<int>? daysOfWeek,
      this.timeOfDay,
      this.isActive = true,
      @TimestampConverter() required this.createdAt,
      @NullableTimestampConverter() this.updatedAt,
      final Map<String, dynamic>? metadata})
      : _daysOfWeek = daysOfWeek,
        _metadata = metadata,
        super._();

  factory _$NotificationScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final NotificationType type;
  @override
  final String title;
  @override
  final String body;
  @override
  @TimestampConverter()
  final DateTime scheduledTime;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final String? recurrencePattern;
// 'daily', 'weekly', 'monthly'
  final List<int>? _daysOfWeek;
// 'daily', 'weekly', 'monthly'
  @override
  List<int>? get daysOfWeek {
    final value = _daysOfWeek;
    if (value == null) return null;
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// For weekly recurrence: 1 = Monday, 7 = Sunday
  @override
  final TimeOfDayData? timeOfDay;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;
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
    return 'NotificationSchedule(id: $id, userId: $userId, type: $type, title: $title, body: $body, scheduledTime: $scheduledTime, isRecurring: $isRecurring, recurrencePattern: $recurrencePattern, daysOfWeek: $daysOfWeek, timeOfDay: $timeOfDay, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurrencePattern, recurrencePattern) ||
                other.recurrencePattern == recurrencePattern) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      title,
      body,
      scheduledTime,
      isRecurring,
      recurrencePattern,
      const DeepCollectionEquality().hash(_daysOfWeek),
      timeOfDay,
      isActive,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationScheduleImplCopyWith<_$NotificationScheduleImpl>
      get copyWith =>
          __$$NotificationScheduleImplCopyWithImpl<_$NotificationScheduleImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationScheduleImplToJson(
      this,
    );
  }
}

abstract class _NotificationSchedule extends NotificationSchedule {
  const factory _NotificationSchedule(
      {required final String id,
      required final String userId,
      required final NotificationType type,
      required final String title,
      required final String body,
      @TimestampConverter() required final DateTime scheduledTime,
      final bool isRecurring,
      final String? recurrencePattern,
      final List<int>? daysOfWeek,
      final TimeOfDayData? timeOfDay,
      final bool isActive,
      @TimestampConverter() required final DateTime createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt,
      final Map<String, dynamic>? metadata}) = _$NotificationScheduleImpl;
  const _NotificationSchedule._() : super._();

  factory _NotificationSchedule.fromJson(Map<String, dynamic> json) =
      _$NotificationScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  NotificationType get type;
  @override
  String get title;
  @override
  String get body;
  @override
  @TimestampConverter()
  DateTime get scheduledTime;
  @override
  bool get isRecurring;
  @override
  String? get recurrencePattern; // 'daily', 'weekly', 'monthly'
  @override
  List<int>? get daysOfWeek; // For weekly recurrence: 1 = Monday, 7 = Sunday
  @override
  TimeOfDayData? get timeOfDay;
  @override
  bool get isActive;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of NotificationSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationScheduleImplCopyWith<_$NotificationScheduleImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TimeOfDayData _$TimeOfDayDataFromJson(Map<String, dynamic> json) {
  return _TimeOfDayData.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDayData {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDayData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayDataCopyWith<TimeOfDayData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayDataCopyWith<$Res> {
  factory $TimeOfDayDataCopyWith(
          TimeOfDayData value, $Res Function(TimeOfDayData) then) =
      _$TimeOfDayDataCopyWithImpl<$Res, TimeOfDayData>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayDataCopyWithImpl<$Res, $Val extends TimeOfDayData>
    implements $TimeOfDayDataCopyWith<$Res> {
  _$TimeOfDayDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeOfDayDataImplCopyWith<$Res>
    implements $TimeOfDayDataCopyWith<$Res> {
  factory _$$TimeOfDayDataImplCopyWith(
          _$TimeOfDayDataImpl value, $Res Function(_$TimeOfDayDataImpl) then) =
      __$$TimeOfDayDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayDataImplCopyWithImpl<$Res>
    extends _$TimeOfDayDataCopyWithImpl<$Res, _$TimeOfDayDataImpl>
    implements _$$TimeOfDayDataImplCopyWith<$Res> {
  __$$TimeOfDayDataImplCopyWithImpl(
      _$TimeOfDayDataImpl _value, $Res Function(_$TimeOfDayDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeOfDayData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeOfDayDataImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayDataImpl extends _TimeOfDayData {
  const _$TimeOfDayDataImpl({required this.hour, required this.minute})
      : super._();

  factory _$TimeOfDayDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayDataImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDayData(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayDataImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDayData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayDataImplCopyWith<_$TimeOfDayDataImpl> get copyWith =>
      __$$TimeOfDayDataImplCopyWithImpl<_$TimeOfDayDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayDataImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDayData extends TimeOfDayData {
  const factory _TimeOfDayData(
      {required final int hour,
      required final int minute}) = _$TimeOfDayDataImpl;
  const _TimeOfDayData._() : super._();

  factory _TimeOfDayData.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayDataImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;

  /// Create a copy of TimeOfDayData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayDataImplCopyWith<_$TimeOfDayDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
