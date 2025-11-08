import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class ReplayModeInfoScreen extends StatelessWidget {
  final VoidCallback onStart;

  const ReplayModeInfoScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Replay Mode'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flashcard-style header with icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.ctaSecondary,
                          AppColors.gradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientEnd.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Title and description
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Flashcard Style',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reveal and rate your recall',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Flashcard flip animation concept
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.ctaSecondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.flip_camera_android,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '1 Memory',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '~3 Questions',
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Steps in a vertical list style
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
                      const SizedBox(height: AppSpacing.md),
                      _buildStepCard(
                        number: 1,
                        icon: Icons.shuffle,
                        text: 'We randomly select a memory from your vault',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStepCard(
                        number: 2,
                        icon: Icons.visibility_outlined,
                        text: 'Try to recall the details before revealing',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStepCard(
                        number: 3,
                        icon: Icons.star_rate,
                        text: 'Reveal the answer and rate your recall accuracy',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildStepCard(
                        number: 4,
                        icon: Icons.trending_up,
                        text: 'Track your improvement over time',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Start button
                CustomButton(
                  text: 'Start Replay Mode',
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

  Widget _buildStepCard({
    required int number,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientMiddle.withOpacity(0.3),
            AppColors.gradientEnd.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gradientEnd.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.ctaPrimary,
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
          const SizedBox(width: AppSpacing.md),
          Icon(
            icon,
            color: AppColors.ctaSecondary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

