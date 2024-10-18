import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/features/teacher/models/exam.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';

// State
abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {
  final List<Exam> currentExams;
  final bool isFirstFetch;

  const ExamLoading(this.currentExams, {this.isFirstFetch = false});

  @override
  List<Object> get props => [currentExams, isFirstFetch];
}

class ExamRefreshing extends ExamState {
  final List<Exam> currentExams;

  const ExamRefreshing(this.currentExams);

  @override
  List<Object> get props => [currentExams];
}

class ExamLoaded extends ExamState {
  final List<Exam> exams;
  final bool hasReachedMax;

  const ExamLoaded(this.exams, {this.hasReachedMax = false});

  @override
  List<Object> get props => [exams, hasReachedMax];

  ExamLoaded copyWith({
    List<Exam>? exams,
    bool? hasReachedMax,
  }) {
    return ExamLoaded(
      exams ?? this.exams,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object> get props => [message];
}
