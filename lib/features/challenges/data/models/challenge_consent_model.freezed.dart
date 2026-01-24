// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_consent_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConsentRecord _$ConsentRecordFromJson(Map<String, dynamic> json) {
  return _ConsentRecord.fromJson(json);
}

/// @nodoc
mixin _$ConsentRecord {
  ConsentType get type => throw _privateConstructorUsedError;
  bool get granted => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get policyVersion => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;

  /// Serializes this ConsentRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsentRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsentRecordCopyWith<ConsentRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsentRecordCopyWith<$Res> {
  factory $ConsentRecordCopyWith(
          ConsentRecord value, $Res Function(ConsentRecord) then) =
      _$ConsentRecordCopyWithImpl<$Res, ConsentRecord>;
  @useResult
  $Res call(
      {ConsentType type,
      bool granted,
      DateTime timestamp,
      String policyVersion,
      String? ipAddress,
      String? userAgent});
}

/// @nodoc
class _$ConsentRecordCopyWithImpl<$Res, $Val extends ConsentRecord>
    implements $ConsentRecordCopyWith<$Res> {
  _$ConsentRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsentRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? granted = null,
    Object? timestamp = null,
    Object? policyVersion = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConsentType,
      granted: null == granted
          ? _value.granted
          : granted // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      policyVersion: null == policyVersion
          ? _value.policyVersion
          : policyVersion // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsentRecordImplCopyWith<$Res>
    implements $ConsentRecordCopyWith<$Res> {
  factory _$$ConsentRecordImplCopyWith(
          _$ConsentRecordImpl value, $Res Function(_$ConsentRecordImpl) then) =
      __$$ConsentRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ConsentType type,
      bool granted,
      DateTime timestamp,
      String policyVersion,
      String? ipAddress,
      String? userAgent});
}

/// @nodoc
class __$$ConsentRecordImplCopyWithImpl<$Res>
    extends _$ConsentRecordCopyWithImpl<$Res, _$ConsentRecordImpl>
    implements _$$ConsentRecordImplCopyWith<$Res> {
  __$$ConsentRecordImplCopyWithImpl(
      _$ConsentRecordImpl _value, $Res Function(_$ConsentRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConsentRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? granted = null,
    Object? timestamp = null,
    Object? policyVersion = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
  }) {
    return _then(_$ConsentRecordImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConsentType,
      granted: null == granted
          ? _value.granted
          : granted // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      policyVersion: null == policyVersion
          ? _value.policyVersion
          : policyVersion // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: freezed == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsentRecordImpl implements _ConsentRecord {
  const _$ConsentRecordImpl(
      {required this.type,
      required this.granted,
      required this.timestamp,
      this.policyVersion = '1.0',
      this.ipAddress,
      this.userAgent});

  factory _$ConsentRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsentRecordImplFromJson(json);

  @override
  final ConsentType type;
  @override
  final bool granted;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final String policyVersion;
  @override
  final String? ipAddress;
  @override
  final String? userAgent;

  @override
  String toString() {
    return 'ConsentRecord(type: $type, granted: $granted, timestamp: $timestamp, policyVersion: $policyVersion, ipAddress: $ipAddress, userAgent: $userAgent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsentRecordImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.granted, granted) || other.granted == granted) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.policyVersion, policyVersion) ||
                other.policyVersion == policyVersion) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, granted, timestamp,
      policyVersion, ipAddress, userAgent);

  /// Create a copy of ConsentRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsentRecordImplCopyWith<_$ConsentRecordImpl> get copyWith =>
      __$$ConsentRecordImplCopyWithImpl<_$ConsentRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsentRecordImplToJson(
      this,
    );
  }
}

abstract class _ConsentRecord implements ConsentRecord {
  const factory _ConsentRecord(
      {required final ConsentType type,
      required final bool granted,
      required final DateTime timestamp,
      final String policyVersion,
      final String? ipAddress,
      final String? userAgent}) = _$ConsentRecordImpl;

  factory _ConsentRecord.fromJson(Map<String, dynamic> json) =
      _$ConsentRecordImpl.fromJson;

  @override
  ConsentType get type;
  @override
  bool get granted;
  @override
  DateTime get timestamp;
  @override
  String get policyVersion;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;

  /// Create a copy of ConsentRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsentRecordImplCopyWith<_$ConsentRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeConsent _$ChallengeConsentFromJson(Map<String, dynamic> json) {
  return _ChallengeConsent.fromJson(json);
}

/// @nodoc
mixin _$ChallengeConsent {
  String get id => throw _privateConstructorUsedError;
  String get odataType => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, ConsentRecord> get consents => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get hasCompletedInitialConsent => throw _privateConstructorUsedError;
  String? get withdrawalReason => throw _privateConstructorUsedError;
  DateTime? get lastWithdrawalAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeConsent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeConsent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeConsentCopyWith<ChallengeConsent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeConsentCopyWith<$Res> {
  factory $ChallengeConsentCopyWith(
          ChallengeConsent value, $Res Function(ChallengeConsent) then) =
      _$ChallengeConsentCopyWithImpl<$Res, ChallengeConsent>;
  @useResult
  $Res call(
      {String id,
      String odataType,
      String userId,
      Map<String, ConsentRecord> consents,
      DateTime createdAt,
      DateTime updatedAt,
      bool hasCompletedInitialConsent,
      String? withdrawalReason,
      DateTime? lastWithdrawalAt});
}

/// @nodoc
class _$ChallengeConsentCopyWithImpl<$Res, $Val extends ChallengeConsent>
    implements $ChallengeConsentCopyWith<$Res> {
  _$ChallengeConsentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeConsent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? odataType = null,
    Object? userId = null,
    Object? consents = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? hasCompletedInitialConsent = null,
    Object? withdrawalReason = freezed,
    Object? lastWithdrawalAt = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      consents: null == consents
          ? _value.consents
          : consents // ignore: cast_nullable_to_non_nullable
              as Map<String, ConsentRecord>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hasCompletedInitialConsent: null == hasCompletedInitialConsent
          ? _value.hasCompletedInitialConsent
          : hasCompletedInitialConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      withdrawalReason: freezed == withdrawalReason
          ? _value.withdrawalReason
          : withdrawalReason // ignore: cast_nullable_to_non_nullable
              as String?,
      lastWithdrawalAt: freezed == lastWithdrawalAt
          ? _value.lastWithdrawalAt
          : lastWithdrawalAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeConsentImplCopyWith<$Res>
    implements $ChallengeConsentCopyWith<$Res> {
  factory _$$ChallengeConsentImplCopyWith(_$ChallengeConsentImpl value,
          $Res Function(_$ChallengeConsentImpl) then) =
      __$$ChallengeConsentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String odataType,
      String userId,
      Map<String, ConsentRecord> consents,
      DateTime createdAt,
      DateTime updatedAt,
      bool hasCompletedInitialConsent,
      String? withdrawalReason,
      DateTime? lastWithdrawalAt});
}

/// @nodoc
class __$$ChallengeConsentImplCopyWithImpl<$Res>
    extends _$ChallengeConsentCopyWithImpl<$Res, _$ChallengeConsentImpl>
    implements _$$ChallengeConsentImplCopyWith<$Res> {
  __$$ChallengeConsentImplCopyWithImpl(_$ChallengeConsentImpl _value,
      $Res Function(_$ChallengeConsentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeConsent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? odataType = null,
    Object? userId = null,
    Object? consents = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? hasCompletedInitialConsent = null,
    Object? withdrawalReason = freezed,
    Object? lastWithdrawalAt = freezed,
  }) {
    return _then(_$ChallengeConsentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      odataType: null == odataType
          ? _value.odataType
          : odataType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      consents: null == consents
          ? _value._consents
          : consents // ignore: cast_nullable_to_non_nullable
              as Map<String, ConsentRecord>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hasCompletedInitialConsent: null == hasCompletedInitialConsent
          ? _value.hasCompletedInitialConsent
          : hasCompletedInitialConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      withdrawalReason: freezed == withdrawalReason
          ? _value.withdrawalReason
          : withdrawalReason // ignore: cast_nullable_to_non_nullable
              as String?,
      lastWithdrawalAt: freezed == lastWithdrawalAt
          ? _value.lastWithdrawalAt
          : lastWithdrawalAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeConsentImpl extends _ChallengeConsent {
  const _$ChallengeConsentImpl(
      {required this.id,
      required this.odataType,
      required this.userId,
      required final Map<String, ConsentRecord> consents,
      required this.createdAt,
      required this.updatedAt,
      this.hasCompletedInitialConsent = false,
      this.withdrawalReason,
      this.lastWithdrawalAt})
      : _consents = consents,
        super._();

  factory _$ChallengeConsentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeConsentImplFromJson(json);

  @override
  final String id;
  @override
  final String odataType;
  @override
  final String userId;
  final Map<String, ConsentRecord> _consents;
  @override
  Map<String, ConsentRecord> get consents {
    if (_consents is EqualUnmodifiableMapView) return _consents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_consents);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool hasCompletedInitialConsent;
  @override
  final String? withdrawalReason;
  @override
  final DateTime? lastWithdrawalAt;

  @override
  String toString() {
    return 'ChallengeConsent(id: $id, odataType: $odataType, userId: $userId, consents: $consents, createdAt: $createdAt, updatedAt: $updatedAt, hasCompletedInitialConsent: $hasCompletedInitialConsent, withdrawalReason: $withdrawalReason, lastWithdrawalAt: $lastWithdrawalAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeConsentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.odataType, odataType) ||
                other.odataType == odataType) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(other._consents, _consents) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hasCompletedInitialConsent,
                    hasCompletedInitialConsent) ||
                other.hasCompletedInitialConsent ==
                    hasCompletedInitialConsent) &&
            (identical(other.withdrawalReason, withdrawalReason) ||
                other.withdrawalReason == withdrawalReason) &&
            (identical(other.lastWithdrawalAt, lastWithdrawalAt) ||
                other.lastWithdrawalAt == lastWithdrawalAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      odataType,
      userId,
      const DeepCollectionEquality().hash(_consents),
      createdAt,
      updatedAt,
      hasCompletedInitialConsent,
      withdrawalReason,
      lastWithdrawalAt);

  /// Create a copy of ChallengeConsent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeConsentImplCopyWith<_$ChallengeConsentImpl> get copyWith =>
      __$$ChallengeConsentImplCopyWithImpl<_$ChallengeConsentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeConsentImplToJson(
      this,
    );
  }
}

abstract class _ChallengeConsent extends ChallengeConsent {
  const factory _ChallengeConsent(
      {required final String id,
      required final String odataType,
      required final String userId,
      required final Map<String, ConsentRecord> consents,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool hasCompletedInitialConsent,
      final String? withdrawalReason,
      final DateTime? lastWithdrawalAt}) = _$ChallengeConsentImpl;
  const _ChallengeConsent._() : super._();

  factory _ChallengeConsent.fromJson(Map<String, dynamic> json) =
      _$ChallengeConsentImpl.fromJson;

  @override
  String get id;
  @override
  String get odataType;
  @override
  String get userId;
  @override
  Map<String, ConsentRecord> get consents;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get hasCompletedInitialConsent;
  @override
  String? get withdrawalReason;
  @override
  DateTime? get lastWithdrawalAt;

  /// Create a copy of ChallengeConsent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeConsentImplCopyWith<_$ChallengeConsentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsentWithdrawalRequest _$ConsentWithdrawalRequestFromJson(
    Map<String, dynamic> json) {
  return _ConsentWithdrawalRequest.fromJson(json);
}

/// @nodoc
mixin _$ConsentWithdrawalRequest {
  String get userId => throw _privateConstructorUsedError;
  List<ConsentType> get consentsToWithdraw =>
      throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;
  bool get deleteAssociatedData => throw _privateConstructorUsedError;
  bool get processed => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;

  /// Serializes this ConsentWithdrawalRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsentWithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsentWithdrawalRequestCopyWith<ConsentWithdrawalRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsentWithdrawalRequestCopyWith<$Res> {
  factory $ConsentWithdrawalRequestCopyWith(ConsentWithdrawalRequest value,
          $Res Function(ConsentWithdrawalRequest) then) =
      _$ConsentWithdrawalRequestCopyWithImpl<$Res, ConsentWithdrawalRequest>;
  @useResult
  $Res call(
      {String userId,
      List<ConsentType> consentsToWithdraw,
      String reason,
      DateTime requestedAt,
      bool deleteAssociatedData,
      bool processed,
      DateTime? processedAt});
}

/// @nodoc
class _$ConsentWithdrawalRequestCopyWithImpl<$Res,
        $Val extends ConsentWithdrawalRequest>
    implements $ConsentWithdrawalRequestCopyWith<$Res> {
  _$ConsentWithdrawalRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsentWithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? consentsToWithdraw = null,
    Object? reason = null,
    Object? requestedAt = null,
    Object? deleteAssociatedData = null,
    Object? processed = null,
    Object? processedAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      consentsToWithdraw: null == consentsToWithdraw
          ? _value.consentsToWithdraw
          : consentsToWithdraw // ignore: cast_nullable_to_non_nullable
              as List<ConsentType>,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deleteAssociatedData: null == deleteAssociatedData
          ? _value.deleteAssociatedData
          : deleteAssociatedData // ignore: cast_nullable_to_non_nullable
              as bool,
      processed: null == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as bool,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsentWithdrawalRequestImplCopyWith<$Res>
    implements $ConsentWithdrawalRequestCopyWith<$Res> {
  factory _$$ConsentWithdrawalRequestImplCopyWith(
          _$ConsentWithdrawalRequestImpl value,
          $Res Function(_$ConsentWithdrawalRequestImpl) then) =
      __$$ConsentWithdrawalRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      List<ConsentType> consentsToWithdraw,
      String reason,
      DateTime requestedAt,
      bool deleteAssociatedData,
      bool processed,
      DateTime? processedAt});
}

/// @nodoc
class __$$ConsentWithdrawalRequestImplCopyWithImpl<$Res>
    extends _$ConsentWithdrawalRequestCopyWithImpl<$Res,
        _$ConsentWithdrawalRequestImpl>
    implements _$$ConsentWithdrawalRequestImplCopyWith<$Res> {
  __$$ConsentWithdrawalRequestImplCopyWithImpl(
      _$ConsentWithdrawalRequestImpl _value,
      $Res Function(_$ConsentWithdrawalRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConsentWithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? consentsToWithdraw = null,
    Object? reason = null,
    Object? requestedAt = null,
    Object? deleteAssociatedData = null,
    Object? processed = null,
    Object? processedAt = freezed,
  }) {
    return _then(_$ConsentWithdrawalRequestImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      consentsToWithdraw: null == consentsToWithdraw
          ? _value._consentsToWithdraw
          : consentsToWithdraw // ignore: cast_nullable_to_non_nullable
              as List<ConsentType>,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deleteAssociatedData: null == deleteAssociatedData
          ? _value.deleteAssociatedData
          : deleteAssociatedData // ignore: cast_nullable_to_non_nullable
              as bool,
      processed: null == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as bool,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsentWithdrawalRequestImpl implements _ConsentWithdrawalRequest {
  const _$ConsentWithdrawalRequestImpl(
      {required this.userId,
      required final List<ConsentType> consentsToWithdraw,
      required this.reason,
      required this.requestedAt,
      this.deleteAssociatedData = false,
      this.processed = false,
      this.processedAt})
      : _consentsToWithdraw = consentsToWithdraw;

  factory _$ConsentWithdrawalRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsentWithdrawalRequestImplFromJson(json);

  @override
  final String userId;
  final List<ConsentType> _consentsToWithdraw;
  @override
  List<ConsentType> get consentsToWithdraw {
    if (_consentsToWithdraw is EqualUnmodifiableListView)
      return _consentsToWithdraw;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_consentsToWithdraw);
  }

  @override
  final String reason;
  @override
  final DateTime requestedAt;
  @override
  @JsonKey()
  final bool deleteAssociatedData;
  @override
  @JsonKey()
  final bool processed;
  @override
  final DateTime? processedAt;

  @override
  String toString() {
    return 'ConsentWithdrawalRequest(userId: $userId, consentsToWithdraw: $consentsToWithdraw, reason: $reason, requestedAt: $requestedAt, deleteAssociatedData: $deleteAssociatedData, processed: $processed, processedAt: $processedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsentWithdrawalRequestImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._consentsToWithdraw, _consentsToWithdraw) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.deleteAssociatedData, deleteAssociatedData) ||
                other.deleteAssociatedData == deleteAssociatedData) &&
            (identical(other.processed, processed) ||
                other.processed == processed) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      const DeepCollectionEquality().hash(_consentsToWithdraw),
      reason,
      requestedAt,
      deleteAssociatedData,
      processed,
      processedAt);

  /// Create a copy of ConsentWithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsentWithdrawalRequestImplCopyWith<_$ConsentWithdrawalRequestImpl>
      get copyWith => __$$ConsentWithdrawalRequestImplCopyWithImpl<
          _$ConsentWithdrawalRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsentWithdrawalRequestImplToJson(
      this,
    );
  }
}

abstract class _ConsentWithdrawalRequest implements ConsentWithdrawalRequest {
  const factory _ConsentWithdrawalRequest(
      {required final String userId,
      required final List<ConsentType> consentsToWithdraw,
      required final String reason,
      required final DateTime requestedAt,
      final bool deleteAssociatedData,
      final bool processed,
      final DateTime? processedAt}) = _$ConsentWithdrawalRequestImpl;

  factory _ConsentWithdrawalRequest.fromJson(Map<String, dynamic> json) =
      _$ConsentWithdrawalRequestImpl.fromJson;

  @override
  String get userId;
  @override
  List<ConsentType> get consentsToWithdraw;
  @override
  String get reason;
  @override
  DateTime get requestedAt;
  @override
  bool get deleteAssociatedData;
  @override
  bool get processed;
  @override
  DateTime? get processedAt;

  /// Create a copy of ConsentWithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsentWithdrawalRequestImplCopyWith<_$ConsentWithdrawalRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
