import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/question_response.dart';

part 'student_exam_response.g.dart';

@JsonSerializable()
class StudentExamResponse extends Equatable {
  final String? message;
  final int status;
  final StudentExamMetadata metadata;

  const StudentExamResponse({
    this.message,
    required this.status,
    required this.metadata,
  });

  factory StudentExamResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentExamResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StudentExamResponseToJson(this);

  @override
  List<Object?> get props => [message, status, metadata];
}

@JsonSerializable()
class StudentExamMetadata extends Equatable {
  final RemainingTime remainingTime;
  final int? total;
  final int? totalPages;
  final List<Question> questions;

  const StudentExamMetadata({
    required this.remainingTime,
    this.total,
    this.totalPages,
    required this.questions,
  });

  factory StudentExamMetadata.fromJson(Map<String, dynamic> json) =>
      _$StudentExamMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$StudentExamMetadataToJson(this);

  @override
  List<Object?> get props => [remainingTime, total, totalPages, questions];
}

@JsonSerializable()
class RemainingTime extends Equatable {
  final int minutes;
  final int seconds;

  const RemainingTime({
    required this.minutes,
    required this.seconds,
  });

  factory RemainingTime.fromJson(Map<String, dynamic> json) =>
      _$RemainingTimeFromJson(json);
  Map<String, dynamic> toJson() => _$RemainingTimeToJson(this);

  @override
  List<Object?> get props => [minutes, seconds];
} 