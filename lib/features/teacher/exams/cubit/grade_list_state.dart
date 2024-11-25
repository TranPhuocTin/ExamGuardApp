import '../model/grade_list_response.dart';

abstract class GradeListState {}

class GradeListInitial extends GradeListState {}

class GradeListLoading extends GradeListState {
  final List<GradeDetail> currentGrades;
  final bool isFirstFetch;

  GradeListLoading(this.currentGrades, {this.isFirstFetch = false});
}

class GradeListLoaded extends GradeListState {
  final List<GradeDetail> grades;
  final bool hasReachedMax;
  final int currentPage;

  GradeListLoaded({
    required this.grades,
    required this.hasReachedMax,
    required this.currentPage,
  });

  GradeListLoaded copyWith({
    List<GradeDetail>? grades,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return GradeListLoaded(
      grades: grades ?? this.grades,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class GradeListError extends GradeListState {
  final String message;

  GradeListError(this.message);
} 