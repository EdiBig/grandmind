// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Milestone _$MilestoneFromJson(Map<String, dynamic> json) {
  return _Milestone.fromJson(json);
}

/// @nodoc
mixin _$Milestone {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  MilestoneType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get badge =>
      throw _privateConstructorUsedError; // Badge identifier (e.g., "5kg_lost", "10_day_streak")
  @TimestampConverter()
  DateTime get achievedAt => throw _privateConstructorUsedError;
  bool get isNew =>
      throw _privateConstructorUsedError; // Show "New" badge indicator
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneCopyWith<Milestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneCopyWith<$Res> {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) then) =
      _$MilestoneCopyWithImpl<$Res, Milestone>;
  @useResult
  $Res call(
      {String id,
      String userId,
      MilestoneType type,
      String title,
      String description,
      String badge,
      @TimestampConverter() DateTime achievedAt,
      bool isNew,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$MilestoneCopyWithImpl<$Res, $Val extends Milestone>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? badge = null,
    Object? achievedAt = null,
    Object? isNew = null,
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
              as MilestoneType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      badge: null == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneImplCopyWith<$Res>
    implements $MilestoneCopyWith<$Res> {
  factory _$$MilestoneImplCopyWith(
          _$MilestoneImpl value, $Res Function(_$MilestoneImpl) then) =
      __$$MilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      MilestoneType type,
      String title,
      String description,
      String badge,
      @TimestampConverter() DateTime achievedAt,
      bool isNew,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$MilestoneImplCopyWithImpl<$Res>
    extends _$MilestoneCopyWithImpl<$Res, _$MilestoneImpl>
    implements _$$MilestoneImplCopyWith<$Res> {
  __$$MilestoneImplCopyWithImpl(
      _$MilestoneImpl _value, $Res Function(_$MilestoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? badge = null,
    Object? achievedAt = null,
    Object? isNew = null,
    Object? metadata = freezed,
  }) {
    return _then(_$MilestoneImpl(
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
              as MilestoneType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      badge: null == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneImpl extends _Milestone {
  const _$MilestoneImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.title,
      required this.description,
      required this.badge,
      @TimestampConverter() required this.achievedAt,
      this.isNew = false,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  factory _$MilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final MilestoneType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final String badge;
// Badge identifier (e.g., "5kg_lost", "10_day_streak")
  @override
  @TimestampConverter()
  final DateTime achievedAt;
  @override
  @JsonKey()
  final bool isNew;
// Show "New" badge indicator
  final Map<String, dynamic>? _metadata;
// Show "New" badge indicator
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
    return 'Milestone(id: $id, userId: $userId, type: $type, title: $title, description: $description, badge: $badge, achievedAt: $achievedAt, isNew: $isNew, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
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
      description,
      badge,
      achievedAt,
      isNew,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      __$$MilestoneImplCopyWithImpl<_$MilestoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneImplToJson(
      this,
    );
  }
}

abstract class _Milestone extends Milestone {
  const factory _Milestone(
      {required final String id,
      required final String userId,
      required final MilestoneType type,
      required final String title,
      required final String description,
      required final String badge,
      @TimestampConverter() required final DateTime achievedAt,
      final bool isNew,
      final Map<String, dynamic>? metadata}) = _$MilestoneImpl;
  const _Milestone._() : super._();

  factory _Milestone.fromJson(Map<String, dynamic> json) =
      _$MilestoneImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  MilestoneType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  String get badge; // Badge identifier (e.g., "5kg_lost", "10_day_streak")
  @override
  @TimestampConverter()
  DateTime get achievedAt;
  @override
  bool get isNew; // Show "New" badge indicator
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MilestoneSummary _$MilestoneSummaryFromJson(Map<String, dynamic> json) {
  return _MilestoneSummary.fromJson(json);
}

/// @nodoc
mixin _$MilestoneSummary {
  List<Milestone> get recentMilestones => throw _privateConstructorUsedError;
  List<Milestone> get allMilestones => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get newCount => throw _privateConstructorUsedError;
  Map<MilestoneType, int> get countByType => throw _privateConstructorUsedError;

  /// Serializes this MilestoneSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MilestoneSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneSummaryCopyWith<MilestoneSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneSummaryCopyWith<$Res> {
  factory $MilestoneSummaryCopyWith(
          MilestoneSummary value, $Res Function(MilestoneSummary) then) =
      _$MilestoneSummaryCopyWithImpl<$Res, MilestoneSummary>;
  @useResult
  $Res call(
      {List<Milestone> recentMilestones,
      List<Milestone> allMilestones,
      int totalCount,
      int newCount,
      Map<MilestoneType, int> countByType});
}

/// @nodoc
class _$MilestoneSummaryCopyWithImpl<$Res, $Val extends MilestoneSummary>
    implements $MilestoneSummaryCopyWith<$Res> {
  _$MilestoneSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MilestoneSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentMilestones = null,
    Object? allMilestones = null,
    Object? totalCount = null,
    Object? newCount = null,
    Object? countByType = null,
  }) {
    return _then(_value.copyWith(
      recentMilestones: null == recentMilestones
          ? _value.recentMilestones
          : recentMilestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      allMilestones: null == allMilestones
          ? _value.allMilestones
          : allMilestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      newCount: null == newCount
          ? _value.newCount
          : newCount // ignore: cast_nullable_to_non_nullable
              as int,
      countByType: null == countByType
          ? _value.countByType
          : countByType // ignore: cast_nullable_to_non_nullable
              as Map<MilestoneType, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneSummaryImplCopyWith<$Res>
    implements $MilestoneSummaryCopyWith<$Res> {
  factory _$$MilestoneSummaryImplCopyWith(_$MilestoneSummaryImpl value,
          $Res Function(_$MilestoneSummaryImpl) then) =
      __$$MilestoneSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Milestone> recentMilestones,
      List<Milestone> allMilestones,
      int totalCount,
      int newCount,
      Map<MilestoneType, int> countByType});
}

/// @nodoc
class __$$MilestoneSummaryImplCopyWithImpl<$Res>
    extends _$MilestoneSummaryCopyWithImpl<$Res, _$MilestoneSummaryImpl>
    implements _$$MilestoneSummaryImplCopyWith<$Res> {
  __$$MilestoneSummaryImplCopyWithImpl(_$MilestoneSummaryImpl _value,
      $Res Function(_$MilestoneSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MilestoneSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentMilestones = null,
    Object? allMilestones = null,
    Object? totalCount = null,
    Object? newCount = null,
    Object? countByType = null,
  }) {
    return _then(_$MilestoneSummaryImpl(
      recentMilestones: null == recentMilestones
          ? _value._recentMilestones
          : recentMilestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      allMilestones: null == allMilestones
          ? _value._allMilestones
          : allMilestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      newCount: null == newCount
          ? _value.newCount
          : newCount // ignore: cast_nullable_to_non_nullable
              as int,
      countByType: null == countByType
          ? _value._countByType
          : countByType // ignore: cast_nullable_to_non_nullable
              as Map<MilestoneType, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneSummaryImpl implements _MilestoneSummary {
  const _$MilestoneSummaryImpl(
      {required final List<Milestone> recentMilestones,
      required final List<Milestone> allMilestones,
      required this.totalCount,
      required this.newCount,
      final Map<MilestoneType, int> countByType = const {}})
      : _recentMilestones = recentMilestones,
        _allMilestones = allMilestones,
        _countByType = countByType;

  factory _$MilestoneSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneSummaryImplFromJson(json);

  final List<Milestone> _recentMilestones;
  @override
  List<Milestone> get recentMilestones {
    if (_recentMilestones is EqualUnmodifiableListView)
      return _recentMilestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentMilestones);
  }

  final List<Milestone> _allMilestones;
  @override
  List<Milestone> get allMilestones {
    if (_allMilestones is EqualUnmodifiableListView) return _allMilestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allMilestones);
  }

  @override
  final int totalCount;
  @override
  final int newCount;
  final Map<MilestoneType, int> _countByType;
  @override
  @JsonKey()
  Map<MilestoneType, int> get countByType {
    if (_countByType is EqualUnmodifiableMapView) return _countByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_countByType);
  }

  @override
  String toString() {
    return 'MilestoneSummary(recentMilestones: $recentMilestones, allMilestones: $allMilestones, totalCount: $totalCount, newCount: $newCount, countByType: $countByType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneSummaryImpl &&
            const DeepCollectionEquality()
                .equals(other._recentMilestones, _recentMilestones) &&
            const DeepCollectionEquality()
                .equals(other._allMilestones, _allMilestones) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.newCount, newCount) ||
                other.newCount == newCount) &&
            const DeepCollectionEquality()
                .equals(other._countByType, _countByType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_recentMilestones),
      const DeepCollectionEquality().hash(_allMilestones),
      totalCount,
      newCount,
      const DeepCollectionEquality().hash(_countByType));

  /// Create a copy of MilestoneSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneSummaryImplCopyWith<_$MilestoneSummaryImpl> get copyWith =>
      __$$MilestoneSummaryImplCopyWithImpl<_$MilestoneSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneSummaryImplToJson(
      this,
    );
  }
}

abstract class _MilestoneSummary implements MilestoneSummary {
  const factory _MilestoneSummary(
      {required final List<Milestone> recentMilestones,
      required final List<Milestone> allMilestones,
      required final int totalCount,
      required final int newCount,
      final Map<MilestoneType, int> countByType}) = _$MilestoneSummaryImpl;

  factory _MilestoneSummary.fromJson(Map<String, dynamic> json) =
      _$MilestoneSummaryImpl.fromJson;

  @override
  List<Milestone> get recentMilestones;
  @override
  List<Milestone> get allMilestones;
  @override
  int get totalCount;
  @override
  int get newCount;
  @override
  Map<MilestoneType, int> get countByType;

  /// Create a copy of MilestoneSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneSummaryImplCopyWith<_$MilestoneSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
