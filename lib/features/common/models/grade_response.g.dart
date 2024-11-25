// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeResponse _$GradeResponseFromJson(Map<String, dynamic> json) =>
    GradeResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata:
          GradeMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GradeResponseToJson(GradeResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

GradeMetadata _$GradeMetadataFromJson(Map<String, dynamic> json) =>
    GradeMetadata(
      score: (json['score'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GradeMetadataToJson(GradeMetadata instance) =>
    <String, dynamic>{
      'score': instance.score,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
