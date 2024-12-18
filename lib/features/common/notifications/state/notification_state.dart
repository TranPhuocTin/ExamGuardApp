import 'package:equatable/equatable.dart';
import '../../models/notification.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final List<Notification> notifications;
  final NotificationStatus status;
  final String? errorMessage;
  final int currentPage;
  final bool hasMoreData;

  const NotificationState({
    this.notifications = const [],
    this.status = NotificationStatus.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  NotificationState copyWith({
    List<Notification>? notifications,
    NotificationStatus? status,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  @override
  List<Object?> get props => [notifications, status, errorMessage, currentPage, hasMoreData];
} 