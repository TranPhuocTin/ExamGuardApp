// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_answer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentAnswerResponse _$StudentAnswerResponseFromJson(
        Map<String, dynamic> json) =>
    StudentAnswerResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: StudentAnswerMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentAnswerResponseToJson(
        StudentAnswerResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

StudentAnswerMetadata _$StudentAnswerMetadataFromJson(
        Map<String, dynamic> json) =>
    StudentAnswerMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      answers: (json['answers'] as List<dynamic>)
          .map((e) => StudentAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentAnswerMetadataToJson(
        StudentAnswerMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'student': instance.student,
      'answers': instance.answers,
    };

StudentAnswer _$StudentAnswerFromJson(Map<String, dynamic> json) =>
    StudentAnswer(
      id: json['_id'] as String,
      answerText: json['answerText'] as String,
      isCorrect: json['isCorrect'] as bool,
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudentAnswerToJson(StudentAnswer instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'answerText': instance.answerText,
      'isCorrect': instance.isCorrect,
      'question': instance.question,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
