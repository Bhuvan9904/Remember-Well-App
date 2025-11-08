import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/memory.dart';
import 'recall_quiz_screen.dart';

class RecallQuizInfoScreen extends StatelessWidget {
  final Memory memory;

  const RecallQuizInfoScreen({
    super.key,
    required this.memory,
  });

  int _calculateTotalQuestions() {
    int count = 1; // Who is always shown
    if (memory.tags != null && memory.tags!.isNotEmpty) {
      count++; // Tags question if available
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: RecallQuizInfoScreen - build() called');
    print('DEBUG: Memory ID: ${memory.id}');
    print('DEBUG: Memory text: ${memory.text}');
    
    final totalQuestions = _calculateTotalQuestions();
    print('DEBUG: Total questions: $totalQuestions');
    
    final snippet = memory.text.length > 50
        ? '${memory.text.substring(0, 50)}...'
        : memory.text;

    print('DEBUG: Building RecallQuizInfoScreen UI');
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recall Quiz'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Memory Preview Card
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
                      child: const Icon(
                        Icons.history,
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
                            snippet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (memory.tags != null && memory.tags!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: memory.tags!.take(2).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gradientMiddle.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Quiz Details Card
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '~${totalQuestions.clamp(1, 3)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Questions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    _buildStep(
                      number: 1,
                      text: 'Read the memory snippet above to refresh your memory',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildStep(
                      number: 2,
                      text: 'Answer questions about the memory\'s details (Who, Where, When, Tags)',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildStep(
                      number: 3,
                      text: 'See your score and track your recall improvement',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Start Button
              CustomButton(
                text: 'Start Recall Quiz',
                onPressed: () async {
                  // Navigate to quiz screen and wait for score
                  final score = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecallQuizScreen(memory: memory),
                    ),
                  );
                  
                  // Return the score to the previous screen (recall queue)
                  if (context.mounted) {
                    Navigator.of(context).pop(score);
                  }
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

