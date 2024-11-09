import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/socket_service.dart';
import '../../../utils/share_preference/shared_preference.dart';

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
  final Function(String, dynamic)? onEventReceived;
  List<String> messages = [];
  bool _isClosed = false;

  RealtimeCubit(
    this._tokenStorage, 
    this._socketService, 
    {this.onEventReceived}
  ) : super(RealtimeInitial());

  Future<void> initializeSocket() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        print('❌ No token found');
        emit(RealtimeError('No authentication token found'));
        return;
      }

      print('🔌 Initializing socket connection...');
      _socketService.initSocket(token);
      
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
        if (!_isClosed && onEventReceived != null) {
          onEventReceived!('newCheatingDetected', data);
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

  void handleSocketEvent(String event, dynamic data, BuildContext context) {
    print('🎯 handleSocketEvent được gọi');
    print('- Event: $event');
    print('- Data: $data');
    
    if (event == 'newCheatingDetected') {
      print('✅ Nhận được event newCheatingDetected');
      final cheatingData = data['data'] as Map<String, dynamic>;
      print('📦 Dữ liệu cheating: $cheatingData');
      
      try {
        context.read<CheatingStatisticsCubit>().handleNewCheatingDetected(cheatingData);
        print('✅ Đã gửi dữ liệu đến CheatingStatisticsCubit');
      } catch (e) {
        print('❌ Lỗi khi gửi dữ liệu đến CheatingStatisticsCubit: $e');
      }
    }
  }

  @override
  Future<void> close() {
    print('🔄 Closing RealtimeCubit...');
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
} 