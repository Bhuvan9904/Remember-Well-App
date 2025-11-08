import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class BattleModeInfoScreen extends StatelessWidget {
  final VoidCallback onStart;

  const BattleModeInfoScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Battle Mode'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Battle Header - Energetic design
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error,
                              AppColors.ctaSecondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compare_arrows,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Speed Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Test your recall speed!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Timer and Questions - Battle style
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.error.withOpacity(0.3),
                              AppColors.error.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '⏱️ Timer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '60 or 120 sec',
                              style: const TextStyle(
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.ctaSecondary.withOpacity(0.3),
                              AppColors.ctaSecondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.ctaSecondary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '∞',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Questions',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'As many as you can',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // How It Works - Battle challenge style
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CHALLENGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildChallengeStep(
                        icon: Icons.timer_outlined,
                        text: 'Choose your challenge duration (60 or 120 seconds)',
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildChallengeStep(
                        icon: Icons.speed,
                        text: 'Answer questions as quickly as possible',
                        color: AppColors.ctaSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildChallengeStep(
                        icon: Icons.check_circle,
                        text: 'See how many questions you can answer correctly',
                        color: AppColors.ctaPrimary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildChallengeStep(
                        icon: Icons.emoji_events,
                        text: 'Beat your high score and improve your speed',
                        color: AppColors.ctaSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Start button - Battle style
                CustomButton(
                  text: 'Start Battle Mode',
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

  Widget _buildChallengeStep({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
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

