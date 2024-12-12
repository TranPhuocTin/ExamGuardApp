enum CheatingBehavior {
  normal,
  noFaceDetected,
  multipleFaces,
  lookingLeft,
  lookingRight,
  spoofing,
  pipMode,
  switchTab,
  error,
  appBackground,
  appMinimized
}

class CheatingDetectionState {
  final CheatingBehavior behavior;
  final String message;
  final DateTime timestamp;

  CheatingDetectionState({
    required this.behavior,
    required this.message,
    required this.timestamp,
  });
} 