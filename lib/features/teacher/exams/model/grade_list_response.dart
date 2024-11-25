import 'package:exam_guardian/features/teacher/exams/model/cheating_statistics_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade_list_response.g.dart';

@JsonSerializable()
class GradeListResponse {
  final String message;
  final int status;
  final GradeListMetadata metadata;

  GradeListResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory GradeListResponse.fromJson(Map<String, dynamic> json) =>
      _$GradeListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$GradeListResponseToJson(this);
}

@JsonSerializable()
class GradeListMetadata {
  final int total;
  final int totalPages;
  final List<GradeDetail> grades;

  GradeListMetadata({
    required this.total,
    required this.totalPages,
    required this.grades,
  });

  factory GradeListMetadata.fromJson(Map<String, dynamic> json) =>
      _$GradeListMetadataFromJson(json);
  
  Map<String, dynamic> toJson() => _$GradeListMetadataToJson(this);
}

@JsonSerializable()
class GradeDetail {
  @JsonKey(name: '_id')
  final String id;
  final int score;
  final Student student;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradeDetail({
    required this.id,
    required this.score,
    required this.student,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradeDetail.fromJson(Map<String, dynamic> json) =>
      _$GradeDetailFromJson(json);
  
  Map<String, dynamic> toJson() => _$GradeDetailToJson(this);
} 