import 'package:json_annotation/json_annotation.dart';

part 'grade_response.g.dart';

@JsonSerializable()
class GradeResponse {
  final String message;
  final int status;
  final GradeMetadata metadata;

  GradeResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory GradeResponse.fromJson(Map<String, dynamic> json) =>
      _$GradeResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$GradeResponseToJson(this);
}

@JsonSerializable()
class GradeMetadata {
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradeMetadata({
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradeMetadata.fromJson(Map<String, dynamic> json) =>
      _$GradeMetadataFromJson(json);
  
  Map<String, dynamic> toJson() => _$GradeMetadataToJson(this);
} 