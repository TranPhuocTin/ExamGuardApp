import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'exam.dart';

part 'exam_response.g.dart';

@JsonSerializable()
class ExamResponse extends Equatable {
  final String message;
  final int status;
  final ExamMetadata metadata;

  const ExamResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory ExamResponse.fromJson(Map<String, dynamic> json) => _$ExamResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExamResponseToJson(this);

  @override
  List<Object?> get props => [message, status, metadata];
}

@JsonSerializable()
class ExamMetadata extends Equatable {
  final int total;
  final int totalPages;
  final List<Exam> exams;

  const ExamMetadata({
    required this.total,
    required this.totalPages,
    required this.exams,
  });

  factory ExamMetadata.fromJson(Map<String, dynamic> json) => _$ExamMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ExamMetadataToJson(this);

  @override
  List<Object?> get props => [total, totalPages, exams];
}
