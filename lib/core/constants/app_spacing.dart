import 'package:flutter/material.dart';

/// Spacing system for RememberWell app
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Private constructor to prevent instantiation
  AppSpacing._();
}

/// Helper widgets for spacing
class Spacing {
  static Widget xxsmall() => SizedBox(height: AppSpacing.xxs, width: AppSpacing.xxs);
  static Widget xsmall() => SizedBox(height: AppSpacing.xs, width: AppSpacing.xs);
  static Widget small() => SizedBox(height: AppSpacing.sm, width: AppSpacing.sm);
  static Widget medium() => SizedBox(height: AppSpacing.md, width: AppSpacing.md);
  static Widget large() => SizedBox(height: AppSpacing.lg, width: AppSpacing.lg);
  static Widget xlarge() => SizedBox(height: AppSpacing.xl, width: AppSpacing.xl);
  static Widget xxlarge() => SizedBox(height: AppSpacing.xxl, width: AppSpacing.xxl);
  
  // Height only
  static Widget heightXXS() => SizedBox(height: AppSpacing.xxs);
  static Widget heightXS() => SizedBox(height: AppSpacing.xs);
  static Widget heightSM() => SizedBox(height: AppSpacing.sm);
  static Widget heightMD() => SizedBox(height: AppSpacing.md);
  static Widget heightLG() => SizedBox(height: AppSpacing.lg);
  static Widget heightXL() => SizedBox(height: AppSpacing.xl);
  static Widget heightXXL() => SizedBox(height: AppSpacing.xxl);
  
  // Width only
  static Widget widthXXS() => SizedBox(width: AppSpacing.xxs);
  static Widget widthXS() => SizedBox(width: AppSpacing.xs);
  static Widget widthSM() => SizedBox(width: AppSpacing.sm);
  static Widget widthMD() => SizedBox(width: AppSpacing.md);
  static Widget widthLG() => SizedBox(width: AppSpacing.lg);
  static Widget widthXL() => SizedBox(width: AppSpacing.xl);
  static Widget widthXXL() => SizedBox(width: AppSpacing.xxl);
}
