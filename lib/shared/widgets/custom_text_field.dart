import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Custom styled text field with character counter
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.text1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.subtext),
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.text2)
                : null,
            suffixIcon: suffixIcon,
            counterText: maxLength != null
                ? '${controller.text.length}/$maxLength'
                : null,
            counterStyle: TextStyle(color: AppColors.subtext),
          ),
        ),
      ],
    );
  }
}


