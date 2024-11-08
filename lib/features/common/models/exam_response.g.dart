// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamResponse _$ExamResponseFromJson(Map<String, dynamic> json) => ExamResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: ExamMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExamResponseToJson(ExamResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

ExamMetadata _$ExamMetadataFromJson(Map<String, dynamic> json) => ExamMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      exams: (json['exams'] as List<dynamic>)
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamMetadataToJson(ExamMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'exams': instance.exams,
    };
