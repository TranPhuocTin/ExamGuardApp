class ExamAlreadyTakenException implements Exception {
  final String message;
  ExamAlreadyTakenException([this.message = 'You already completed this exam']);

  @override
  String toString() => message;
} 