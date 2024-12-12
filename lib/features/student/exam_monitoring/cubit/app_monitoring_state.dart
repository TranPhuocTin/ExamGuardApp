part of 'app_monitoring_cubit.dart';

class AppMonitoringState {
  final bool isMonitoring;
  final CheatingBehavior currentBehavior;
  final List<CheatingDetectionState> cheatingLogs;
  final String? error;

  AppMonitoringState({
    required this.isMonitoring,
    required this.currentBehavior,
    required this.cheatingLogs,
    this.error,
  });

  AppMonitoringState copyWith({
    bool? isMonitoring,
    CheatingBehavior? currentBehavior,
    List<CheatingDetectionState>? cheatingLogs,
    String? error,
  }) {
    return AppMonitoringState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      currentBehavior: currentBehavior ?? this.currentBehavior,
      cheatingLogs: cheatingLogs ?? this.cheatingLogs,
      error: error,
    );
  }
}