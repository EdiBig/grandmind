// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_best.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PersonalBest _$PersonalBestFromJson(Map<String, dynamic> json) {
  return _PersonalBest.fromJson(json);
}

/// @nodoc
mixin _$PersonalBest {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  PersonalBestCategory get category => throw _privateConstructorUsedError;
  String get title =>
      throw _privateConstructorUsedError; // e.g., "Heaviest Bench Press"
  String get metric =>
      throw _privateConstructorUsedError; // e.g., "Bench Press", "5K Run"
  double get value => throw _privateConstructorUsedError; // The record value
  String get unit =>
      throw _privateConstructorUsedError; // e.g., "kg", "lbs", "min", "days"
  @TimestampConverter()
  DateTime get achievedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  double? get previousValue =>
      throw _privateConstructorUsedError; // Previous best for comparison
  @TimestampConverter()
  DateTime? get previousDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get workoutLogId => throw _privateConstructorUsedError;

  /// Serializes this PersonalBest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonalBest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalBestCopyWith<PersonalBest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalBestCopyWith<$Res> {
  factory $PersonalBestCopyWith(
          PersonalBest value, $Res Function(PersonalBest) then) =
      _$PersonalBestCopyWithImpl<$Res, PersonalBest>;
  @useResult
  $Res call(
      {String id,
      String userId,
      PersonalBestCategory category,
      String title,
      String metric,
      double value,
      String unit,
      @TimestampConverter() DateTime achievedAt,
      @TimestampConverter() DateTime createdAt,
      double? previousValue,
      @TimestampConverter() DateTime? previousDate,
      String? notes,
      String? workoutLogId});
}

/// @nodoc
class _$PersonalBestCopyWithImpl<$Res, $Val extends PersonalBest>
    implements $PersonalBestCopyWith<$Res> {
  _$PersonalBestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalBest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? title = null,
    Object? metric = null,
    Object? value = null,
    Object? unit = null,
    Object? achievedAt = null,
    Object? createdAt = null,
    Object? previousValue = freezed,
    Object? previousDate = freezed,
    Object? notes = freezed,
    Object? workoutLogId = freezed,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as PersonalBestCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      previousValue: freezed == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double?,
      previousDate: freezed == previousDate
          ? _value.previousDate
          : previousDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutLogId: freezed == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalBestImplCopyWith<$Res>
    implements $PersonalBestCopyWith<$Res> {
  factory _$$PersonalBestImplCopyWith(
          _$PersonalBestImpl value, $Res Function(_$PersonalBestImpl) then) =
      __$$PersonalBestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      PersonalBestCategory category,
      String title,
      String metric,
      double value,
      String unit,
      @TimestampConverter() DateTime achievedAt,
      @TimestampConverter() DateTime createdAt,
      double? previousValue,
      @TimestampConverter() DateTime? previousDate,
      String? notes,
      String? workoutLogId});
}

/// @nodoc
class __$$PersonalBestImplCopyWithImpl<$Res>
    extends _$PersonalBestCopyWithImpl<$Res, _$PersonalBestImpl>
    implements _$$PersonalBestImplCopyWith<$Res> {
  __$$PersonalBestImplCopyWithImpl(
      _$PersonalBestImpl _value, $Res Function(_$PersonalBestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonalBest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? category = null,
    Object? title = null,
    Object? metric = null,
    Object? value = null,
    Object? unit = null,
    Object? achievedAt = null,
    Object? createdAt = null,
    Object? previousValue = freezed,
    Object? previousDate = freezed,
    Object? notes = freezed,
    Object? workoutLogId = freezed,
  }) {
    return _then(_$PersonalBestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as PersonalBestCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      previousValue: freezed == previousValue
          ? _value.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as double?,
      previousDate: freezed == previousDate
          ? _value.previousDate
          : previousDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutLogId: freezed == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalBestImpl extends _PersonalBest {
  const _$PersonalBestImpl(
      {required this.id,
      required this.userId,
      required this.category,
      required this.title,
      required this.metric,
      required this.value,
      required this.unit,
      @TimestampConverter() required this.achievedAt,
      @TimestampConverter() required this.createdAt,
      this.previousValue,
      @TimestampConverter() this.previousDate,
      this.notes,
      this.workoutLogId})
      : super._();

  factory _$PersonalBestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalBestImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final PersonalBestCategory category;
  @override
  final String title;
// e.g., "Heaviest Bench Press"
  @override
  final String metric;
// e.g., "Bench Press", "5K Run"
  @override
  final double value;
// The record value
  @override
  final String unit;
// e.g., "kg", "lbs", "min", "days"
  @override
  @TimestampConverter()
  final DateTime achievedAt;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final double? previousValue;
// Previous best for comparison
  @override
  @TimestampConverter()
  final DateTime? previousDate;
  @override
  final String? notes;
  @override
  final String? workoutLogId;

  @override
  String toString() {
    return 'PersonalBest(id: $id, userId: $userId, category: $category, title: $title, metric: $metric, value: $value, unit: $unit, achievedAt: $achievedAt, createdAt: $createdAt, previousValue: $previousValue, previousDate: $previousDate, notes: $notes, workoutLogId: $workoutLogId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalBestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue) &&
            (identical(other.previousDate, previousDate) ||
                other.previousDate == previousDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.workoutLogId, workoutLogId) ||
                other.workoutLogId == workoutLogId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      category,
      title,
      metric,
      value,
      unit,
      achievedAt,
      createdAt,
      previousValue,
      previousDate,
      notes,
      workoutLogId);

  /// Create a copy of PersonalBest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalBestImplCopyWith<_$PersonalBestImpl> get copyWith =>
      __$$PersonalBestImplCopyWithImpl<_$PersonalBestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalBestImplToJson(
      this,
    );
  }
}

abstract class _PersonalBest extends PersonalBest {
  const factory _PersonalBest(
      {required final String id,
      required final String userId,
      required final PersonalBestCategory category,
      required final String title,
      required final String metric,
      required final double value,
      required final String unit,
      @TimestampConverter() required final DateTime achievedAt,
      @TimestampConverter() required final DateTime createdAt,
      final double? previousValue,
      @TimestampConverter() final DateTime? previousDate,
      final String? notes,
      final String? workoutLogId}) = _$PersonalBestImpl;
  const _PersonalBest._() : super._();

  factory _PersonalBest.fromJson(Map<String, dynamic> json) =
      _$PersonalBestImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  PersonalBestCategory get category;
  @override
  String get title; // e.g., "Heaviest Bench Press"
  @override
  String get metric; // e.g., "Bench Press", "5K Run"
  @override
  double get value; // The record value
  @override
  String get unit; // e.g., "kg", "lbs", "min", "days"
  @override
  @TimestampConverter()
  DateTime get achievedAt;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  double? get previousValue; // Previous best for comparison
  @override
  @TimestampConverter()
  DateTime? get previousDate;
  @override
  String? get notes;
  @override
  String? get workoutLogId;

  /// Create a copy of PersonalBest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalBestImplCopyWith<_$PersonalBestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonalBestsSummary _$PersonalBestsSummaryFromJson(Map<String, dynamic> json) {
  return _PersonalBestsSummary.fromJson(json);
}

/// @nodoc
mixin _$PersonalBestsSummary {
  List<PersonalBest> get recentPRs =>
      throw _privateConstructorUsedError; // Last 5 PRs
  List<PersonalBest> get allTimeBests =>
      throw _privateConstructorUsedError; // All-time records by category
  int get totalPRCount => throw _privateConstructorUsedError;
  int get monthlyPRCount => throw _privateConstructorUsedError;
  Map<PersonalBestCategory, int> get prsByCategory =>
      throw _privateConstructorUsedError;

  /// Serializes this PersonalBestsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonalBestsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonalBestsSummaryCopyWith<PersonalBestsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalBestsSummaryCopyWith<$Res> {
  factory $PersonalBestsSummaryCopyWith(PersonalBestsSummary value,
          $Res Function(PersonalBestsSummary) then) =
      _$PersonalBestsSummaryCopyWithImpl<$Res, PersonalBestsSummary>;
  @useResult
  $Res call(
      {List<PersonalBest> recentPRs,
      List<PersonalBest> allTimeBests,
      int totalPRCount,
      int monthlyPRCount,
      Map<PersonalBestCategory, int> prsByCategory});
}

/// @nodoc
class _$PersonalBestsSummaryCopyWithImpl<$Res,
        $Val extends PersonalBestsSummary>
    implements $PersonalBestsSummaryCopyWith<$Res> {
  _$PersonalBestsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonalBestsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentPRs = null,
    Object? allTimeBests = null,
    Object? totalPRCount = null,
    Object? monthlyPRCount = null,
    Object? prsByCategory = null,
  }) {
    return _then(_value.copyWith(
      recentPRs: null == recentPRs
          ? _value.recentPRs
          : recentPRs // ignore: cast_nullable_to_non_nullable
              as List<PersonalBest>,
      allTimeBests: null == allTimeBests
          ? _value.allTimeBests
          : allTimeBests // ignore: cast_nullable_to_non_nullable
              as List<PersonalBest>,
      totalPRCount: null == totalPRCount
          ? _value.totalPRCount
          : totalPRCount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyPRCount: null == monthlyPRCount
          ? _value.monthlyPRCount
          : monthlyPRCount // ignore: cast_nullable_to_non_nullable
              as int,
      prsByCategory: null == prsByCategory
          ? _value.prsByCategory
          : prsByCategory // ignore: cast_nullable_to_non_nullable
              as Map<PersonalBestCategory, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalBestsSummaryImplCopyWith<$Res>
    implements $PersonalBestsSummaryCopyWith<$Res> {
  factory _$$PersonalBestsSummaryImplCopyWith(_$PersonalBestsSummaryImpl value,
          $Res Function(_$PersonalBestsSummaryImpl) then) =
      __$$PersonalBestsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PersonalBest> recentPRs,
      List<PersonalBest> allTimeBests,
      int totalPRCount,
      int monthlyPRCount,
      Map<PersonalBestCategory, int> prsByCategory});
}

/// @nodoc
class __$$PersonalBestsSummaryImplCopyWithImpl<$Res>
    extends _$PersonalBestsSummaryCopyWithImpl<$Res, _$PersonalBestsSummaryImpl>
    implements _$$PersonalBestsSummaryImplCopyWith<$Res> {
  __$$PersonalBestsSummaryImplCopyWithImpl(_$PersonalBestsSummaryImpl _value,
      $Res Function(_$PersonalBestsSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PersonalBestsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentPRs = null,
    Object? allTimeBests = null,
    Object? totalPRCount = null,
    Object? monthlyPRCount = null,
    Object? prsByCategory = null,
  }) {
    return _then(_$PersonalBestsSummaryImpl(
      recentPRs: null == recentPRs
          ? _value._recentPRs
          : recentPRs // ignore: cast_nullable_to_non_nullable
              as List<PersonalBest>,
      allTimeBests: null == allTimeBests
          ? _value._allTimeBests
          : allTimeBests // ignore: cast_nullable_to_non_nullable
              as List<PersonalBest>,
      totalPRCount: null == totalPRCount
          ? _value.totalPRCount
          : totalPRCount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyPRCount: null == monthlyPRCount
          ? _value.monthlyPRCount
          : monthlyPRCount // ignore: cast_nullable_to_non_nullable
              as int,
      prsByCategory: null == prsByCategory
          ? _value._prsByCategory
          : prsByCategory // ignore: cast_nullable_to_non_nullable
              as Map<PersonalBestCategory, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalBestsSummaryImpl implements _PersonalBestsSummary {
  const _$PersonalBestsSummaryImpl(
      {required final List<PersonalBest> recentPRs,
      required final List<PersonalBest> allTimeBests,
      required this.totalPRCount,
      required this.monthlyPRCount,
      final Map<PersonalBestCategory, int> prsByCategory = const {}})
      : _recentPRs = recentPRs,
        _allTimeBests = allTimeBests,
        _prsByCategory = prsByCategory;

  factory _$PersonalBestsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalBestsSummaryImplFromJson(json);

  final List<PersonalBest> _recentPRs;
  @override
  List<PersonalBest> get recentPRs {
    if (_recentPRs is EqualUnmodifiableListView) return _recentPRs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentPRs);
  }

// Last 5 PRs
  final List<PersonalBest> _allTimeBests;
// Last 5 PRs
  @override
  List<PersonalBest> get allTimeBests {
    if (_allTimeBests is EqualUnmodifiableListView) return _allTimeBests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allTimeBests);
  }

// All-time records by category
  @override
  final int totalPRCount;
  @override
  final int monthlyPRCount;
  final Map<PersonalBestCategory, int> _prsByCategory;
  @override
  @JsonKey()
  Map<PersonalBestCategory, int> get prsByCategory {
    if (_prsByCategory is EqualUnmodifiableMapView) return _prsByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prsByCategory);
  }

  @override
  String toString() {
    return 'PersonalBestsSummary(recentPRs: $recentPRs, allTimeBests: $allTimeBests, totalPRCount: $totalPRCount, monthlyPRCount: $monthlyPRCount, prsByCategory: $prsByCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalBestsSummaryImpl &&
            const DeepCollectionEquality()
                .equals(other._recentPRs, _recentPRs) &&
            const DeepCollectionEquality()
                .equals(other._allTimeBests, _allTimeBests) &&
            (identical(other.totalPRCount, totalPRCount) ||
                other.totalPRCount == totalPRCount) &&
            (identical(other.monthlyPRCount, monthlyPRCount) ||
                other.monthlyPRCount == monthlyPRCount) &&
            const DeepCollectionEquality()
                .equals(other._prsByCategory, _prsByCategory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_recentPRs),
      const DeepCollectionEquality().hash(_allTimeBests),
      totalPRCount,
      monthlyPRCount,
      const DeepCollectionEquality().hash(_prsByCategory));

  /// Create a copy of PersonalBestsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalBestsSummaryImplCopyWith<_$PersonalBestsSummaryImpl>
      get copyWith =>
          __$$PersonalBestsSummaryImplCopyWithImpl<_$PersonalBestsSummaryImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalBestsSummaryImplToJson(
      this,
    );
  }
}

abstract class _PersonalBestsSummary implements PersonalBestsSummary {
  const factory _PersonalBestsSummary(
          {required final List<PersonalBest> recentPRs,
          required final List<PersonalBest> allTimeBests,
          required final int totalPRCount,
          required final int monthlyPRCount,
          final Map<PersonalBestCategory, int> prsByCategory}) =
      _$PersonalBestsSummaryImpl;

  factory _PersonalBestsSummary.fromJson(Map<String, dynamic> json) =
      _$PersonalBestsSummaryImpl.fromJson;

  @override
  List<PersonalBest> get recentPRs; // Last 5 PRs
  @override
  List<PersonalBest> get allTimeBests; // All-time records by category
  @override
  int get totalPRCount;
  @override
  int get monthlyPRCount;
  @override
  Map<PersonalBestCategory, int> get prsByCategory;

  /// Create a copy of PersonalBestsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonalBestsSummaryImplCopyWith<_$PersonalBestsSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ExercisePR _$ExercisePRFromJson(Map<String, dynamic> json) {
  return _ExercisePR.fromJson(json);
}

/// @nodoc
mixin _$ExercisePR {
  String get exerciseName => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError; // in kg
  int get reps => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get achievedAt => throw _privateConstructorUsedError;
  double? get previousWeight => throw _privateConstructorUsedError;
  int? get previousReps => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get previousDate => throw _privateConstructorUsedError;

  /// Serializes this ExercisePR to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExercisePR
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExercisePRCopyWith<ExercisePR> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExercisePRCopyWith<$Res> {
  factory $ExercisePRCopyWith(
          ExercisePR value, $Res Function(ExercisePR) then) =
      _$ExercisePRCopyWithImpl<$Res, ExercisePR>;
  @useResult
  $Res call(
      {String exerciseName,
      double weight,
      int reps,
      @TimestampConverter() DateTime achievedAt,
      double? previousWeight,
      int? previousReps,
      @TimestampConverter() DateTime? previousDate});
}

/// @nodoc
class _$ExercisePRCopyWithImpl<$Res, $Val extends ExercisePR>
    implements $ExercisePRCopyWith<$Res> {
  _$ExercisePRCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExercisePR
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? achievedAt = null,
    Object? previousWeight = freezed,
    Object? previousReps = freezed,
    Object? previousDate = freezed,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      previousWeight: freezed == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      previousReps: freezed == previousReps
          ? _value.previousReps
          : previousReps // ignore: cast_nullable_to_non_nullable
              as int?,
      previousDate: freezed == previousDate
          ? _value.previousDate
          : previousDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExercisePRImplCopyWith<$Res>
    implements $ExercisePRCopyWith<$Res> {
  factory _$$ExercisePRImplCopyWith(
          _$ExercisePRImpl value, $Res Function(_$ExercisePRImpl) then) =
      __$$ExercisePRImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      double weight,
      int reps,
      @TimestampConverter() DateTime achievedAt,
      double? previousWeight,
      int? previousReps,
      @TimestampConverter() DateTime? previousDate});
}

/// @nodoc
class __$$ExercisePRImplCopyWithImpl<$Res>
    extends _$ExercisePRCopyWithImpl<$Res, _$ExercisePRImpl>
    implements _$$ExercisePRImplCopyWith<$Res> {
  __$$ExercisePRImplCopyWithImpl(
      _$ExercisePRImpl _value, $Res Function(_$ExercisePRImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExercisePR
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? achievedAt = null,
    Object? previousWeight = freezed,
    Object? previousReps = freezed,
    Object? previousDate = freezed,
  }) {
    return _then(_$ExercisePRImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      previousWeight: freezed == previousWeight
          ? _value.previousWeight
          : previousWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      previousReps: freezed == previousReps
          ? _value.previousReps
          : previousReps // ignore: cast_nullable_to_non_nullable
              as int?,
      previousDate: freezed == previousDate
          ? _value.previousDate
          : previousDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExercisePRImpl implements _ExercisePR {
  const _$ExercisePRImpl(
      {required this.exerciseName,
      required this.weight,
      required this.reps,
      @TimestampConverter() required this.achievedAt,
      this.previousWeight,
      this.previousReps,
      @TimestampConverter() this.previousDate});

  factory _$ExercisePRImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExercisePRImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final double weight;
// in kg
  @override
  final int reps;
  @override
  @TimestampConverter()
  final DateTime achievedAt;
  @override
  final double? previousWeight;
  @override
  final int? previousReps;
  @override
  @TimestampConverter()
  final DateTime? previousDate;

  @override
  String toString() {
    return 'ExercisePR(exerciseName: $exerciseName, weight: $weight, reps: $reps, achievedAt: $achievedAt, previousWeight: $previousWeight, previousReps: $previousReps, previousDate: $previousDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExercisePRImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.previousWeight, previousWeight) ||
                other.previousWeight == previousWeight) &&
            (identical(other.previousReps, previousReps) ||
                other.previousReps == previousReps) &&
            (identical(other.previousDate, previousDate) ||
                other.previousDate == previousDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, weight, reps,
      achievedAt, previousWeight, previousReps, previousDate);

  /// Create a copy of ExercisePR
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExercisePRImplCopyWith<_$ExercisePRImpl> get copyWith =>
      __$$ExercisePRImplCopyWithImpl<_$ExercisePRImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExercisePRImplToJson(
      this,
    );
  }
}

abstract class _ExercisePR implements ExercisePR {
  const factory _ExercisePR(
      {required final String exerciseName,
      required final double weight,
      required final int reps,
      @TimestampConverter() required final DateTime achievedAt,
      final double? previousWeight,
      final int? previousReps,
      @TimestampConverter() final DateTime? previousDate}) = _$ExercisePRImpl;

  factory _ExercisePR.fromJson(Map<String, dynamic> json) =
      _$ExercisePRImpl.fromJson;

  @override
  String get exerciseName;
  @override
  double get weight; // in kg
  @override
  int get reps;
  @override
  @TimestampConverter()
  DateTime get achievedAt;
  @override
  double? get previousWeight;
  @override
  int? get previousReps;
  @override
  @TimestampConverter()
  DateTime? get previousDate;

  /// Create a copy of ExercisePR
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExercisePRImplCopyWith<_$ExercisePRImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
