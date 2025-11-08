import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class RandomRecallInfoScreen extends StatelessWidget {
  final VoidCallback onStart;

  const RandomRecallInfoScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Random Recall'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surprise Quiz Card - Large and prominent
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Shuffle icon with animation concept
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientMiddle,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gradientEnd.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shuffle,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Surprise Quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll randomly select 5 memories from your vault. Can you recall the details without knowing which ones are coming?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Quiz Details - Side by side with large numbers
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        style: AppCardStyle.lavender,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            const Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Random Memories',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppCard(
                        style: AppCardStyle.lavender,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            const Text(
                              '~10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Questions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // How It Works - Horizontal timeline style
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How It Works',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTimelineStep(
                        number: 1,
                        text: 'We randomly select 5 memories from your vault',
                        isFirst: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildTimelineStep(
                        number: 2,
                        text: 'Answer questions about each memory\'s details',
                        isFirst: false,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildTimelineStep(
                        number: 3,
                        text: 'See your score and improve your recall skills',
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Start button
                CustomButton(
                  text: 'Start Random Recall',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStart();
                  },
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int number,
    required String text,
    required bool isFirst,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: AppColors.ctaPrimary.withOpacity(0.5),
              ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.ctaPrimary,
                    AppColors.ctaSecondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: AppColors.ctaPrimary.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

