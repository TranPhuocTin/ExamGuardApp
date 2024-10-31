import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cheating_detection_state.dart';

class FaceMonitoringState {
  final List<CheatingDetectionState> cheatingLogs;
  final CheatingBehavior currentBehavior;
  final bool isMonitoring;
  final String? error;

  FaceMonitoringState({
    this.cheatingLogs = const [],
    this.currentBehavior = CheatingBehavior.normal,
    this.isMonitoring = false,
    this.error,
  });

  FaceMonitoringState copyWith({
    List<CheatingDetectionState>? cheatingLogs,
    CheatingBehavior? currentBehavior,
    bool? isMonitoring,
    String? error,
  }) {
    return FaceMonitoringState(
      cheatingLogs: cheatingLogs ?? this.cheatingLogs,
      currentBehavior: currentBehavior ?? this.currentBehavior,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      error: error,
    );
  }
}

class FaceMonitoringCubit extends Cubit<FaceMonitoringState> {
  FaceMonitoringCubit() : super(FaceMonitoringState());

  void startMonitoring() {
    emit(state.copyWith(isMonitoring: true, error: null));
  }

  void stopMonitoring() {
    emit(state.copyWith(isMonitoring: false));
  }

  void updateCheatingState(CheatingDetectionState detectionState) {
    if (detectionState.behavior != state.currentBehavior) {
      final updatedLogs = [...state.cheatingLogs, detectionState];
      emit(state.copyWith(
        currentBehavior: detectionState.behavior,
        cheatingLogs: updatedLogs,
      ));
    }
  }

  void handleError(String errorMessage) {
    emit(state.copyWith(error: errorMessage, isMonitoring: false));
  }
} 