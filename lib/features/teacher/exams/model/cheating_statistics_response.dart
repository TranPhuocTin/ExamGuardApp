import 'package:json_annotation/json_annotation.dart';

part 'cheating_statistics_response.g.dart';

@JsonSerializable()
class CheatingStatisticsResponse {
  final String message;
  final int status;
  final CheatingStatisticsMetadata metadata;

  CheatingStatisticsResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory CheatingStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$CheatingStatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingStatisticsResponseToJson(this);
}

@JsonSerializable()
class CheatingStatisticsMetadata {
  final int total;
  @JsonKey(name: 'cheatingStatistics')
  final List<CheatingStatistic> statistics;

  CheatingStatisticsMetadata({
    required this.total,
    required this.statistics,
  });

  factory CheatingStatisticsMetadata.fromJson(Map<String, dynamic> json) =>
      _$CheatingStatisticsMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingStatisticsMetadataToJson(this);
}

@JsonSerializable()
class CheatingStatistic {
  @JsonKey(name: '_id')
  final String id;
  final int faceDetectionCount;
  final int tabSwitchCount;
  final int screenCaptureCount;
  final Student student;
  final Exam exam;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheatingStatistic({
    required this.id,
    required this.faceDetectionCount,
    required this.tabSwitchCount,
    required this.screenCaptureCount,
    required this.student,
    required this.exam,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheatingStatistic.fromJson(Map<String, dynamic> json) =>
      _$CheatingStatisticFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingStatisticToJson(this);

  CheatingStatistic copyWith({
    int? faceDetectionCount,
    int? tabSwitchCount,
    int? screenCaptureCount,
  }) {
    return CheatingStatistic(
      id: id,
      student: student,
      exam: exam,
      createdAt: createdAt,
      updatedAt: updatedAt,
      faceDetectionCount: faceDetectionCount ?? this.faceDetectionCount,
      tabSwitchCount: tabSwitchCount ?? this.tabSwitchCount,
      screenCaptureCount: screenCaptureCount ?? this.screenCaptureCount,
    );
  }
}

@JsonSerializable()
class Student {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String name;
  final String email;
  final String avatar;

  Student({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

@JsonSerializable()
class Exam {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String description;

  Exam({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);
}
