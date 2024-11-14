enum CheatingBehavior {
  normal,
  noFaceDetected,
  multipleFaces,
  lookingLeft,
  lookingRight,
  spoofing,
  pipMode,
  error
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