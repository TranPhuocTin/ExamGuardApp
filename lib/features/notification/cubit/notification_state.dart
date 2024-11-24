class NotificationState {
  final List<NotificationMessage> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationMessage>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  final bool isRead;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();
} 