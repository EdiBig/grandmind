// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cache_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CacheEntry _$CacheEntryFromJson(Map<String, dynamic> json) {
  return _CacheEntry.fromJson(json);
}

/// @nodoc
mixin _$CacheEntry {
  String get id => throw _privateConstructorUsedError;
  String get promptHash => throw _privateConstructorUsedError;
  String get response => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  int get inputTokens => throw _privateConstructorUsedError;
  int get outputTokens => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get promptType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this CacheEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CacheEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CacheEntryCopyWith<CacheEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheEntryCopyWith<$Res> {
  factory $CacheEntryCopyWith(
          CacheEntry value, $Res Function(CacheEntry) then) =
      _$CacheEntryCopyWithImpl<$Res, CacheEntry>;
  @useResult
  $Res call(
      {String id,
      String promptHash,
      String response,
      DateTime createdAt,
      DateTime expiresAt,
      int inputTokens,
      int outputTokens,
      double cost,
      String? userId,
      String? promptType,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$CacheEntryCopyWithImpl<$Res, $Val extends CacheEntry>
    implements $CacheEntryCopyWith<$Res> {
  _$CacheEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CacheEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? promptHash = null,
    Object? response = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? cost = null,
    Object? userId = freezed,
    Object? promptType = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      promptHash: null == promptHash
          ? _value.promptHash
          : promptHash // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inputTokens: null == inputTokens
          ? _value.inputTokens
          : inputTokens // ignore: cast_nullable_to_non_nullable
              as int,
      outputTokens: null == outputTokens
          ? _value.outputTokens
          : outputTokens // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      promptType: freezed == promptType
          ? _value.promptType
          : promptType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CacheEntryImplCopyWith<$Res>
    implements $CacheEntryCopyWith<$Res> {
  factory _$$CacheEntryImplCopyWith(
          _$CacheEntryImpl value, $Res Function(_$CacheEntryImpl) then) =
      __$$CacheEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String promptHash,
      String response,
      DateTime createdAt,
      DateTime expiresAt,
      int inputTokens,
      int outputTokens,
      double cost,
      String? userId,
      String? promptType,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$CacheEntryImplCopyWithImpl<$Res>
    extends _$CacheEntryCopyWithImpl<$Res, _$CacheEntryImpl>
    implements _$$CacheEntryImplCopyWith<$Res> {
  __$$CacheEntryImplCopyWithImpl(
      _$CacheEntryImpl _value, $Res Function(_$CacheEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CacheEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? promptHash = null,
    Object? response = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? cost = null,
    Object? userId = freezed,
    Object? promptType = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$CacheEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      promptHash: null == promptHash
          ? _value.promptHash
          : promptHash // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inputTokens: null == inputTokens
          ? _value.inputTokens
          : inputTokens // ignore: cast_nullable_to_non_nullable
              as int,
      outputTokens: null == outputTokens
          ? _value.outputTokens
          : outputTokens // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      promptType: freezed == promptType
          ? _value.promptType
          : promptType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CacheEntryImpl implements _CacheEntry {
  const _$CacheEntryImpl(
      {required this.id,
      required this.promptHash,
      required this.response,
      required this.createdAt,
      required this.expiresAt,
      required this.inputTokens,
      required this.outputTokens,
      required this.cost,
      this.userId,
      this.promptType,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$CacheEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CacheEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String promptHash;
  @override
  final String response;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  final int inputTokens;
  @override
  final int outputTokens;
  @override
  final double cost;
  @override
  final String? userId;
  @override
  final String? promptType;
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
    return 'CacheEntry(id: $id, promptHash: $promptHash, response: $response, createdAt: $createdAt, expiresAt: $expiresAt, inputTokens: $inputTokens, outputTokens: $outputTokens, cost: $cost, userId: $userId, promptType: $promptType, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.promptHash, promptHash) ||
                other.promptHash == promptHash) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.inputTokens, inputTokens) ||
                other.inputTokens == inputTokens) &&
            (identical(other.outputTokens, outputTokens) ||
                other.outputTokens == outputTokens) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.promptType, promptType) ||
                other.promptType == promptType) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      promptHash,
      response,
      createdAt,
      expiresAt,
      inputTokens,
      outputTokens,
      cost,
      userId,
      promptType,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of CacheEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheEntryImplCopyWith<_$CacheEntryImpl> get copyWith =>
      __$$CacheEntryImplCopyWithImpl<_$CacheEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CacheEntryImplToJson(
      this,
    );
  }
}

abstract class _CacheEntry implements CacheEntry {
  const factory _CacheEntry(
      {required final String id,
      required final String promptHash,
      required final String response,
      required final DateTime createdAt,
      required final DateTime expiresAt,
      required final int inputTokens,
      required final int outputTokens,
      required final double cost,
      final String? userId,
      final String? promptType,
      final Map<String, dynamic>? metadata}) = _$CacheEntryImpl;

  factory _CacheEntry.fromJson(Map<String, dynamic> json) =
      _$CacheEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get promptHash;
  @override
  String get response;
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  int get inputTokens;
  @override
  int get outputTokens;
  @override
  double get cost;
  @override
  String? get userId;
  @override
  String? get promptType;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of CacheEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheEntryImplCopyWith<_$CacheEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CacheLookupRequest {
  String get promptHash => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get promptType => throw _privateConstructorUsedError;

  /// Create a copy of CacheLookupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CacheLookupRequestCopyWith<CacheLookupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheLookupRequestCopyWith<$Res> {
  factory $CacheLookupRequestCopyWith(
          CacheLookupRequest value, $Res Function(CacheLookupRequest) then) =
      _$CacheLookupRequestCopyWithImpl<$Res, CacheLookupRequest>;
  @useResult
  $Res call({String promptHash, String? userId, String? promptType});
}

/// @nodoc
class _$CacheLookupRequestCopyWithImpl<$Res, $Val extends CacheLookupRequest>
    implements $CacheLookupRequestCopyWith<$Res> {
  _$CacheLookupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CacheLookupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promptHash = null,
    Object? userId = freezed,
    Object? promptType = freezed,
  }) {
    return _then(_value.copyWith(
      promptHash: null == promptHash
          ? _value.promptHash
          : promptHash // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      promptType: freezed == promptType
          ? _value.promptType
          : promptType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CacheLookupRequestImplCopyWith<$Res>
    implements $CacheLookupRequestCopyWith<$Res> {
  factory _$$CacheLookupRequestImplCopyWith(_$CacheLookupRequestImpl value,
          $Res Function(_$CacheLookupRequestImpl) then) =
      __$$CacheLookupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String promptHash, String? userId, String? promptType});
}

/// @nodoc
class __$$CacheLookupRequestImplCopyWithImpl<$Res>
    extends _$CacheLookupRequestCopyWithImpl<$Res, _$CacheLookupRequestImpl>
    implements _$$CacheLookupRequestImplCopyWith<$Res> {
  __$$CacheLookupRequestImplCopyWithImpl(_$CacheLookupRequestImpl _value,
      $Res Function(_$CacheLookupRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CacheLookupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promptHash = null,
    Object? userId = freezed,
    Object? promptType = freezed,
  }) {
    return _then(_$CacheLookupRequestImpl(
      promptHash: null == promptHash
          ? _value.promptHash
          : promptHash // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      promptType: freezed == promptType
          ? _value.promptType
          : promptType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CacheLookupRequestImpl implements _CacheLookupRequest {
  const _$CacheLookupRequestImpl(
      {required this.promptHash, this.userId, this.promptType});

  @override
  final String promptHash;
  @override
  final String? userId;
  @override
  final String? promptType;

  @override
  String toString() {
    return 'CacheLookupRequest(promptHash: $promptHash, userId: $userId, promptType: $promptType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheLookupRequestImpl &&
            (identical(other.promptHash, promptHash) ||
                other.promptHash == promptHash) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.promptType, promptType) ||
                other.promptType == promptType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, promptHash, userId, promptType);

  /// Create a copy of CacheLookupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheLookupRequestImplCopyWith<_$CacheLookupRequestImpl> get copyWith =>
      __$$CacheLookupRequestImplCopyWithImpl<_$CacheLookupRequestImpl>(
          this, _$identity);
}

abstract class _CacheLookupRequest implements CacheLookupRequest {
  const factory _CacheLookupRequest(
      {required final String promptHash,
      final String? userId,
      final String? promptType}) = _$CacheLookupRequestImpl;

  @override
  String get promptHash;
  @override
  String? get userId;
  @override
  String? get promptType;

  /// Create a copy of CacheLookupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheLookupRequestImplCopyWith<_$CacheLookupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CacheStats _$CacheStatsFromJson(Map<String, dynamic> json) {
  return _CacheStats.fromJson(json);
}

/// @nodoc
mixin _$CacheStats {
  int get totalRequests => throw _privateConstructorUsedError;
  int get cacheHits => throw _privateConstructorUsedError;
  int get cacheMisses => throw _privateConstructorUsedError;
  double get totalCostSaved => throw _privateConstructorUsedError;
  int get tier1Hits => throw _privateConstructorUsedError;
  int get tier2Hits => throw _privateConstructorUsedError;
  int get tier3Hits => throw _privateConstructorUsedError;
  DateTime? get periodStart => throw _privateConstructorUsedError;
  DateTime? get periodEnd => throw _privateConstructorUsedError;

  /// Serializes this CacheStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CacheStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CacheStatsCopyWith<CacheStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CacheStatsCopyWith<$Res> {
  factory $CacheStatsCopyWith(
          CacheStats value, $Res Function(CacheStats) then) =
      _$CacheStatsCopyWithImpl<$Res, CacheStats>;
  @useResult
  $Res call(
      {int totalRequests,
      int cacheHits,
      int cacheMisses,
      double totalCostSaved,
      int tier1Hits,
      int tier2Hits,
      int tier3Hits,
      DateTime? periodStart,
      DateTime? periodEnd});
}

/// @nodoc
class _$CacheStatsCopyWithImpl<$Res, $Val extends CacheStats>
    implements $CacheStatsCopyWith<$Res> {
  _$CacheStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CacheStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRequests = null,
    Object? cacheHits = null,
    Object? cacheMisses = null,
    Object? totalCostSaved = null,
    Object? tier1Hits = null,
    Object? tier2Hits = null,
    Object? tier3Hits = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_value.copyWith(
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      cacheHits: null == cacheHits
          ? _value.cacheHits
          : cacheHits // ignore: cast_nullable_to_non_nullable
              as int,
      cacheMisses: null == cacheMisses
          ? _value.cacheMisses
          : cacheMisses // ignore: cast_nullable_to_non_nullable
              as int,
      totalCostSaved: null == totalCostSaved
          ? _value.totalCostSaved
          : totalCostSaved // ignore: cast_nullable_to_non_nullable
              as double,
      tier1Hits: null == tier1Hits
          ? _value.tier1Hits
          : tier1Hits // ignore: cast_nullable_to_non_nullable
              as int,
      tier2Hits: null == tier2Hits
          ? _value.tier2Hits
          : tier2Hits // ignore: cast_nullable_to_non_nullable
              as int,
      tier3Hits: null == tier3Hits
          ? _value.tier3Hits
          : tier3Hits // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CacheStatsImplCopyWith<$Res>
    implements $CacheStatsCopyWith<$Res> {
  factory _$$CacheStatsImplCopyWith(
          _$CacheStatsImpl value, $Res Function(_$CacheStatsImpl) then) =
      __$$CacheStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalRequests,
      int cacheHits,
      int cacheMisses,
      double totalCostSaved,
      int tier1Hits,
      int tier2Hits,
      int tier3Hits,
      DateTime? periodStart,
      DateTime? periodEnd});
}

/// @nodoc
class __$$CacheStatsImplCopyWithImpl<$Res>
    extends _$CacheStatsCopyWithImpl<$Res, _$CacheStatsImpl>
    implements _$$CacheStatsImplCopyWith<$Res> {
  __$$CacheStatsImplCopyWithImpl(
      _$CacheStatsImpl _value, $Res Function(_$CacheStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CacheStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRequests = null,
    Object? cacheHits = null,
    Object? cacheMisses = null,
    Object? totalCostSaved = null,
    Object? tier1Hits = null,
    Object? tier2Hits = null,
    Object? tier3Hits = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
  }) {
    return _then(_$CacheStatsImpl(
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      cacheHits: null == cacheHits
          ? _value.cacheHits
          : cacheHits // ignore: cast_nullable_to_non_nullable
              as int,
      cacheMisses: null == cacheMisses
          ? _value.cacheMisses
          : cacheMisses // ignore: cast_nullable_to_non_nullable
              as int,
      totalCostSaved: null == totalCostSaved
          ? _value.totalCostSaved
          : totalCostSaved // ignore: cast_nullable_to_non_nullable
              as double,
      tier1Hits: null == tier1Hits
          ? _value.tier1Hits
          : tier1Hits // ignore: cast_nullable_to_non_nullable
              as int,
      tier2Hits: null == tier2Hits
          ? _value.tier2Hits
          : tier2Hits // ignore: cast_nullable_to_non_nullable
              as int,
      tier3Hits: null == tier3Hits
          ? _value.tier3Hits
          : tier3Hits // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CacheStatsImpl implements _CacheStats {
  const _$CacheStatsImpl(
      {required this.totalRequests,
      required this.cacheHits,
      required this.cacheMisses,
      required this.totalCostSaved,
      required this.tier1Hits,
      required this.tier2Hits,
      required this.tier3Hits,
      this.periodStart,
      this.periodEnd});

  factory _$CacheStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CacheStatsImplFromJson(json);

  @override
  final int totalRequests;
  @override
  final int cacheHits;
  @override
  final int cacheMisses;
  @override
  final double totalCostSaved;
  @override
  final int tier1Hits;
  @override
  final int tier2Hits;
  @override
  final int tier3Hits;
  @override
  final DateTime? periodStart;
  @override
  final DateTime? periodEnd;

  @override
  String toString() {
    return 'CacheStats(totalRequests: $totalRequests, cacheHits: $cacheHits, cacheMisses: $cacheMisses, totalCostSaved: $totalCostSaved, tier1Hits: $tier1Hits, tier2Hits: $tier2Hits, tier3Hits: $tier3Hits, periodStart: $periodStart, periodEnd: $periodEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheStatsImpl &&
            (identical(other.totalRequests, totalRequests) ||
                other.totalRequests == totalRequests) &&
            (identical(other.cacheHits, cacheHits) ||
                other.cacheHits == cacheHits) &&
            (identical(other.cacheMisses, cacheMisses) ||
                other.cacheMisses == cacheMisses) &&
            (identical(other.totalCostSaved, totalCostSaved) ||
                other.totalCostSaved == totalCostSaved) &&
            (identical(other.tier1Hits, tier1Hits) ||
                other.tier1Hits == tier1Hits) &&
            (identical(other.tier2Hits, tier2Hits) ||
                other.tier2Hits == tier2Hits) &&
            (identical(other.tier3Hits, tier3Hits) ||
                other.tier3Hits == tier3Hits) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalRequests,
      cacheHits,
      cacheMisses,
      totalCostSaved,
      tier1Hits,
      tier2Hits,
      tier3Hits,
      periodStart,
      periodEnd);

  /// Create a copy of CacheStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheStatsImplCopyWith<_$CacheStatsImpl> get copyWith =>
      __$$CacheStatsImplCopyWithImpl<_$CacheStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CacheStatsImplToJson(
      this,
    );
  }
}

abstract class _CacheStats implements CacheStats {
  const factory _CacheStats(
      {required final int totalRequests,
      required final int cacheHits,
      required final int cacheMisses,
      required final double totalCostSaved,
      required final int tier1Hits,
      required final int tier2Hits,
      required final int tier3Hits,
      final DateTime? periodStart,
      final DateTime? periodEnd}) = _$CacheStatsImpl;

  factory _CacheStats.fromJson(Map<String, dynamic> json) =
      _$CacheStatsImpl.fromJson;

  @override
  int get totalRequests;
  @override
  int get cacheHits;
  @override
  int get cacheMisses;
  @override
  double get totalCostSaved;
  @override
  int get tier1Hits;
  @override
  int get tier2Hits;
  @override
  int get tier3Hits;
  @override
  DateTime? get periodStart;
  @override
  DateTime? get periodEnd;

  /// Create a copy of CacheStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheStatsImplCopyWith<_$CacheStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
