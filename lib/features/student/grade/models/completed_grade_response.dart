import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'completed_grade_response.g.dart';

@JsonSerializable()
class CompletedGradeResponse extends Equatable {
  final String message;
  final int status;
  final CompletedGradeMetadata metadata;

  const CompletedGradeResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory CompletedGradeResponse.fromJson(Map<String, dynamic> json) =>
      _$CompletedGradeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedGradeResponseToJson(this);

  @override
  List<Object?> get props => [message, status, metadata];
}

@JsonSerializable()
class CompletedGradeMetadata extends Equatable {
  final int total;
  final int totalPages;
  final List<CompletedGrade> grades;

  const CompletedGradeMetadata({
    required this.total,
    required this.totalPages,
    required this.grades,
  });

  factory CompletedGradeMetadata.fromJson(Map<String, dynamic> json) =>
      _$CompletedGradeMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedGradeMetadataToJson(this);

  @override
  List<Object?> get props => [total, totalPages, grades];
}

@JsonSerializable()
class CompletedGrade extends Equatable {
  @JsonKey(name: '_id')
  final String id;
  final int score;
  final CompletedExam? exam;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompletedGrade({
    required this.id,
    required this.score,
    this.exam,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompletedGrade.fromJson(Map<String, dynamic> json) =>
      _$CompletedGradeFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedGradeToJson(this);

  @override
  List<Object?> get props => [id, score, exam, createdAt, updatedAt];
}

@JsonSerializable()
class CompletedExam extends Equatable {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String description;
  final String teacher;

  const CompletedExam({
    required this.id,
    required this.title,
    required this.description,
    required this.teacher,
  });

  factory CompletedExam.fromJson(Map<String, dynamic> json) =>
      _$CompletedExamFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedExamToJson(this);

  @override
  List<Object?> get props => [id, title, description, teacher];
} 