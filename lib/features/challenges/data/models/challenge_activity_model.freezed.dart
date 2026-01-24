// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChallengeActivity _$ChallengeActivityFromJson(Map<String, dynamic> json) {
  return _ChallengeActivity.fromJson(json);
}

/// @nodoc
mixin _$ChallengeActivity {
  String get id => throw _privateConstructorUsedError;
  String get odataType => throw _privateConstructorUsedError;
  String get challengeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  ChallengeActivityType get activityType => throw _privateConstructorUsedError;
  ActivityVisibility get visibility => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Display name (only populated if user consented to activity sharing)
  String? get displayName => throw _privateConstructorUsedError;

  /// Avatar URL (only populated if user consented to activity sharing)
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Activity-specific data
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Human-readable description of the activity
  String? get description => throw _privateConstructorUsedError;

  /// Whether this activity has been redacted due to privacy
  bool get isRedacted => throw _privateConstructorUsedError;

  /// Encouragement/reaction counts
  int get encouragementCount => throw _privateConstructorUsedError;

  /// Users who sent encouragement (anonymized if privacy enabled)
  List<String> get encouragedBy => throw _privateConstructorUsedError;

  /// Serializes this ChallengeActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeActivityCopyWith<ChallengeActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeActivityCopyWith<$Res> {
  factory $ChallengeActivityCopyWith(
          ChallengeActivity value, $Res Function(ChallengeActivity) then) =
      _$ChallengeActivityCopyWithImpl<$Res, ChallengeActivity>;
  @useResult
  $Res call(
      {String id,
      String odataType,
      String challengeId,
      String userId,
      ChallengeActivityType activityType,
      ActivityVisibility visibility,
      DateTime createdAt,
      String? displayName,
      String? avatarUrl,
      Map<String, dynamic>? data,
      String? description,
      bool isRedacted,
      int encouragementCount,
      List<String> encouragedBy});
}

/// @nodoc
class _$ChallengeActivityCopyWithImpl<$Res, $Val extends ChallengeActivity>
    implements $ChallengeActivityCopyWith<$Res> {
  _$ChallengeActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? odataType = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? activityType = null,
    Object? visibility = null,
    Object? createdAt = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? data = freezed,
    Object? description = freezed,
    Object? isRedacted = null,
    Object? encouragementCount = null,
    Object? encouragedBy = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      odataType: null == odataType
          ? _value.odataType
          : odataType // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as ChallengeActivityType,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as ActivityVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isRedacted: null == isRedacted
          ? _value.isRedacted
          : isRedacted // ignore: cast_nullable_to_non_nullable
              as bool,
      encouragementCount: null == encouragementCount
          ? _value.encouragementCount
          : encouragementCount // ignore: cast_nullable_to_non_nullable
              as int,
      encouragedBy: null == encouragedBy
          ? _value.encouragedBy
          : encouragedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeActivityImplCopyWith<$Res>
    implements $ChallengeActivityCopyWith<$Res> {
  factory _$$ChallengeActivityImplCopyWith(_$ChallengeActivityImpl value,
          $Res Function(_$ChallengeActivityImpl) then) =
      __$$ChallengeActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String odataType,
      String challengeId,
      String userId,
      ChallengeActivityType activityType,
      ActivityVisibility visibility,
      DateTime createdAt,
      String? displayName,
      String? avatarUrl,
      Map<String, dynamic>? data,
      String? description,
      bool isRedacted,
      int encouragementCount,
      List<String> encouragedBy});
}

/// @nodoc
class __$$ChallengeActivityImplCopyWithImpl<$Res>
    extends _$ChallengeActivityCopyWithImpl<$Res, _$ChallengeActivityImpl>
    implements _$$ChallengeActivityImplCopyWith<$Res> {
  __$$ChallengeActivityImplCopyWithImpl(_$ChallengeActivityImpl _value,
      $Res Function(_$ChallengeActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? odataType = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? activityType = null,
    Object? visibility = null,
    Object? createdAt = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? data = freezed,
    Object? description = freezed,
    Object? isRedacted = null,
    Object? encouragementCount = null,
    Object? encouragedBy = null,
  }) {
    return _then(_$ChallengeActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      odataType: null == odataType
          ? _value.odataType
          : odataType // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as ChallengeActivityType,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as ActivityVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isRedacted: null == isRedacted
          ? _value.isRedacted
          : isRedacted // ignore: cast_nullable_to_non_nullable
              as bool,
      encouragementCount: null == encouragementCount
          ? _value.encouragementCount
          : encouragementCount // ignore: cast_nullable_to_non_nullable
              as int,
      encouragedBy: null == encouragedBy
          ? _value._encouragedBy
          : encouragedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeActivityImpl extends _ChallengeActivity {
  const _$ChallengeActivityImpl(
      {required this.id,
      required this.odataType,
      required this.challengeId,
      required this.userId,
      required this.activityType,
      required this.visibility,
      required this.createdAt,
      this.displayName,
      this.avatarUrl,
      final Map<String, dynamic>? data,
      this.description,
      this.isRedacted = false,
      this.encouragementCount = 0,
      final List<String> encouragedBy = const []})
      : _data = data,
        _encouragedBy = encouragedBy,
        super._();

  factory _$ChallengeActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String odataType;
  @override
  final String challengeId;
  @override
  final String userId;
  @override
  final ChallengeActivityType activityType;
  @override
  final ActivityVisibility visibility;
  @override
  final DateTime createdAt;

  /// Display name (only populated if user consented to activity sharing)
  @override
  final String? displayName;

  /// Avatar URL (only populated if user consented to activity sharing)
  @override
  final String? avatarUrl;

  /// Activity-specific data
  final Map<String, dynamic>? _data;

  /// Activity-specific data
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Human-readable description of the activity
  @override
  final String? description;

  /// Whether this activity has been redacted due to privacy
  @override
  @JsonKey()
  final bool isRedacted;

  /// Encouragement/reaction counts
  @override
  @JsonKey()
  final int encouragementCount;

  /// Users who sent encouragement (anonymized if privacy enabled)
  final List<String> _encouragedBy;

  /// Users who sent encouragement (anonymized if privacy enabled)
  @override
  @JsonKey()
  List<String> get encouragedBy {
    if (_encouragedBy is EqualUnmodifiableListView) return _encouragedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_encouragedBy);
  }

  @override
  String toString() {
    return 'ChallengeActivity(id: $id, odataType: $odataType, challengeId: $challengeId, userId: $userId, activityType: $activityType, visibility: $visibility, createdAt: $createdAt, displayName: $displayName, avatarUrl: $avatarUrl, data: $data, description: $description, isRedacted: $isRedacted, encouragementCount: $encouragementCount, encouragedBy: $encouragedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.odataType, odataType) ||
                other.odataType == odataType) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isRedacted, isRedacted) ||
                other.isRedacted == isRedacted) &&
            (identical(other.encouragementCount, encouragementCount) ||
                other.encouragementCount == encouragementCount) &&
            const DeepCollectionEquality()
                .equals(other._encouragedBy, _encouragedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      odataType,
      challengeId,
      userId,
      activityType,
      visibility,
      createdAt,
      displayName,
      avatarUrl,
      const DeepCollectionEquality().hash(_data),
      description,
      isRedacted,
      encouragementCount,
      const DeepCollectionEquality().hash(_encouragedBy));

  /// Create a copy of ChallengeActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeActivityImplCopyWith<_$ChallengeActivityImpl> get copyWith =>
      __$$ChallengeActivityImplCopyWithImpl<_$ChallengeActivityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeActivityImplToJson(
      this,
    );
  }
}

abstract class _ChallengeActivity extends ChallengeActivity {
  const factory _ChallengeActivity(
      {required final String id,
      required final String odataType,
      required final String challengeId,
      required final String userId,
      required final ChallengeActivityType activityType,
      required final ActivityVisibility visibility,
      required final DateTime createdAt,
      final String? displayName,
      final String? avatarUrl,
      final Map<String, dynamic>? data,
      final String? description,
      final bool isRedacted,
      final int encouragementCount,
      final List<String> encouragedBy}) = _$ChallengeActivityImpl;
  const _ChallengeActivity._() : super._();

  factory _ChallengeActivity.fromJson(Map<String, dynamic> json) =
      _$ChallengeActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get odataType;
  @override
  String get challengeId;
  @override
  String get userId;
  @override
  ChallengeActivityType get activityType;
  @override
  ActivityVisibility get visibility;
  @override
  DateTime get createdAt;

  /// Display name (only populated if user consented to activity sharing)
  @override
  String? get displayName;

  /// Avatar URL (only populated if user consented to activity sharing)
  @override
  String? get avatarUrl;

  /// Activity-specific data
  @override
  Map<String, dynamic>? get data;

  /// Human-readable description of the activity
  @override
  String? get description;

  /// Whether this activity has been redacted due to privacy
  @override
  bool get isRedacted;

  /// Encouragement/reaction counts
  @override
  int get encouragementCount;

  /// Users who sent encouragement (anonymized if privacy enabled)
  @override
  List<String> get encouragedBy;

  /// Create a copy of ChallengeActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeActivityImplCopyWith<_$ChallengeActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeActivityStats _$ChallengeActivityStatsFromJson(
    Map<String, dynamic> json) {
  return _ChallengeActivityStats.fromJson(json);
}

/// @nodoc
mixin _$ChallengeActivityStats {
  String get challengeId => throw _privateConstructorUsedError;
  int get totalActivities => throw _privateConstructorUsedError;
  int get totalEncouragements => throw _privateConstructorUsedError;
  int get participantsActive => throw _privateConstructorUsedError;
  Map<String, int> get activityTypeBreakdown =>
      throw _privateConstructorUsedError;
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeActivityStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeActivityStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeActivityStatsCopyWith<ChallengeActivityStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeActivityStatsCopyWith<$Res> {
  factory $ChallengeActivityStatsCopyWith(ChallengeActivityStats value,
          $Res Function(ChallengeActivityStats) then) =
      _$ChallengeActivityStatsCopyWithImpl<$Res, ChallengeActivityStats>;
  @useResult
  $Res call(
      {String challengeId,
      int totalActivities,
      int totalEncouragements,
      int participantsActive,
      Map<String, int> activityTypeBreakdown,
      DateTime? lastActivityAt});
}

/// @nodoc
class _$ChallengeActivityStatsCopyWithImpl<$Res,
        $Val extends ChallengeActivityStats>
    implements $ChallengeActivityStatsCopyWith<$Res> {
  _$ChallengeActivityStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeActivityStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? totalActivities = null,
    Object? totalEncouragements = null,
    Object? participantsActive = null,
    Object? activityTypeBreakdown = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(_value.copyWith(
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      totalActivities: null == totalActivities
          ? _value.totalActivities
          : totalActivities // ignore: cast_nullable_to_non_nullable
              as int,
      totalEncouragements: null == totalEncouragements
          ? _value.totalEncouragements
          : totalEncouragements // ignore: cast_nullable_to_non_nullable
              as int,
      participantsActive: null == participantsActive
          ? _value.participantsActive
          : participantsActive // ignore: cast_nullable_to_non_nullable
              as int,
      activityTypeBreakdown: null == activityTypeBreakdown
          ? _value.activityTypeBreakdown
          : activityTypeBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeActivityStatsImplCopyWith<$Res>
    implements $ChallengeActivityStatsCopyWith<$Res> {
  factory _$$ChallengeActivityStatsImplCopyWith(
          _$ChallengeActivityStatsImpl value,
          $Res Function(_$ChallengeActivityStatsImpl) then) =
      __$$ChallengeActivityStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challengeId,
      int totalActivities,
      int totalEncouragements,
      int participantsActive,
      Map<String, int> activityTypeBreakdown,
      DateTime? lastActivityAt});
}

/// @nodoc
class __$$ChallengeActivityStatsImplCopyWithImpl<$Res>
    extends _$ChallengeActivityStatsCopyWithImpl<$Res,
        _$ChallengeActivityStatsImpl>
    implements _$$ChallengeActivityStatsImplCopyWith<$Res> {
  __$$ChallengeActivityStatsImplCopyWithImpl(
      _$ChallengeActivityStatsImpl _value,
      $Res Function(_$ChallengeActivityStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeActivityStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? totalActivities = null,
    Object? totalEncouragements = null,
    Object? participantsActive = null,
    Object? activityTypeBreakdown = null,
    Object? lastActivityAt = freezed,
  }) {
    return _then(_$ChallengeActivityStatsImpl(
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      totalActivities: null == totalActivities
          ? _value.totalActivities
          : totalActivities // ignore: cast_nullable_to_non_nullable
              as int,
      totalEncouragements: null == totalEncouragements
          ? _value.totalEncouragements
          : totalEncouragements // ignore: cast_nullable_to_non_nullable
              as int,
      participantsActive: null == participantsActive
          ? _value.participantsActive
          : participantsActive // ignore: cast_nullable_to_non_nullable
              as int,
      activityTypeBreakdown: null == activityTypeBreakdown
          ? _value._activityTypeBreakdown
          : activityTypeBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeActivityStatsImpl implements _ChallengeActivityStats {
  const _$ChallengeActivityStatsImpl(
      {required this.challengeId,
      this.totalActivities = 0,
      this.totalEncouragements = 0,
      this.participantsActive = 0,
      final Map<String, int> activityTypeBreakdown = const {},
      this.lastActivityAt})
      : _activityTypeBreakdown = activityTypeBreakdown;

  factory _$ChallengeActivityStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeActivityStatsImplFromJson(json);

  @override
  final String challengeId;
  @override
  @JsonKey()
  final int totalActivities;
  @override
  @JsonKey()
  final int totalEncouragements;
  @override
  @JsonKey()
  final int participantsActive;
  final Map<String, int> _activityTypeBreakdown;
  @override
  @JsonKey()
  Map<String, int> get activityTypeBreakdown {
    if (_activityTypeBreakdown is EqualUnmodifiableMapView)
      return _activityTypeBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activityTypeBreakdown);
  }

  @override
  final DateTime? lastActivityAt;

  @override
  String toString() {
    return 'ChallengeActivityStats(challengeId: $challengeId, totalActivities: $totalActivities, totalEncouragements: $totalEncouragements, participantsActive: $participantsActive, activityTypeBreakdown: $activityTypeBreakdown, lastActivityAt: $lastActivityAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeActivityStatsImpl &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.totalActivities, totalActivities) ||
                other.totalActivities == totalActivities) &&
            (identical(other.totalEncouragements, totalEncouragements) ||
                other.totalEncouragements == totalEncouragements) &&
            (identical(other.participantsActive, participantsActive) ||
                other.participantsActive == participantsActive) &&
            const DeepCollectionEquality()
                .equals(other._activityTypeBreakdown, _activityTypeBreakdown) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challengeId,
      totalActivities,
      totalEncouragements,
      participantsActive,
      const DeepCollectionEquality().hash(_activityTypeBreakdown),
      lastActivityAt);

  /// Create a copy of ChallengeActivityStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeActivityStatsImplCopyWith<_$ChallengeActivityStatsImpl>
      get copyWith => __$$ChallengeActivityStatsImplCopyWithImpl<
          _$ChallengeActivityStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeActivityStatsImplToJson(
      this,
    );
  }
}

abstract class _ChallengeActivityStats implements ChallengeActivityStats {
  const factory _ChallengeActivityStats(
      {required final String challengeId,
      final int totalActivities,
      final int totalEncouragements,
      final int participantsActive,
      final Map<String, int> activityTypeBreakdown,
      final DateTime? lastActivityAt}) = _$ChallengeActivityStatsImpl;

  factory _ChallengeActivityStats.fromJson(Map<String, dynamic> json) =
      _$ChallengeActivityStatsImpl.fromJson;

  @override
  String get challengeId;
  @override
  int get totalActivities;
  @override
  int get totalEncouragements;
  @override
  int get participantsActive;
  @override
  Map<String, int> get activityTypeBreakdown;
  @override
  DateTime? get lastActivityAt;

  /// Create a copy of ChallengeActivityStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeActivityStatsImplCopyWith<_$ChallengeActivityStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
