import '../models/login_response.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final bool isObscure;
  final String? errorMessage;
  final User? user;
  final Tokens? tokens;
  final bool shouldShowError; // New field

  AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    required this.isObscure,
    this.errorMessage,
    this.user,
    this.tokens,
    this.shouldShowError = false, // Initialize with false
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    bool? isObscure,
    String? errorMessage,
    User? user,
    Tokens? tokens,
    bool? shouldShowError,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isObscure: isObscure ?? this.isObscure,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      shouldShowError: shouldShowError ?? this.shouldShowError,
    );
  }
}
