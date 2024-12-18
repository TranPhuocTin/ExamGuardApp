import 'package:flutter/foundation.dart';

enum MonitoringLogType {
  face,
  app,
  system
}

enum MonitoringLogLevel {
  info,
  warning,
  error
}

class MonitoringLog {
  final MonitoringLogType type;
  final MonitoringLogLevel level;
  final String message;
  final DateTime timestamp;
  final String? details;

  MonitoringLog({
    required this.type,
    required this.level,
    required this.message,
    required this.timestamp,
    this.details,
  });

  @override
  String toString() {
    final typeEmoji = _getTypeEmoji();
    final levelEmoji = _getLevelEmoji();
    final time = timestamp.toIso8601String();
    return '$typeEmoji $levelEmoji [$time] $message${details != null ? '\nDetails: $details' : ''}';
  }

  String _getTypeEmoji() {
    switch (type) {
      case MonitoringLogType.face:
        return '👤';
      case MonitoringLogType.app:
        return '📱';
      case MonitoringLogType.system:
        return '⚙️';
    }
  }

  String _getLevelEmoji() {
    switch (level) {
      case MonitoringLogLevel.info:
        return '✅';
      case MonitoringLogLevel.warning:
        return '⚠️';
      case MonitoringLogLevel.error:
        return '❌';
    }
  }
}

class MonitoringLogService {
  static final MonitoringLogService _instance = MonitoringLogService._internal();
  factory MonitoringLogService() => _instance;
  MonitoringLogService._internal();

  final List<MonitoringLog> _logs = [];
  List<MonitoringLog> get logs => List.unmodifiable(_logs);

  void _addLog(MonitoringLog log) {
    _logs.add(log);
    if (kDebugMode) {
      print(log.toString());
    }
  }

  // Face Detection Logs
  void logFaceDetection({
    required String message,
    String? details,
    MonitoringLogLevel level = MonitoringLogLevel.info,
  }) {
    _addLog(MonitoringLog(
      type: MonitoringLogType.face,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      details: details,
    ));
  }

  void logFaceNotFound() {
    logFaceDetection(
      message: 'Face not detected',
      details: 'Please ensure your face is visible to the camera',
      level: MonitoringLogLevel.warning,
    );
  }

  void logMultipleFaces() {
    logFaceDetection(
      message: 'Multiple faces detected',
      details: 'Only one face should be visible during the exam',
      level: MonitoringLogLevel.warning,
    );
  }

  void logFaceDetected() {
    logFaceDetection(
      message: 'Face detected successfully',
      level: MonitoringLogLevel.info,
    );
  }

  void logFacePosition(String position) {
    logFaceDetection(
      message: 'Unusual face position detected',
      details: position,
      level: MonitoringLogLevel.warning,
    );
  }

  // App State Logs
  void logAppState({
    required String message,
    String? details,
    MonitoringLogLevel level = MonitoringLogLevel.info,
  }) {
    _addLog(MonitoringLog(
      type: MonitoringLogType.app,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      details: details,
    ));
  }

  void logAppBackground() {
    logAppState(
      message: 'App moved to background',
      details: 'Exam requires app to stay in foreground',
      level: MonitoringLogLevel.warning,
    );
  }

  void logAppForeground() {
    logAppState(
      message: 'App returned to foreground',
      level: MonitoringLogLevel.info,
    );
  }

  void logAppMinimized() {
    logAppState(
      message: 'App was minimized',
      details: 'Exam requires full screen view',
      level: MonitoringLogLevel.warning,
    );
  }

  void logAppNormal() {
    logAppState(
      message: 'App in normal state',
      level: MonitoringLogLevel.info,
    );
  }

  void logScreenCapture() {
    logAppState(
      message: 'Screen capture detected',
      details: 'Screen recording/capture is not allowed during exam',
      level: MonitoringLogLevel.error,
    );
  }

  void logTabSwitch() {
    logAppState(
      message: 'Tab/Window switch detected',
      details: 'Switching between apps/tabs is not allowed',
      level: MonitoringLogLevel.warning,
    );
  }

  // System Logs
  void logSystem({
    required String message,
    String? details,
    MonitoringLogLevel level = MonitoringLogLevel.info,
  }) {
    _addLog(MonitoringLog(
      type: MonitoringLogType.system,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      details: details,
    ));
  }

  // Query Methods
  List<MonitoringLog> getLogsByType(MonitoringLogType type) {
    return _logs.where((log) => log.type == type).toList();
  }

  List<MonitoringLog> getLogsByLevel(MonitoringLogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  List<MonitoringLog> getLogsInRange(DateTime start, DateTime end) {
    return _logs.where((log) => 
      log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
    ).toList();
  }

  List<MonitoringLog> getWarningsAndErrors() {
    return _logs.where((log) => 
      log.level == MonitoringLogLevel.warning || 
      log.level == MonitoringLogLevel.error
    ).toList();
  }

  // Clear Methods
  void clearLogs() {
    _logs.clear();
  }

  void clearLogsByType(MonitoringLogType type) {
    _logs.removeWhere((log) => log.type == type);
  }

  void clearOldLogs(Duration age) {
    final cutoff = DateTime.now().subtract(age);
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
  }
} 