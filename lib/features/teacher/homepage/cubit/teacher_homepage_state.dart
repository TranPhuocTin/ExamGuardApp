import 'package:equatable/equatable.dart';

import '../../models/exam.dart';

abstract class TeacherHomepageState extends Equatable {
  const TeacherHomepageState();

  @override
  List<Object> get props => [];
}

class TeacherHomepageInitial extends TeacherHomepageState {
 final bool isLoading;

  const TeacherHomepageInitial({this.isLoading = false});

  @override
  List<Object> get props => [isLoading];
}

class TeacherHomepageLoading extends TeacherHomepageState {
  final List<Exam> currentExams;
  final bool isFirstFetch;

  const TeacherHomepageLoading(this.currentExams, {this.isFirstFetch = false});

  @override
  List<Object> get props => [currentExams, isFirstFetch];
}

class TeacherHomepageRefreshing extends TeacherHomepageState {
  final List<Exam> currentExams;

  const TeacherHomepageRefreshing(this.currentExams);

  @override
  List<Object> get props => [currentExams];
}

class TeacherHomepageLoaded extends TeacherHomepageState {
  final List<Exam> exams;
  final bool hasReachedMax;
  final int currentPage;

  const TeacherHomepageLoaded(this.exams, {this.hasReachedMax = false, this.currentPage = 1});

  @override
  List<Object> get props => [exams, hasReachedMax, currentPage];

  TeacherHomepageLoaded copyWith({
    List<Exam>? exams,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return TeacherHomepageLoaded(
      exams ?? this.exams,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class TeacherHomepageError extends TeacherHomepageState {
  final String message;

  const TeacherHomepageError(this.message);

  @override
  List<Object> get props => [message];
}
