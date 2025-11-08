import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography definitions for RememberWell app
class AppTextStyles {
  // Heading Styles
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.text1,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text1,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  // Body Styles
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.text1,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.subtext,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.subtext,
  );

  // Special Styles
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.subtext,
    letterSpacing: 1.5,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}
