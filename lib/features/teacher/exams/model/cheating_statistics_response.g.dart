// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheating_statistics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheatingStatisticsResponse _$CheatingStatisticsResponseFromJson(
        Map<String, dynamic> json) =>
    CheatingStatisticsResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: CheatingStatisticsMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheatingStatisticsResponseToJson(
        CheatingStatisticsResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

CheatingStatisticsMetadata _$CheatingStatisticsMetadataFromJson(
        Map<String, dynamic> json) =>
    CheatingStatisticsMetadata(
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      statistics: (json['statistics'] as List<dynamic>)
          .map((e) => CheatingStatistic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CheatingStatisticsMetadataToJson(
        CheatingStatisticsMetadata instance) =>
    <String, dynamic>{
      'total': instance.total,
      'totalPages': instance.totalPages,
      'statistics': instance.statistics,
    };

CheatingStatistic _$CheatingStatisticFromJson(Map<String, dynamic> json) =>
    CheatingStatistic(
      id: json['_id'] as String,
      faceDetectionCount: (json['faceDetectionCount'] as num).toInt(),
      tabSwitchCount: (json['tabSwitchCount'] as num).toInt(),
      screenCaptureCount: (json['screenCaptureCount'] as num).toInt(),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      exam: Exam.fromJson(json['exam'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CheatingStatisticToJson(CheatingStatistic instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'faceDetectionCount': instance.faceDetectionCount,
      'tabSwitchCount': instance.tabSwitchCount,
      'screenCaptureCount': instance.screenCaptureCount,
      'student': instance.student,
      'exam': instance.exam,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: json['_id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String? ?? '',
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'avatar': instance.avatar,
    };

Exam _$ExamFromJson(Map<String, dynamic> json) => Exam(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };
