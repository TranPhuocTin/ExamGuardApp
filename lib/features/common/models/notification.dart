import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationResponse {
  final String message;
  final int status;
  final List<Notification> metadata;

  NotificationResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class Notification {
  @JsonKey(name: '_id')
  final String id;
  final String noti_type;
  final String noti_content;
  final String noti_senderId;
  final String noti_receivedId;
  final NotificationOptions noti_options;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.noti_type,
    required this.noti_content,
    required this.noti_senderId,
    required this.noti_receivedId,
    required this.noti_options,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}

@JsonSerializable()
class NotificationOptions {
  final String studentName;
  final String infractionType;
  final String examTitle;

  NotificationOptions({
    required this.studentName,
    required this.infractionType,
    required this.examTitle,
  });

  factory NotificationOptions.fromJson(Map<String, dynamic> json) =>
      _$NotificationOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationOptionsToJson(this);
} 