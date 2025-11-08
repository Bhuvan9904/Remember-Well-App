import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class RecallModeInfoScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final List<String> steps;
  final Map<String, String>? details; // e.g., {"5": "Random Memories", "~10": "Questions"}
  final VoidCallback onStart;

  const RecallModeInfoScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.steps,
    this.details,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    print('DEBUG: RecallModeInfoScreen - build() called for: $title');
    
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Card
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientEnd.withOpacity(0.3),
                              AppColors.gradientEnd.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.gradientEnd.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.gradientEnd,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (details != null && details!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Details Card
                  AppCard(
                    style: AppCardStyle.lavender,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quiz Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: details!.entries.map((entry) {
                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.subtext,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: AppSpacing.lg),
                
                // How It Works Card
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
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...steps.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key < steps.length - 1 ? AppSpacing.md : 0,
                          ),
                          child: _buildStep(
                            number: entry.key + 1,
                            text: entry.value,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Start Button
                CustomButton(
                  text: 'Start $title',
                  onPressed: () {
                    print('DEBUG: RecallModeInfoScreen - Start button pressed');
                    Navigator.of(context).pop(); // Close info screen
                    onStart(); // Execute the start action
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

  Widget _buildStep({required int number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
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
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
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

