import 'package:equatable/equatable.dart';

abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object?> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordError extends ResetPasswordState {
  final String message;

  const ResetPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}

// Send Reset Link States
class SendResetLinkLoading extends ResetPasswordState {}

class SendResetLinkSuccess extends ResetPasswordState {}

class SendResetLinkError extends ResetPasswordState {
  final String message;

  const SendResetLinkError(this.message);

  @override
  List<Object?> get props => [message];
}

// Verify Code States
class VerifyCodeLoading extends ResetPasswordState {}

class VerifyCodeSuccess extends ResetPasswordState {}

class VerifyCodeError extends ResetPasswordState {
  final String message;

  const VerifyCodeError(this.message);

  @override
  List<Object?> get props => [message];
}