// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['_id'] as String?,
      questionText: json['questionText'] as String,
      questionType: json['questionType'] as String,
      questionScore: (json['questionScore'] as num).toInt(),
      correctAnswer: json['correctAnswer'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      '_id': instance.id,
      'questionText': instance.questionText,
      'questionType': instance.questionType,
      'questionScore': instance.questionScore,
      'correctAnswer': instance.correctAnswer,
      'options': instance.options,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

QuestionResponse _$QuestionResponseFromJson(Map<String, dynamic> json) =>
    QuestionResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata:
          QuestionMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuestionResponseToJson(QuestionResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

QuestionMetadata _$QuestionMetadataFromJson(Map<String, dynamic> json) =>
    QuestionMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionMetadataToJson(QuestionMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'questions': instance.questions,
    };
