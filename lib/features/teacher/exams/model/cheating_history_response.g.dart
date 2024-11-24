// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheating_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheatingHistoryResponse _$CheatingHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    CheatingHistoryResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: CheatingHistoryMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheatingHistoryResponseToJson(
        CheatingHistoryResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

CheatingHistoryMetadata _$CheatingHistoryMetadataFromJson(
        Map<String, dynamic> json) =>
    CheatingHistoryMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      histories: (json['cheatingHistories'] as List<dynamic>)
          .map((e) => CheatingHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CheatingHistoryMetadataToJson(
        CheatingHistoryMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'cheatingHistories': instance.histories,
    };

CheatingHistory _$CheatingHistoryFromJson(Map<String, dynamic> json) =>
    CheatingHistory(
      id: json['_id'] as String,
      infractionType: json['infractionType'] as String,
      description: json['description'] as String,
      exam: json['exam'] as String,
      timeDetected: json['timeDetected'] == null
          ? null
          : DateTime.parse(json['timeDetected'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CheatingHistoryToJson(CheatingHistory instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'infractionType': instance.infractionType,
      'description': instance.description,
      'exam': instance.exam,
      'timeDetected': instance.timeDetected?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
