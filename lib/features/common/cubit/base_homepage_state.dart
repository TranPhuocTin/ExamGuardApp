import 'package:equatable/equatable.dart';
import '../models/exam.dart';

abstract class BaseHomepageState extends Equatable {
  const BaseHomepageState();

  @override
  List<Object> get props => [];
}

class HomepageInitial extends BaseHomepageState {
  final bool isLoading;

  const HomepageInitial({this.isLoading = false});

  @override
  List<Object> get props => [isLoading];
}

class HomepageLoading extends BaseHomepageState {
  final List<Exam> currentExams;
  final bool isFirstFetch;

  const HomepageLoading(this.currentExams, {this.isFirstFetch = false});

  @override
  List<Object> get props => [currentExams, isFirstFetch];
}

class HomepageRefreshing extends BaseHomepageState {
  final List<Exam> currentExams;

  const HomepageRefreshing(this.currentExams);

  @override
  List<Object> get props => [currentExams];
}

class HomepageLoaded extends BaseHomepageState {
  final List<Exam> exams;
  final bool hasReachedMax;
  final int currentPage;
  final bool isSearching;
  final String searchQuery;

  const HomepageLoaded(
    this.exams, {
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isSearching = false,
    this.searchQuery = '',
  });

  @override
  List<Object> get props =>
      [exams, hasReachedMax, currentPage, isSearching, searchQuery];

  HomepageLoaded copyWith({
    List<Exam>? exams,
    bool? hasReachedMax,
    int? currentPage,
    bool? isSearching,
    String? searchQuery,
  }) {
    return HomepageLoaded(
      exams ?? this.exams,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomepageError extends BaseHomepageState {
  final String message;

  const HomepageError(this.message);

  @override
  List<Object> get props => [message];
}
