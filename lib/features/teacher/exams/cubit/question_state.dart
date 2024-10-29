import 'package:equatable/equatable.dart';
import '../../../common/models/question_response.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoading extends QuestionState {
  final List<Question> currentQuestions;
  final bool isFirstFetch;

  const QuestionLoading(this.currentQuestions, {this.isFirstFetch = false});

  @override
  List<Object> get props => [currentQuestions, isFirstFetch];
}

class QuestionLoaded extends QuestionState {
  final List<Question> questions;
  final bool hasReachedMax;
  final int currentPage;
  final String examId;

  const QuestionLoaded(
    this.questions, {
    this.hasReachedMax = false,
    this.currentPage = 1,
    required this.examId,
  });

  @override
  List<Object> get props => [questions, hasReachedMax, currentPage, examId];

  QuestionLoaded copyWith({
    List<Question>? questions,
    bool? hasReachedMax,
    int? currentPage,
    String? examId,
  }) {
    return QuestionLoaded(
      questions ?? this.questions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      examId: examId ?? this.examId,
    );
  }
}



class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);

  @override
  List<Object> get props => [message];
}

// Add this class to your existing states
class QuestionCreated extends QuestionState {
  final Question question;

  const QuestionCreated(this.question);

  @override
  List<Object> get props => [question];
}

class QuestionUpdated extends QuestionState {}
