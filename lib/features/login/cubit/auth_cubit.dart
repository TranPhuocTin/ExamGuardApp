import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:exam_guardian/data/auth_repository.dart';
import 'package:exam_guardian/features/login/models/login_response.dart';
import '../../../utils/share_preference/shared_preference.dart';
import 'auth_state.dart';
import 'package:exam_guardian/features/realtime/cubit/realtime_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository = AuthRepository();
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
      print('user: ${loginResponse.metadata.user}');
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
      // emit(state.copyWith(
      //   isLoading: false,
      //   errorMessage: errorMessage,
      //   isLoggedIn: false,
      //   shouldShowError: true,
      // ));
    }
  }

  Future<void> loadUserInfo() async {
    TokenStorage tokenStorage = TokenStorage();
    final userFromTokenStorage = await tokenStorage.getUser();
    if (userFromTokenStorage != null) {
      User user = User.fromJson(userFromTokenStorage);
      emit(state.copyWith(
        user: user,
      ));
      print('Loaded user: ${user.name}');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      //Hiện tại phương thức close đang làm rốt loạn state của ứng dụng
      // await context.read<RealtimeCubit>().close();
      context.read<RealtimeCubit>().cleanupSocket();
      await _authRepository.logout();
      
      emit(AuthState(isLoading: false, isLoggedIn: false, isObscure: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        shouldShowError: true,
      ));
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
