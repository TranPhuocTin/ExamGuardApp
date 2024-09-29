import 'package:equatable/equatable.dart';
import '../models/user_response.dart';

class UserState extends Equatable {
  final List<User> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;
  final bool isSearching;
  final String? searchQuery;

  const UserState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
    this.isSearching = false,
    this.searchQuery,
  });

  UserState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    bool? isSearching,
    String? searchQuery,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [users, isLoading, isLoadingMore, error, currentPage, totalPages, hasReachedMax, isSearching, searchQuery];
}