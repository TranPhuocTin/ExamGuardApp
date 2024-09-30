import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:exam_guardian/data/auth_repository.dart';
import 'package:exam_guardian/data/user_repository.dart';
import 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  AuthCubit()
      : super(AuthState(isLoading: false, isLoggedIn: false, isObscure: true));

  void obscurePassword() {
    emit(state.copyWith(isObscure: !state.isObscure));
  }

  Future<void> login(String username, String password) async {
    if (state.isLoading) return;

    emit(state.copyWith(
        isLoading: true, errorMessage: null, shouldShowError: false));
    try {
      final loginResponse = await _authRepository.login(username, password);
      emit(state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: loginResponse.metadata.user,
        tokens: loginResponse.metadata.tokens,
        shouldShowError: false,
      ));
      // final userResponse = await _userRepository.getUserList(loginResponse.metadata.user.id, 'STUDENT', 1, 5);
      // final findUserById = await _userRepository.findUserById(loginResponse.metadata.user.id, '66f67dda8ac04e1a9b553f94');
      // print(userResponse.metadata.users[1].name);
      // print('User information: ${findUserById.name}');
    } catch (error) {
      String errorMessage = 'An error occurred. Please try again.';
      if (error is DioException) {
        if (error.response?.statusCode == 401) {
          errorMessage = 'Username or password is incorrect. Please try again.';
        } else {
          errorMessage = 'Failed to login. Please check your credentials.';
        }
      }
      print(error);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isLoggedIn: false,
        shouldShowError: true,
      ));
    }
  }

  void logout() async {
    try{
      await _authRepository.logout();
      emit(
        AuthState(isLoading: false, isLoggedIn: false, isObscure: true),
      );
    }catch(e){
      Exception(e);
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null, shouldShowError: false));
  }

  void markErrorAsShown() {
    if (state.shouldShowError) {
      emit(state.copyWith(shouldShowError: false));
    }
  }
}
