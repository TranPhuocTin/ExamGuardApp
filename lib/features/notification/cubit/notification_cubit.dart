import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cheating_repository.dart';
import '../../../services/notification_service.dart';
import '../../../utils/navigation_service.dart';
import '../../../utils/share_preference/shared_preference.dart';
import '../../../utils/share_preference/token_cubit.dart';
import '../../teacher/exams/cubit/cheating_history_cubit.dart';
import '../../teacher/exams/model/cheating_statistics_response.dart' as cheating;
import '../../teacher/exams/view/cheating_history_dialog.dart';
import '../../teacher/exams/view/teacher_exam_monitoring_view.dart';
import 'notification_state.dart';
import '../../../features/common/models/exam.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;
  final GlobalKey<NavigatorState> _navigatorKey;

  NotificationCubit(this._notificationService, this._navigatorKey) : super(NotificationState()) {
    print('🔄 NotificationCubit: Initializing...');
    _notificationService.setOnNotificationTap(_handleNotificationTap);
    _notificationService.initialize();
  }

  Future<void> _handleNotificationTap(String? payload) async {
    print('🎯 Handling notification tap with payload: $payload');
    if (payload == null) return;

    try {
      final context = _navigatorKey.currentContext;
      if (context == null) {
        print('❌ Context is null in notification tap handler');
        return;
      }

      final cheatingStatistic = cheating.CheatingStatistic.fromJson(jsonDecode(payload));
      final convertedExam = _convertExamType(cheatingStatistic.exam);

      // Push monitoring screen and wait for it to complete
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: RouteSettings(
            name: TeacherExamMonitoringView.routeName,
            arguments: convertedExam,
          ),
          builder: (context) => BlocProvider(
            create: (context) => CheatingHistoryCubit(
              context.read<CheatingRepository>(),
              context.read<TokenStorage>(),
              context.read<TokenCubit>(),
            ),
            child: TeacherExamMonitoringView(
              exam: convertedExam,
              onNavigationComplete: () {
                if (context.mounted) {
                  _showHistoryDialog(context, cheatingStatistic);
                }
              },
            ),
          ),
        ),
        (route) => route.settings.name == '/teacher_homepage',
      );
    } catch (e) {
      print('❌ Error handling notification tap: $e');
      // Thêm xử lý lỗi cụ thể
      if (_navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
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

  Exam _convertExamType(cheating.Exam examFromStats) {
    return Exam(
      id: examFromStats.id,
      title: examFromStats.title,
      description: examFromStats.description ?? '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: '',
      duration: 0,
    );
  }

  void _showHistoryDialog(BuildContext parentContext, cheating.CheatingStatistic stat) {
    if (!parentContext.mounted) return;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => BlocProvider(
        // Tạo một BlocProvider mới cho dialog
        create: (context) => CheatingHistoryCubit(
          parentContext.read<CheatingRepository>(),
          parentContext.read<TokenStorage>(),
          parentContext.read<TokenCubit>(),
        )..loadHistories(
            stat.exam.id,
            stat.student.id,
          ),
        child: Builder(
          builder: (builderContext) => CheatingHistoryDialog(
            examId: stat.exam.id,
            studentId: stat.student.id,
            studentName: stat.student.name,
            stat: stat,
          ),
        ),
      ),
    );
  }
}
