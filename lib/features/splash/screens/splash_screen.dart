import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/utils/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Tạo hàm bất đồng bộ để điều hướng sau khi kiểm tra token
  Future<void> _navigateToNextScreen() async {
    // Chờ trong 3 giây
    await Future.delayed(const Duration(seconds: 3));

    // Kiểm tra token từ TokenCubit
    await context.read<TokenCubit>().loadTokens();
    await context.read<AuthCubit>().loadUserInfo();

    if (context.read<TokenCubit>().state.accessToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if(context.read<TokenCubit>().state.cliendRole == 'ADMIN') {
      Navigator.pushReplacementNamed(context, '/admin_main_screen');
    } else if(context.read<TokenCubit>().state.cliendRole == 'TEACHER'){
      Navigator.pushReplacementNamed(context, '/teacher_homepage');
    } else if(context.read<TokenCubit>().state.cliendRole == 'STUDENT'){
      print('student login');
      Navigator.pushReplacementNamed(context, '/student_homepage');
    } else print('Role null');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1DB0A6), // Màu nền cho splash
      body: Center(
        child: Image.asset(
          'assets/icons/splash_icon.png',
          width: 200, // Thiết lập kích thước logo
          height: 200,
        ),
      ),
    );
  }
}

