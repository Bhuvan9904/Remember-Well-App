import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart' show Spacing;
import '../../../../core/constants/app_colors.dart';

class IntroSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;

  const IntroSlide({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            icon,
            style: const TextStyle(fontSize: 80),
          ),
          Spacing.heightLG(),
          Text(
            title,
            style: AppTextStyles.largeTitle,
            textAlign: TextAlign.center,
          ),
          Spacing.heightMD(),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.subtext),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
