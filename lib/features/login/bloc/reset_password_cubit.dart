import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/features/login/bloc/reset_password_state.dart';

import '../../../data/auth_repository.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  String? _email;
  String? _code;

  ResetPasswordCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(ResetPasswordInitial());

  Future<void> sendResetLink(String email) async {
    try {
      emit(SendResetLinkLoading());
      await _authRepository.forgotPassword(email);
      _email = email;
      emit(SendResetLinkSuccess());
    } catch (e) {
      emit(SendResetLinkError(e.toString()));
    }
  }

  Future<void> verifyCode(String code, String newPassword) async {
    if (_email == null) {
      emit(const VerifyCodeError('Email not found'));
      return;
    }

    try {
      emit(VerifyCodeLoading());
      await _authRepository.resetPassword(_email!, code, newPassword);
      _code = code;
      emit(VerifyCodeSuccess());
    } catch (e) {
      emit(VerifyCodeError(e.toString()));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (_email == null || _code == null) {
      emit(const ResetPasswordError('Invalid state'));
      return;
    }

    try {
      emit(ResetPasswordLoading());
      await _authRepository.resetPassword(_email!, _code!, newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }

  void reset() {
    _email = null;
    _code = null;
    emit(ResetPasswordInitial());
  }
} 