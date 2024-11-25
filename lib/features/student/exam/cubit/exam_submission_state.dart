abstract class ExamSubmissionState {}

class ExamSubmissionInitial extends ExamSubmissionState {}

class ExamSubmissionLoading extends ExamSubmissionState {}

class ExamSubmissionSuccess extends ExamSubmissionState {}

class ExamSubmissionFailure extends ExamSubmissionState {
  final String error;

  ExamSubmissionFailure(this.error);
} 