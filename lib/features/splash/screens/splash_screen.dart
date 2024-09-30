import 'package:exam_guardian/features/login/cubit/AuthCubit.dart';
import 'package:exam_guardian/features/login/cubit/AuthState.dart';
import 'package:exam_guardian/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/features/admin/view/admin_homepage_view.dart';

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
    final token = context.read<TokenCubit>().state.accessToken;

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/admin_main_screen');
    }
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

