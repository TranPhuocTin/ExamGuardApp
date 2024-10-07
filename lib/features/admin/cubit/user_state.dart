  import 'package:equatable/equatable.dart';
  import '../models/user_response.dart';

  class UserState extends Equatable {
    final List<User> teachers;
    final List<User> students;
    final bool isLoadingTeachers;
    final bool isLoadingStudents;
    final bool isLoadingMoreTeachers;
    final bool isLoadingMoreStudents;
    final String? errorTeachers;
    final String? errorStudents;
    final int currentPageTeachers;
    final int currentPageStudents;
    final int totalPagesTeachers;
    final int totalPagesStudents;
    final bool hasReachedMaxTeachers;
    final bool hasReachedMaxStudents;
    final bool isSearching;
    final bool isEditing;
    final String? searchQuery;
    final bool deleteSuccess;
    final bool updateSuccess;
    final bool isRefreshing;

    const UserState({
      this.teachers = const [],
      this.students = const [],
      this.isLoadingTeachers = false,
      this.isLoadingStudents = false,
      this.isLoadingMoreTeachers = false,
      this.isLoadingMoreStudents = false,
      this.errorTeachers,
      this.errorStudents,
      this.currentPageTeachers = 1,
      this.currentPageStudents = 1,
      this.totalPagesTeachers = 1,
      this.totalPagesStudents = 1,
      this.hasReachedMaxTeachers = false,
      this.hasReachedMaxStudents = false,
      this.isSearching = false,
      this.isEditing = false,
      this.searchQuery,
      this.deleteSuccess = false,
      this.updateSuccess = false,
      this.isRefreshing = false,
    });

    UserState copyWith({
      List<User>? teachers,
      List<User>? students,
      bool? isLoadingTeachers,
      bool? isLoadingStudents,
      bool? isLoadingMoreTeachers,
      bool? isLoadingMoreStudents,
      String? errorTeachers,
      String? errorStudents,
      int? currentPageTeachers,
      int? currentPageStudents,
      int? totalPagesTeachers,
      int? totalPagesStudents,
      bool? hasReachedMaxTeachers,
      bool? hasReachedMaxStudents,
      bool? isSearching,
      bool? isEditing,
      String? searchQuery,
      bool? deleteSuccess,
      bool? updateSuccess,
      bool? isRefreshing
    }) {
      return UserState(
        teachers: teachers ?? this.teachers,
        students: students ?? this.students,
        isLoadingTeachers: isLoadingTeachers ?? this.isLoadingTeachers,
        isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
        isLoadingMoreTeachers: isLoadingMoreTeachers ?? this.isLoadingMoreTeachers,
        isLoadingMoreStudents: isLoadingMoreStudents ?? this.isLoadingMoreStudents,
        errorTeachers: errorTeachers ?? this.errorTeachers,
        errorStudents: errorStudents ?? this.errorStudents,
        currentPageTeachers: currentPageTeachers ?? this.currentPageTeachers,
        currentPageStudents: currentPageStudents ?? this.currentPageStudents,
        totalPagesTeachers: totalPagesTeachers ?? this.totalPagesTeachers,
        totalPagesStudents: totalPagesStudents ?? this.totalPagesStudents,
        hasReachedMaxTeachers: hasReachedMaxTeachers ?? this.hasReachedMaxTeachers,
        hasReachedMaxStudents: hasReachedMaxStudents ?? this.hasReachedMaxStudents,
        isSearching: isSearching ?? this.isSearching,
        isEditing: isEditing ?? this.isEditing,
        searchQuery: searchQuery ?? this.searchQuery,
        deleteSuccess: deleteSuccess ?? this.deleteSuccess,
        updateSuccess: updateSuccess ?? this.updateSuccess,
        isRefreshing: isRefreshing ?? this.isRefreshing
      );
    }

    @override
    List<Object?> get props => [
      teachers,
      students,
      isLoadingTeachers,
      isLoadingStudents,
      isLoadingMoreTeachers,
      isLoadingMoreStudents,
      errorTeachers,
      errorStudents,
      currentPageTeachers,
      currentPageStudents,
      totalPagesTeachers,
      totalPagesStudents,
      hasReachedMaxTeachers,
      hasReachedMaxStudents,
      isSearching,
      isEditing,
      searchQuery,
      deleteSuccess,
      updateSuccess,
      isRefreshing
    ];
  }