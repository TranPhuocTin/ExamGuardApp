import 'dart:io';

import 'package:exam_guardian/features/realtime/cubit/realtime_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/socket_service.dart';
import '../../../utils/share_preference/shared_preference.dart';
import '../../../services/notification_service.dart';

import '../../teacher/exams/cubit/cheating_statistics_cubit.dart';

// Define states
class RealtimeState {
  final List<String> messages;
  
  const RealtimeState({
    this.messages = const [],
  });
}

class RealtimeInitial extends RealtimeState {}

class RealtimeConnected extends RealtimeState {
  const RealtimeConnected({super.messages});
}

class RealtimeDisconnected extends RealtimeState {
  const RealtimeDisconnected({super.messages});
}

class RealtimeError extends RealtimeState {
  final String message;
  const RealtimeError(this.message, {super.messages});
}

class RealtimeCubit extends Cubit<RealtimeState> {
  final TokenStorage _tokenStorage;
  final SocketService _socketService;
  final NotificationService _notificationService;
  Function(String, dynamic)? onEventReceived;
  List<String> messages = [];
  bool _isClosed = false;
  Socket? _socket;

  RealtimeCubit(
    this._tokenStorage,
    this._socketService,
    this._notificationService,
    {this.onEventReceived}
  ) : super(RealtimeInitial()) {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print('🔄 Initializing services...');
    await _notificationService.initialize();
  }

  Future<void> initializeSocket() async {
    try {
      final clientId = await _tokenStorage.getClientId();
      if (clientId == null) {
        print('❌ No clientId found');
        emit(RealtimeError('No client ID found'));
        return;
      }

      print('🔌 Initializing socket connection...');
      _socketService.initSocket(teacherId: clientId);
      
      // Thêm listener này để debug
      _socketService.socket.onAny((event, data) {
        print('🔍 Socket Event Received:');
        print('- Event name: $event');
        print('- Data: $data');
      });

      // Listen to socket events
      _socketService.socket.on('connect', (_) {
        print('✅ Socket connected successfully');
        if (!_isClosed) {
          emit(RealtimeConnected(messages: List.from(messages)));
        }
      });

      _socketService.socket.on('disconnect', (_) {
        print('❌ Socket disconnected');
        if (!_isClosed) {
          emit(RealtimeDisconnected(messages: List.from(messages)));
        }
      });

      _socketService.socket.on('error', (error) {
        print('❌ Socket error: $error');
        if (!_isClosed) {
          emit(RealtimeError(error.toString(), messages: List.from(messages)));
        }
      });

      // Thêm listener cho newCheatingDetected event
      _socketService.socket.on('newCheatingDetected', (data) {
        print('🎯 Nhận được newCheatingDetected event');
          final cheatingData = Map<String, dynamic>.from(data['data']);
          
          // Hiển thị notification
          // _handleNewCheatingDetected(data);
          
          // Emit state mới để trigger BlocListener
          emit(RealtimeMessageReceived(
            event: 'newCheatingDetected',
            data: data,
            messages: List.from(messages)
          ));
        if (!_isClosed) {
          final cheatingData = Map<String, dynamic>.from(data['data']);
          String studentName = cheatingData['studentName'] ?? 'Học sinh';
          String examName = cheatingData['examName'] ?? 'Bài kiểm tra';
          String cheatingType = cheatingData['cheatingType'] ?? 'gian lận';

          showNotification(
            title: 'Phát hiện gian lận',
            body: '$studentName đã $cheatingType trong $examName',
            payload: 'newCheatingDetected_${cheatingData['examId']}',
          );

          if (onEventReceived != null) {
            onEventReceived!('newCheatingDetected', Map<String, dynamic>.from(data));
          }
        }
      });

    } catch (e) {
      print('❌ Socket initialization error: $e');
      if (!_isClosed) {
        emit(RealtimeError(e.toString(), messages: List.from(messages)));
      }
    }
  }

  void disconnect() {
    _socketService.disconnect();
    if (!_isClosed) {
      emit(RealtimeDisconnected(messages: List.from(messages)));
    }
  }

  // Example method to emit an event
  void sendExamUpdate(String examId, Map<String, dynamic> updateData) {
    if (state is RealtimeConnected) {
      _socketService.socket.emit('examUpdate', {
        'examId': examId,
        'data': updateData,
      });
    }
  }

  // void _handleNewCheatingDetected(Map<String, dynamic> data) {
  //   if (data.containsKey('data')) {
  //     final cheatingData = Map<String, dynamic>.from(data['data']);
  //     try {
  //       String studentName = cheatingData['studentName'] ?? 'Học sinh';
  //       String examName = cheatingData['examName'] ?? 'Bài kiểm tra';
  //       String cheatingType = cheatingData['cheatingType'] ?? 'gian lận';
  //
  //       final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
  //
  //       _notificationService.showNotification(
  //         id: notificationId,
  //         title: 'New cheating detected!',
  //         body: '$studentName was $cheatingType in $examName',
  //         payload: 'newCheatingDetected_${cheatingData['examId']}',
  //       );
  //     } catch (e) {
  //       print('❌ Lỗi khi xử lý thông báo gian lận: $e');
  //     }
  //   }
  // }

  @override
  Future<void> close() {
    print(' Closing RealtimeCubit...');
    _isClosed = true;
    _socketService.socket.off('connect');
    _socketService.socket.off('disconnect');
    _socketService.socket.off('student_join');
    _socketService.socket.off('cheating_detected');
    _socketService.socket.off('student_leave');
    _socketService.socket.off('error');
    _socketService.disconnect();
    return super.close();
  }

  SocketService get socketService => _socketService;

  void showNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    _notificationService.showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: payload,
    );
  }

  // Thêm setter cho onEventReceived
  set eventCallback(Function(String, dynamic)? callback) {
    onEventReceived = callback;
  }

  // Hủy callback
  void clearEventCallback() {
    onEventReceived = null;
  }

} 