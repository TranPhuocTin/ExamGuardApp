// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeListResponse _$GradeListResponseFromJson(Map<String, dynamic> json) =>
    GradeListResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata:
          GradeListMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GradeListResponseToJson(GradeListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

GradeListMetadata _$GradeListMetadataFromJson(Map<String, dynamic> json) =>
    GradeListMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      grades: (json['grades'] as List<dynamic>)
          .map((e) => GradeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeListMetadataToJson(GradeListMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'grades': instance.grades,
    };

GradeDetail _$GradeDetailFromJson(Map<String, dynamic> json) => GradeDetail(
      id: json['_id'] as String,
      score: (json['score'] as num).toInt(),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GradeDetailToJson(GradeDetail instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'score': instance.score,
      'student': instance.student,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
