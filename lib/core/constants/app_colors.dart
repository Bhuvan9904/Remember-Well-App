import 'package:flutter/material.dart';

/// Color palette for RememberWell app
class AppColors {
  // Text Colors
  static const mainHeading = Color(0xFF161824);
  static const text1 = Colors.white; // White for main text
  static const text2 = Color(0xCCFFFFFF); // White with 80% opacity - improved for better visibility
  static const subtext = Colors.white70; // Muted purple for supporting text

  // Background Gradient Colors
  static const gradientStart = Color(0xFF3B86E3); // Top blue
  static const gradientMiddle = Color(0xFFE7ACCC); // Soft pink transition
  static const gradientAccent = Color(0xFFDA82D2); // Midway lavender
  static const gradientEnd = Color(0xFFBD27E0); // Bottom purple

  // Background Secondary
  static const background2 = Color(0xFFE4B2EA); // Solid lavender card background
  static const accentSurface = Color(0xFFD4A5C7); // Accent pill / badge background

  // CTA Colors
  static const ctaPrimary = Color(0xFF6FD373); // Green
  static const ctaSecondary = Color(0xFFFFBF2B); // Orange

  // Highlight Card
  static const highlightCard = Color(0xFF4A90E2); // Vibrant blue

  // Additional utility colors
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF6FD373);
  static const warning = Color(0xFFFFBF2B);

  // Private constructor to prevent instantiation
  AppColors._();
}

/// Helper to get the gradient for backgrounds
LinearGradient get appGradient => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.gradientStart,
        AppColors.gradientMiddle,
        AppColors.gradientAccent,
        AppColors.gradientEnd,
      ],
    );


