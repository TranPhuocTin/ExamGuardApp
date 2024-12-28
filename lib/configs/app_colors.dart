import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1DB0A6);    // Giữ nguyên màu chủ đạo
  static const Color secondaryColor = Color(0xFF2B4865);  // Xanh dương đậm, chuyên nghiệp hơn
  static const Color accentColor = Color(0xFFFF9F29);     // Cam ấm áp thay vì cam nhạt
  static const Color logoColor = Color(0xFF007E7D);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);  // Xám nhạt ấm
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF1F5F9);  // Xám nhạt lạnh hơn
  
  // Text Colors
  static const Color textColor = Color(0xFFFFFFFF);       // Xanh đen, dễ đọc hơn
  static const Color textPrimary = Color(0xFF1E293B);    // Xanh đen, dễ đọc hơn
  static const Color textSecondary = Color(0xFF64748B);
  
  // Status Colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  
  // UI Elements
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  
  // Shadows
  static final BoxShadow cardShadow = BoxShadow(
    color: primaryColor.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1DB0A6),
      Color(0xFF0D9488),
    ],
  );

  static final LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2B4865).withOpacity(0.95),
      Color(0xFF1DB0A6).withOpacity(0.85),
    ],
    stops: [0.3, 1.0],
  );

  // Status Gradients
  static const LinearGradient scheduledGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3B82F6), // Xanh dương
      Color(0xFF0EA5E9), // Xanh biển
    ],
  );

  static const LinearGradient inProgressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF22C55E), // Xanh lá
      Color(0xFF10B981), // Xanh ngọc
    ],
  );

  static const LinearGradient completedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF64748B), // Xám
      Color(0xFF475569), // Xám đậm
    ],
  );
}
