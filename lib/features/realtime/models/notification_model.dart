class NotificationModel {
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type;

  NotificationModel({
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type,
  });

  NotificationModel copyWith({
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
} 