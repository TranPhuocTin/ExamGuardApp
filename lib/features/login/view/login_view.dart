import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/cubit/auth_state.dart';
import 'package:exam_guardian/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/utils/text_style.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
      previous.isLoggedIn != current.isLoggedIn ||
          previous.shouldShowError != current.shouldShowError,
      listener: (context, state) {
        if (state.isLoggedIn && state.user?.role == "ADMIN") {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushReplacementNamed(context, '/admin_main_screen');
        }
        else if(state.user?.role == "TEACHER"){
          Navigator.pushReplacementNamed(context, '/teacher_homepage');
        }
        else if(state.user?.role == "STUDENT"){
          Navigator.pushReplacementNamed(context, '/student_homepage');
        }
        else if (state.shouldShowError && state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
          context.read<AuthCubit>().markErrorAsShown();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyles.h1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  TextField(
                    controller: _usernameController,
                    style: TextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyles.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: Color(0xFF1DB0A6)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: state.isObscure,
                    style: TextStyles.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyles.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: TextStyles.borderColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: Color(0xFF1DB0A6)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          state.isObscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        onPressed: () => context.read<AuthCubit>().obscurePassword(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyles.withColor(
                            TextStyles.bodySmall, AppColors.primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                      if (_usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        context.read<AuthCubit>().login(
                            _usernameController.text, _passwordController.text);
                      } else {
                        showErrorSnackBar(
                            context, 'Username or password is invalid');
                      }
                    },
                    child: state.isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                        : Text(
                      'NEXT',
                      style: TextStyles.button.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have a question? ', style: TextStyles.bodySmall),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Send feedback',
                          style: TextStyles.withColor(
                              TextStyles.bodySmall, Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}