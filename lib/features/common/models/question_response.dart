import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'question_response.g.dart';

@JsonSerializable()
class Question {
  @JsonKey(name: '_id')
  final String? id;
  final String questionText;
  final String questionType;
  final int questionScore;
  final String correctAnswer;
  final List<String> options;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Question({
    this.id,
    required this.questionText,
    required this.questionType,
    required this.questionScore,
    required this.correctAnswer,
    required this.options,
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);


  Question copyWith({
    String? id,
    String? questionText,
    String? questionType,
    int? questionScore,
    String? correctAnswer,
    List<String>? options,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      questionScore: questionScore ?? this.questionScore,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class QuestionResponse {
  final String message;
  final int status;
  final QuestionMetadata metadata;

  QuestionResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) => _$QuestionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionResponseToJson(this);
}

@JsonSerializable()
class QuestionMetadata {
  final int total;
  final int totalPages;
  final List<Question> questions;

  QuestionMetadata({
    required this.total,
    required this.totalPages,
    required this.questions,
  });

  factory QuestionMetadata.fromJson(Map<String, dynamic> json) => _$QuestionMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionMetadataToJson(this);
}
