import '../models/cheating_detection_state.dart';

class FaceMonitoringState{
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
