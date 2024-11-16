import 'package:equatable/equatable.dart';
import '../../../common/models/question_response.dart';
import '../models/student_exam_response.dart';

abstract class StudentExamState extends Equatable {
  const StudentExamState();

  @override
  List<Object?> get props => [];
}

class StudentExamInitial extends StudentExamState {}

class StudentExamLoading extends StudentExamState {}

class StudentExamLoaded extends StudentExamState {
  final List<Question> questions;
  final RemainingTime remainingTime;
  final Map<String, String> answers;
  final bool hasReachedMax;
  final bool isLoading;

  const StudentExamLoaded({
    required this.questions,
    required this.remainingTime,
    this.answers = const {},
    this.hasReachedMax = false,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [questions, remainingTime, answers, hasReachedMax, isLoading];

  StudentExamLoaded copyWith({
    List<Question>? questions,
    RemainingTime? remainingTime,
    Map<String, String>? answers,
    bool? hasReachedMax,
    bool? isLoading,
  }) {
    return StudentExamLoaded(
      questions: questions ?? this.questions,
      remainingTime: remainingTime ?? this.remainingTime,
      answers: answers ?? this.answers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StudentExamError extends StudentExamState {
  final String message;

  const StudentExamError(this.message);

  @override
  List<Object> get props => [message];
}

class StudentExamSubmitted extends StudentExamState {} 