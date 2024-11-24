import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cheating_repository.dart';
import '../../../services/notification_service.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/share_preference/shared_preference.dart';
import '../../../utils/share_preference/token_cubit.dart';
import '../../teacher/exams/cubit/cheating_history_cubit.dart';
import '../../teacher/exams/model/cheating_statistics_response.dart';
import '../../teacher/exams/view/cheating_history_dialog.dart';
import 'notification_state.dart';


class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;
  final BuildContext context;
  
  NotificationCubit(this._notificationService, this.context) : super(NotificationState()) {
    print('🔄 NotificationCubit: Initializing...');
    _notificationService.setOnNotificationTap(_handleNotificationTap);
    _notificationService.initialize();
  }

  void _handleNotificationTap(String? payload) {
    print('🎯 Handling notification tap with payload: $payload');
    if (payload == null) return;
    
    try {
      final cheatingStatistic = CheatingStatistic.fromJson(jsonDecode(payload));
      print('📊 Parsed cheating statistic: ${cheatingStatistic.student.name}');
      
      // Sử dụng navigatorKey để navigation
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => CheatingHistoryCubit(
              context.read<CheatingRepository>(),
              context.read<TokenStorage>(),
              context.read<TokenCubit>(),
            )..loadHistories(
                cheatingStatistic.exam.id,
                cheatingStatistic.student.id,
              ),
            child: CheatingHistoryDialog(
              examId: cheatingStatistic.exam.id,
              studentId: cheatingStatistic.student.id,
              studentName: cheatingStatistic.student.name,
              stat: cheatingStatistic,
            ),
          ),
        ),
      );
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
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