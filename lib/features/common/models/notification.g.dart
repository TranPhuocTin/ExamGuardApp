// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: (json['metadata'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: json['_id'] as String,
      noti_type: json['noti_type'] as String,
      noti_content: json['noti_content'] as String,
      noti_senderId: json['noti_senderId'] as String,
      noti_receivedId: json['noti_receivedId'] as String,
      noti_options: NotificationOptions.fromJson(
          json['noti_options'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'noti_type': instance.noti_type,
      'noti_content': instance.noti_content,
      'noti_senderId': instance.noti_senderId,
      'noti_receivedId': instance.noti_receivedId,
      'noti_options': instance.noti_options,
      'createdAt': instance.createdAt.toIso8601String(),
    };

NotificationOptions _$NotificationOptionsFromJson(Map<String, dynamic> json) =>
    NotificationOptions(
      studentName: json['studentName'] as String,
      infractionType: json['infractionType'] as String,
      examTitle: json['examTitle'] as String,
    );

Map<String, dynamic> _$NotificationOptionsToJson(
        NotificationOptions instance) =>
    <String, dynamic>{
      'studentName': instance.studentName,
      'infractionType': instance.infractionType,
      'examTitle': instance.examTitle,
    };
