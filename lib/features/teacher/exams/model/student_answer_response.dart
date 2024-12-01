import 'package:json_annotation/json_annotation.dart';

import '../../../common/models/question_response.dart';
import 'cheating_statistics_response.dart';
part 'student_answer_response.g.dart';

@JsonSerializable()
class StudentAnswerResponse {
  final String message;
  final int status;
  final StudentAnswerMetadata metadata;

  StudentAnswerResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory StudentAnswerResponse.fromJson(Map<String, dynamic> json) => 
      _$StudentAnswerResponseFromJson(json);
}

@JsonSerializable()
class StudentAnswerMetadata {
  final int total;
  final int totalPages;
  final Student student;
  final List<StudentAnswer> answers;

  StudentAnswerMetadata({
    required this.total,
    required this.totalPages,
    required this.student,
    required this.answers,
  });

  factory StudentAnswerMetadata.fromJson(Map<String, dynamic> json) => 
      _$StudentAnswerMetadataFromJson(json);
}

@JsonSerializable()
class StudentAnswer {
  @JsonKey(name: '_id')
  final String id;
  final String answerText;
  final bool isCorrect;
  final Question question;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentAnswer({
    required this.id,
    required this.answerText,
    required this.isCorrect,
    required this.question,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) => 
      _$StudentAnswerFromJson(json);
} 