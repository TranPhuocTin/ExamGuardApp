import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../utils/exceptions/token_exceptions.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../models/cheating_detection_state.dart';
import 'dart:async';

import 'face_monitoring_state.dart';

class FaceMonitoringCubit extends Cubit<FaceMonitoringState> {
  final CheatingRepository _cheatingRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  final String examId;
  DateTime? _lastSubmissionTime;
  static const Duration _minimumSubmissionInterval = Duration(seconds: 5);
  Timer? _cheatingTimer;
  static const Duration _cheatingDelay = Duration(seconds: 5);
  CheatingDetectionState? _pendingCheatingState;

  FaceMonitoringCubit({
    required this.examId,
    required CheatingRepository cheatingRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : assert(examId.isNotEmpty, 'examId cannot be empty'),
        _cheatingRepository = cheatingRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(FaceMonitoringState());

  void startMonitoring() {
    emit(state.copyWith(isMonitoring: true, error: null));
  }

  void stopMonitoring() {
    emit(state.copyWith(isMonitoring: false, error: null));
  }

  void updateCheatingState(CheatingDetectionState detectionState) async {
    if (detectionState.behavior != state.currentBehavior) {
      final now = DateTime.now();
      final updatedLogs = [...state.cheatingLogs, detectionState];

      print('🔄 Phát hiện thay đổi hành vi: ${detectionState.behavior}');
      print('📝 Message: ${detectionState.message}');

      if (detectionState.behavior != CheatingBehavior.normal) {
        print('⚠️ Phát hiện hành vi bất thường - Bắt đầu đếm thời gian 5s');
        _cheatingTimer?.cancel();
        _pendingCheatingState = detectionState;

        _cheatingTimer = Timer(_cheatingDelay, () async {
          print('⏰ Hết thời gian delay 5s');

          if (_pendingCheatingState == detectionState) {
            print('✅ Hành vi vẫn tiếp tục sau 5s - Chuẩn bị gửi báo cáo');

            final shouldSubmit = _lastSubmissionTime == null ||
                now.difference(_lastSubmissionTime!) >
                    _minimumSubmissionInterval;

            if (shouldSubmit) {
              print('📤 Đủ điều kiện gửi báo cáo');
              _lastSubmissionTime = now;
              try {
                final clientId = await _tokenStorage.getClientId();
                final token = await _tokenStorage.getAccessToken();

                if (clientId != null && token != null) {
                  print('🚀 Gửi báo cáo lên server');
                  await _submitCheatingReport(clientId, token, detectionState);
                }
              } catch (e) {
                print('❌ Lỗi khi gửi báo cáo: $e');
                handleError('Lỗi khi gửi báo cáo: ${e.toString()}');
              }
            } else {
              print('⏳ Chưa đủ thời gian giữa 2 lần gửi báo cáo');
            }
          } else {
            print('🚫 Hành vi đã thay đổi trong 5s - Không gửi báo cáo');
          }
        });
      } else {
        print('✅ Trở về trạng thái bình thường - Hủy timer');
        _cheatingTimer?.cancel();
        _pendingCheatingState = null;
      }

      emit(state.copyWith(
        currentBehavior: detectionState.behavior,
        cheatingLogs: updatedLogs,
        error: null,
      ));
    }
  }

  Future<void> _submitCheatingReport(String clientId, String token,
      CheatingDetectionState detectionState) async {
    try {
      print('📊 Chi tiết báo cáo:');
      print('- Hành vi: ${detectionState.behavior}');
      print('- Thời gian: ${detectionState.timestamp}');
      print('- Message: ${detectionState.message}');

      await _cheatingRepository.submitDetectCheating(
        clientId,
        token,
        examId,
        detectionState,
      );
      print('✅ Gửi báo cáo thành công');
    } catch (e) {
      print('❌ Lỗi khi gửi báo cáo: $e');
      _tokenCubit.handleTokenError(e);
      emit(state.copyWith(
        error: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        isMonitoring: false,
      ));
    }
  }

  void handleError(String errorMessage) {
    emit(state.copyWith(
      error: errorMessage,
      isMonitoring: false,
    ));
  }

  @override
  Future<void> close() {
    _cheatingTimer?.cancel();
    return super.close();
  }
}
