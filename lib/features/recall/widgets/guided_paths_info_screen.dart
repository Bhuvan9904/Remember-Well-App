import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class GuidedPathsInfoScreen extends StatelessWidget {
  final VoidCallback onStart;

  const GuidedPathsInfoScreen({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guided Paths'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Path Header - Journey style
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gradientStart.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Focused Training',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Strengthen your recall in targeted areas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Path Options - Grid style
                Row(
                  children: [
                    Expanded(
                      child: _buildPathCard(
                        icon: Icons.people,
                        label: '3 Paths',
                        color: AppColors.gradientStart,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildPathCard(
                        icon: Icons.memory,
                        label: '~5 Memories',
                        color: AppColors.gradientEnd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Description
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.gradientStart,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'About Guided Paths',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Focus on specific types of memories: People, Places, or Sensory details. Strengthen your recall in targeted areas.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Steps - Path style with icons
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPathStep(
                        icon: Icons.radio_button_checked,
                        text: 'Choose your focus: People, Places, or Sensory',
                        color: AppColors.gradientStart,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathConnector(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathStep(
                        icon: Icons.book,
                        text: 'Practice recalling memories in that category',
                        color: AppColors.gradientMiddle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathConnector(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathStep(
                        icon: Icons.quiz,
                        text: 'Answer questions specific to your chosen path',
                        color: AppColors.gradientEnd,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathConnector(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPathStep(
                        icon: Icons.insights,
                        text: 'Track your progress in each memory type',
                        color: AppColors.ctaPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Start button
                CustomButton(
                  text: 'Start Guided Paths',
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

  Widget _buildPathCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathStep({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
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
    );
  }

  Widget _buildPathConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        width: 2,
        height: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStart.withOpacity(0.5),
              AppColors.gradientEnd.withOpacity(0.5),
            ],
          ),
        ),
      ),
    );
  }
}

