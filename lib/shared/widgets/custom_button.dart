import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

enum ButtonType { primary, secondary, tertiary }

/// Custom styled button following the app's design system
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isExpanded;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isExpanded = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonBackgroundColor;
    Color buttonTextColor;
    
    // Use provided colors if available, otherwise use type-based colors
    if (backgroundColor != null && textColor != null) {
      buttonBackgroundColor = backgroundColor!;
      buttonTextColor = textColor!;
    } else {
      switch (type) {
        case ButtonType.primary:
          buttonBackgroundColor = AppColors.ctaPrimary;
          buttonTextColor = AppColors.text1;
          break;
        case ButtonType.secondary:
          buttonBackgroundColor = AppColors.ctaSecondary;
          buttonTextColor = AppColors.text1;
          break;
        case ButtonType.tertiary:
          buttonBackgroundColor = Colors.transparent;
          buttonTextColor = AppColors.ctaPrimary;
          break;
      }
    }

    Widget child = Container(
      width: isExpanded ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: buttonBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: type == ButtonType.tertiary
            ? Border.all(color: AppColors.ctaPrimary, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, color: buttonTextColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            text,
            style: TextStyle(
              color: buttonTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1.0,
        child: child,
      ),
    );
  }
}


