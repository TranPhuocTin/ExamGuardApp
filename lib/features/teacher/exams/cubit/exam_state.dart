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
  final int currentPage;
  final String selectedStatus;
  final String searchQuery;

  const ExamLoaded(
    this.exams, {
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.selectedStatus = 'All',
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [exams, hasReachedMax, currentPage, selectedStatus, searchQuery];

  ExamLoaded copyWith({
    List<Exam>? exams,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return ExamLoaded(
      exams ?? this.exams,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object> get props => [message];
}

class ExamUpdate extends ExamState{
  final bool isSuccess;
  const ExamUpdate(this.isSuccess);

  ExamUpdate copyWith({
    bool? isSuccess,
  }) {
    return ExamUpdate(isSuccess ?? this.isSuccess);
  }
}

