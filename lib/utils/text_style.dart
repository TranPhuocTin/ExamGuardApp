import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  static const String _fontFamily = 'Lexend';

  // Colors
  static const Color borderColor = Color(0xFFC4C4C4);

  // Heading styles
  static TextStyle h1 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle h2 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  static TextStyle h3 = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  // Body text styles
  static TextStyle bodyLarge = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Button text style
  static TextStyle button = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Caption text style
  static TextStyle caption = GoogleFonts.getFont(
    _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  // Helper method to apply color to any style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}