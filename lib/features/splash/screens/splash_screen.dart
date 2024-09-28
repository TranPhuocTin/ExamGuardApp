import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Chuyển sang màn hình chính sau vài giây
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1DB0A6), // Màu nền cho splash
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
