import 'package:equatable/equatable.dart';
import '../model/cheating_statistics_response.dart';
import '../model/student_answer_response.dart';


abstract class StudentAnswerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentAnswerInitial extends StudentAnswerState {}

class StudentAnswerLoading extends StudentAnswerState {
  final List<StudentAnswer> currentAnswers;
  final bool isFirstFetch;

  StudentAnswerLoading(this.currentAnswers, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [currentAnswers, isFirstFetch];
}

class StudentAnswerLoaded extends StudentAnswerState {
  final List<StudentAnswer> answers;
  final bool hasReachedMax;
  final Student student;
  final int total;
  final int currentPage;

  StudentAnswerLoaded({
    required this.answers,
    required this.hasReachedMax,
    required this.student,
    required this.total,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [answers, hasReachedMax, student, total, currentPage];

  StudentAnswerLoaded copyWith({
    List<StudentAnswer>? answers,
    bool? hasReachedMax,
    Student? student,
    int? total,
    int? currentPage,
  }) {
    return StudentAnswerLoaded(
      answers: answers ?? this.answers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      student: student ?? this.student,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class StudentAnswerError extends StudentAnswerState {
  final String message;

  StudentAnswerError(this.message);

  @override
  List<Object> get props => [message];
} 