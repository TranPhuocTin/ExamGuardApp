import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/features/login/view/login_view.dart';
import 'package:exam_guardian/features/login/cubit/AuthCubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: LoginView(),
    );
  }
}
