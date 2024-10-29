// import 'package:equatable/equatable.dart';
//
// import '../../../common/models/exam.dart';
//
// abstract class TeacherHomepageState extends Equatable {
//   const TeacherHomepageState();
//
//   @override
//   List<Object> get props => [];
// }
//
// class TeacherHomepageInitial extends TeacherHomepageState {
//   final bool isLoading;
//
//   const TeacherHomepageInitial({this.isLoading = false});
//
//   @override
//   List<Object> get props => [isLoading];
// }
//
// class TeacherHomepageLoading extends TeacherHomepageState {
//   final List<Exam> currentExams;
//
//   TeacherHomepageLoading(this.currentExams);
//
//   @override
//   List<Object> get props => [currentExams];
// }
//
// class TeacherHomepageRefreshing extends TeacherHomepageState {
//   final List<Exam> currentExams;
//
//   const TeacherHomepageRefreshing(this.currentExams);
//
//   @override
//   List<Object> get props => [currentExams];
// }
//
// class TeacherHomepageLoaded extends TeacherHomepageState {
//   final List<Exam> exams;
//   final bool hasReachedMax;
//   final int currentPage;
//   final bool isSearching;
//   final String searchQuery;
//
//   const TeacherHomepageLoaded(
//     this.exams, {
//     this.hasReachedMax = false,
//     this.currentPage = 1,
//     this.isSearching = false,
//     this.searchQuery = '',
//   });
//
//   @override
//   List<Object> get props =>
//       [exams, hasReachedMax, currentPage, isSearching, searchQuery];
//
//   TeacherHomepageLoaded copyWith({
//     List<Exam>? exams,
//     bool? hasReachedMax,
//     int? currentPage,
//     bool? isSearching,
//     String? searchQuery,
//   }) {
//     return TeacherHomepageLoaded(
//       exams ?? this.exams,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//       currentPage: currentPage ?? this.currentPage,
//       isSearching: isSearching ?? this.isSearching,
//       searchQuery: searchQuery ?? this.searchQuery,
//     );
//   }
// }
//
// class TeacherHomepageError extends TeacherHomepageState {
//   final String message;
//
//   const TeacherHomepageError(this.message);
//
//   @override
//   List<Object> get props => [message];
// }
