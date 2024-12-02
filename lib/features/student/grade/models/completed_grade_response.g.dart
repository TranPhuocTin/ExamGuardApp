// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_grade_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletedGradeResponse _$CompletedGradeResponseFromJson(
        Map<String, dynamic> json) =>
    CompletedGradeResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: CompletedGradeMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompletedGradeResponseToJson(
        CompletedGradeResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

CompletedGradeMetadata _$CompletedGradeMetadataFromJson(
        Map<String, dynamic> json) =>
    CompletedGradeMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      grades: (json['grades'] as List<dynamic>)
          .map((e) => CompletedGrade.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompletedGradeMetadataToJson(
        CompletedGradeMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'grades': instance.grades,
    };

CompletedGrade _$CompletedGradeFromJson(Map<String, dynamic> json) =>
    CompletedGrade(
      id: json['_id'] as String,
      score: (json['score'] as num).toInt(),
      exam: json['exam'] == null
          ? null
          : CompletedExam.fromJson(json['exam'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CompletedGradeToJson(CompletedGrade instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'score': instance.score,
      'exam': instance.exam,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CompletedExam _$CompletedExamFromJson(Map<String, dynamic> json) =>
    CompletedExam(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      teacher: json['teacher'] as String,
    );

Map<String, dynamic> _$CompletedExamToJson(CompletedExam instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'teacher': instance.teacher,
    };
