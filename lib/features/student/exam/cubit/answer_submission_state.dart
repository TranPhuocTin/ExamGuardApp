abstract class AnswerSubmissionState {
  const AnswerSubmissionState();
}

class AnswerSubmissionInitial extends AnswerSubmissionState {}

class AnswerSubmissionLoading extends AnswerSubmissionState {
  final String questionId;

  AnswerSubmissionLoading({required this.questionId});
}

class AnswerSubmissionSuccess extends AnswerSubmissionState {
  final String questionId;
  final String answer;

  AnswerSubmissionSuccess({
    required this.questionId,
    required this.answer,
  });
}

class AnswerSubmissionFailure extends AnswerSubmissionState {
  final String questionId;
  final String error;

  AnswerSubmissionFailure({
    required this.questionId,
    required this.error,
  });
} 