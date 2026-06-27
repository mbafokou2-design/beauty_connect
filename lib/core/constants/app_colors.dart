import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color darkBordeaux = Color(0xFF240420);
  static const Color pinkRose = Color(0xFFB90C55);
  
  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFDF8F5);
  
  // Text
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF888888);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBordeaux, pinkRose],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBordeaux, pinkRose],
  );
}