import 'package:equatable/equatable.dart';
import '../models/user_response.dart';

class UserState extends Equatable {
  final List<User> users;
  final bool isLoading;
  final bool hasReachedMax;
  final String? error;

  const UserState({
    this.users = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.error,
  });

  UserState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? hasReachedMax,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [users, isLoading, hasReachedMax, error];
}