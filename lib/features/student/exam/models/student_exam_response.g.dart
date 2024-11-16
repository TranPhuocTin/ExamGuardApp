// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_exam_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentExamResponse _$StudentExamResponseFromJson(Map<String, dynamic> json) =>
    StudentExamResponse(
      message: json['message'] as String?,
      status: (json['status'] as num).toInt(),
      metadata: StudentExamMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentExamResponseToJson(
        StudentExamResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

StudentExamMetadata _$StudentExamMetadataFromJson(Map<String, dynamic> json) =>
    StudentExamMetadata(
      remainingTime:
          RemainingTime.fromJson(json['remainingTime'] as Map<String, dynamic>),
      total: (json['total'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentExamMetadataToJson(
        StudentExamMetadata instance) =>
    <String, dynamic>{
      'remainingTime': instance.remainingTime,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'questions': instance.questions,
    };

RemainingTime _$RemainingTimeFromJson(Map<String, dynamic> json) =>
    RemainingTime(
      minutes: (json['minutes'] as num).toInt(),
      seconds: (json['seconds'] as num).toInt(),
    );

Map<String, dynamic> _$RemainingTimeToJson(RemainingTime instance) =>
    <String, dynamic>{
      'minutes': instance.minutes,
      'seconds': instance.seconds,
    };
