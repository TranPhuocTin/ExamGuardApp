import 'package:equatable/equatable.dart';
import '../models/completed_grade_response.dart';

enum CompletedGradeStatus { initial, loading, success, failure }

class CompletedGradeState extends Equatable {
  final CompletedGradeStatus status;
  final List<CompletedGrade> grades;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;

  const CompletedGradeState({
    this.status = CompletedGradeStatus.initial,
    this.grades = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  CompletedGradeState copyWith({
    CompletedGradeStatus? status,
    List<CompletedGrade>? grades,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
  }) {
    return CompletedGradeState(
      status: status ?? this.status,
      grades: grades ?? this.grades,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        grades,
        errorMessage,
        hasReachedMax,
        currentPage,
        totalPages,
      ];
} 