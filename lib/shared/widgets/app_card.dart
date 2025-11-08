import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

enum AppCardStyle {
  bluePurple, // 1st image: 0% #4D6FFF -> 100% #6B47DC
  lavender, // Updated to solid #5E465F for primary card fill
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardStyle style;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.style = AppCardStyle.lavender,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration(style, borderRadius);

    final content = Container(
      decoration: decoration,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }

  BoxDecoration _buildDecoration(AppCardStyle style, double radius) {
    switch (style) {
      case AppCardStyle.bluePurple:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4D6FFF),
              Color(0xFF6B47DC),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        );
      case AppCardStyle.lavender:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0x665E465F),
              Color(0x665E465F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        );
    }
  }
}


