import 'dart:async';
import 'package:exam_guardian/configs/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:exam_guardian/features/login/bloc/reset_password_cubit.dart';
import 'package:exam_guardian/features/login/bloc/reset_password_state.dart';
import 'package:exam_guardian/features/login/view/reset_password_view.dart';

import '../../../widgets/custom_text_field.dart';

class VerifyCodeView extends StatefulWidget {
  final String email;

  const VerifyCodeView({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _timeLeft = 60;
  Timer? _timer;
  Timer? _clipboardTimer;
  String _currentText = "";
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startListeningClipboard();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _clipboardTimer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startListeningClipboard() {
    _clipboardTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_disposed) {
        timer.cancel();
        return;
      }

      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData?.text != null) {
          final text = clipboardData!.text!;
          // Kiểm tra xem text có phải là OTP 6 số không
          if (text.length == 6 && RegExp(r'^\d{6}$').hasMatch(text)) {
            // Nếu OTP controller chưa có giá trị hoặc giá trị khác với clipboard
            if (!_disposed && _otpController.text != text) {
              setState(() {
                _otpController.text = text;
                _currentText = text;
              });
              // Tự động submit nếu đã nhập password
              if (!_disposed && _passwordController.text.isNotEmpty) {
                _handleSubmit();
              }
            }
          }
        }
      } catch (e) {
        // Ignore clipboard errors
      }
    });
  }

  void _handleResend() {
    if (_disposed) return;
    setState(() => _timeLeft = 60);
    _startTimer();
    context.read<ResetPasswordCubit>().sendResetLink(widget.email);
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context
          .read<ResetPasswordCubit>()
          .verifyCode(_otpController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is VerifyCodeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is VerifyCodeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Code'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'We have sent a verification code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.grey[100],
                          selectedFillColor: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Colors.grey[300],
                          selectedColor: Theme.of(context).primaryColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        errorAnimationController: null,
                        controller: _otpController,
                        onCompleted: (v) {
                          _handleSubmit();
                        },
                        onChanged: (value) {
                          setState(() {
                            _currentText = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          return true;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'New Password',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                      builder: (context, state) {
                        return CustomButton(
                          onPressed:
                              state is VerifyCodeLoading ? null : _handleSubmit,
                          child: state is VerifyCodeLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Verify', style: TextStyle(color: Colors.white),),
                          backgroundColor: AppColors.primaryColor,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive code? "),
                        TextButton(
                          onPressed: _timeLeft == 0 ? _handleResend : null,
                          child: Text(
                            _timeLeft > 0
                                ? 'Resend in ${_timeLeft}s'
                                : 'Resend Code',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
