import 'package:bloc/bloc.dart';

import '../../../services/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;
  
  NotificationCubit(this._notificationService) : super(NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    
    // Thiết lập callback khi notification được click
    _notificationService.setOnNotificationTap((String? payload) {
      handleNotificationTap(payload);
    });
  }

  void showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    
    // Hiển thị notification
    await _notificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );

    // Lưu notification vào state
    final newNotification = NotificationMessage(
      id: id.toString(),
      title: title,
      body: body,
      payload: payload,
    );

    final updatedNotifications = [
      newNotification,
      ...state.notifications,
    ];

    emit(state.copyWith(notifications: updatedNotifications));
  }

  void handleNotificationTap(String? payload) {
    if (payload == null) return;
    
    // Xử lý các loại payload khác nhau
    if (payload.startsWith('newCheatingDetected_')) {
      final examId = payload.split('_')[1];
      // Navigate to exam detail
      print('Navigate to exam detail: $examId');
    }
  }

  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return NotificationMessage(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          payload: notification.payload,
          timestamp: notification.timestamp,
          isRead: true,
        );
      }
      return notification;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }
} 