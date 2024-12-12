import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../services/app_lifecycle_service.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../models/cheating_detection_state.dart';

part 'app_monitoring_state.dart';

class AppMonitoringCubit extends Cubit<AppMonitoringState> {
  final AppLifecycleService _appLifecycleService;
  final CheatingRepository _cheatingRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  final String examId;
  
  StreamSubscription? _appStateSubscription;
  Timer? _monitoringTimer;
  Timer? _cheatingTimer;
  static const Duration _cheatingDelay = Duration(seconds: 5);
  CheatingDetectionState? _pendingCheatingState;
  bool _hasReportedCurrentViolation = false;

  AppMonitoringCubit({
    required this.examId,
    required AppLifecycleService appLifecycleService,
    required CheatingRepository cheatingRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  }) : _appLifecycleService = appLifecycleService,
       _cheatingRepository = cheatingRepository,
       _tokenStorage = tokenStorage,
       _tokenCubit = tokenCubit,
       super(AppMonitoringState(
         isMonitoring: false,
         currentBehavior: CheatingBehavior.normal,
         cheatingLogs: [],
         error: null,
       ));

  void startMonitoring() {
    if (state.isMonitoring) return;
    
    try {
      _appLifecycleService.initialize();
      _setupAppStateListener();
      _startPeriodicCheck();
      emit(state.copyWith(
        isMonitoring: true,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to start monitoring: ${e.toString()}',
        isMonitoring: false,
      ));
    }
  }

  void _setupAppStateListener() {
    _appStateSubscription = _appLifecycleService.appStateStream.listen((state) {
      _handleAppStateChange(state);
    });
  }

  void _startPeriodicCheck() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkCurrentState();
    });
  }

  void _checkCurrentState() {
    final currentState = _appLifecycleService.currentState;

    if (currentState == AppState.background) {
      _handleCheatingDetection(
        CheatingBehavior.switchTab,
        'Application switched to another tab/window',
      );
    } else if (currentState == AppState.minimized) {
      _handleCheatingDetection(
        CheatingBehavior.switchTab,
        'Application was minimized',
      );
    } else if (currentState == AppState.normal) {
      _handleCheatingDetection(
        CheatingBehavior.normal,
        'Application is in normal state',
      );
    }
  }

  void _handleAppStateChange(AppState state) {
    switch (state) {
      case AppState.background:
        _handleCheatingDetection(
          CheatingBehavior.switchTab,
          'Application switched to another tab/window',
        );
        break;
      case AppState.minimized:
        _handleCheatingDetection(
          CheatingBehavior.switchTab,
          'Application was minimized',
        );
        break;
      case AppState.normal:
        _handleCheatingDetection(
          CheatingBehavior.normal,
          'Application is in normal state',
        );
        break;
    }
  }

  void _handleCheatingDetection(CheatingBehavior behavior, String message) {
    if (behavior == state.currentBehavior) return;

    final detectionState = CheatingDetectionState(
      behavior: CheatingBehavior.switchTab,
      message: message,
      timestamp: DateTime.now(),
    );

    final updatedLogs = [...state.cheatingLogs, detectionState];
    print('🔄 Phát hiện thay đổi hành vi: ${behavior.name}');
    print('📝 Message: $message');

    if (behavior == CheatingBehavior.normal) {
      print('✅ Trở về trạng thái bình thường - Hủy timer');
      _cheatingTimer?.cancel();
      _pendingCheatingState = null;
      _hasReportedCurrentViolation = false;
      emit(state.copyWith(
        currentBehavior: behavior,
        cheatingLogs: updatedLogs,
        error: null,
      ));
      return;
    }

    if (!_hasReportedCurrentViolation) {
      print('⚠️ Phát hiện hành vi bất thường - Bắt đầu đếm thời gian 5s');
      _cheatingTimer?.cancel();
      _pendingCheatingState = detectionState;

      _cheatingTimer = Timer(_cheatingDelay, () async {
        print('⏰ Hết thời gian delay 5s');

        if (_pendingCheatingState == detectionState && !_hasReportedCurrentViolation) {
          print('✅ Hành vi vẫn tiếp tục sau 5s - Chuẩn bị gửi báo cáo');
          try {
            final clientId = await _tokenStorage.getClientId();
            final token = await _tokenStorage.getAccessToken();

            if (clientId != null && token != null) {
              print('🚀 Gửi báo cáo lên server');
              await _submitReport(clientId, token, detectionState);
              _hasReportedCurrentViolation = true;
            }
          } catch (e) {
            print('❌ Lỗi khi gửi báo cáo: $e');
            emit(state.copyWith(error: 'Lỗi khi gửi báo cáo: ${e.toString()}'));
          }
        } else {
          print('🚫 Hành vi đã thay đổi trong 5s hoặc đã được báo cáo - Không gửi báo cáo');
        }
      });
    } else {
      print('⏭️ Vi phạm này đã được báo cáo - Bỏ qua');
    }

    emit(state.copyWith(
      currentBehavior: behavior,
      cheatingLogs: updatedLogs,
      error: null,
    ));
  }

  Future<void> _submitReport(String clientId, String token, CheatingDetectionState detectionState) async {
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
      
      if (e.toString().contains('401') || e.toString().contains('403')) {
        _tokenCubit.handleTokenError(e);
        emit(state.copyWith(
          error: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          isMonitoring: false,
        ));
        stopMonitoring();
      } else {
        emit(state.copyWith(
          error: 'Không thể gửi báo cáo: ${e.toString()}',
        ));
      }
      rethrow;
    }
  }

  void pauseMonitoring() {
    _monitoringTimer?.cancel();
    _cheatingTimer?.cancel();
    emit(state.copyWith(isMonitoring: false));
  }

  void resumeMonitoring() {
    _startPeriodicCheck();
    emit(state.copyWith(isMonitoring: true));
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _cheatingTimer?.cancel();
    _appStateSubscription?.cancel();
    _appLifecycleService.dispose();
    emit(state.copyWith(isMonitoring: false));
  }

  @override
  Future<void> close() {
    stopMonitoring();
    return super.close();
  }
}