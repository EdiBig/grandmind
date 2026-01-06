// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CacheEntryImpl _$$CacheEntryImplFromJson(Map<String, dynamic> json) =>
    _$CacheEntryImpl(
      id: json['id'] as String,
      promptHash: json['promptHash'] as String,
      response: json['response'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      inputTokens: (json['inputTokens'] as num).toInt(),
      outputTokens: (json['outputTokens'] as num).toInt(),
      cost: (json['cost'] as num).toDouble(),
      userId: json['userId'] as String?,
      promptType: json['promptType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CacheEntryImplToJson(_$CacheEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'promptHash': instance.promptHash,
      'response': instance.response,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'inputTokens': instance.inputTokens,
      'outputTokens': instance.outputTokens,
      'cost': instance.cost,
      'userId': instance.userId,
      'promptType': instance.promptType,
      'metadata': instance.metadata,
    };

_$CacheStatsImpl _$$CacheStatsImplFromJson(Map<String, dynamic> json) =>
    _$CacheStatsImpl(
      totalRequests: (json['totalRequests'] as num).toInt(),
      cacheHits: (json['cacheHits'] as num).toInt(),
      cacheMisses: (json['cacheMisses'] as num).toInt(),
      totalCostSaved: (json['totalCostSaved'] as num).toDouble(),
      tier1Hits: (json['tier1Hits'] as num).toInt(),
      tier2Hits: (json['tier2Hits'] as num).toInt(),
      tier3Hits: (json['tier3Hits'] as num).toInt(),
      periodStart: json['periodStart'] == null
          ? null
          : DateTime.parse(json['periodStart'] as String),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.parse(json['periodEnd'] as String),
    );

Map<String, dynamic> _$$CacheStatsImplToJson(_$CacheStatsImpl instance) =>
    <String, dynamic>{
      'totalRequests': instance.totalRequests,
      'cacheHits': instance.cacheHits,
      'cacheMisses': instance.cacheMisses,
      'totalCostSaved': instance.totalCostSaved,
      'tier1Hits': instance.tier1Hits,
      'tier2Hits': instance.tier2Hits,
      'tier3Hits': instance.tier3Hits,
      'periodStart': instance.periodStart?.toIso8601String(),
      'periodEnd': instance.periodEnd?.toIso8601String(),
    };
