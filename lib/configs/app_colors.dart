import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF1DB0A6);
  static const Color secondaryColor = Color(0xFF2A2D3E);
  static const Color accentColor = Color(0xFFFFA726);
  
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  
  static const Color textPrimary = Color(0xFF2A2D3E);
  static const Color textSecondary = Color(0xFF6C7293);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Thêm các màu gradient nếu cần
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1DB0A6), Color(0xFF14D2B8)],
  );
}
