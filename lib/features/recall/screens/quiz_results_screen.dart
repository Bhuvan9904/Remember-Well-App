import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../data/models/memory.dart';
import '../../../core/utils/adaptive_algorithm.dart';
import '../../../data/models/recall_plan.dart';
import '../../../data/models/training_mode.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../memory/screens/memory_detail_screen.dart';
import 'wrong_entries_review_screen.dart';

class QuizQuestionResult {
  final String questionType; // 'Mcq', 'Fill-In'
  final String questionLabel; // 'Who', 'Place', 'Tag'
  final int score; // 0-100
  final String userAnswer;
  final String correctAnswer;
  final String memoryId; // For linking back to original entry

  QuizQuestionResult({
    required this.questionType,
    required this.questionLabel,
    required this.score,
    required this.userAnswer,
    required this.correctAnswer,
    required this.memoryId,
  });
}

class QuizResultsScreen extends StatelessWidget {
  final Memory memory;
  final int overallScore; // 0-100
  final List<QuizQuestionResult> questionResults;
  final TrainingMode mode;
  final int currentProgress; // e.g., 1/5
  final int totalProgress; // e.g., 5
  final RecallPlan? existingPlan; // For scheduled recalls

  const QuizResultsScreen({
    super.key,
    required this.memory,
    required this.overallScore,
    required this.questionResults,
    required this.mode,
    this.currentProgress = 1,
    this.totalProgress = 1,
    this.existingPlan,
  });

  bool _hasMultipleWrong(List<QuizQuestionResult> results) {
    final ids = results
        .where((r) => r.score < 70)
        .map((r) => r.memoryId)
        .toSet();
    return ids.length > 1;
  }

  void _reviewEntries(BuildContext context, List<QuizQuestionResult> results, Memory fallback) {
    final memoryRepo = MemoryRepository();
    final wrongIds = results
        .where((r) => r.score < 70)
        .map((r) => r.memoryId)
        .toSet()
        .toList();

    // If none wrong, default to the single memory
    if (wrongIds.isEmpty) {
      final mem = memoryRepo.getById(fallback.id);
      if (mem != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: mem)),
        );
      }
      return;
    }

    // If only one wrong memory, open it directly
    if (wrongIds.length == 1) {
      final mem = memoryRepo.getById(wrongIds.first);
      if (mem != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: mem)),
        );
      }
      return;
    }

    // Otherwise, show a sequential review screen
    final memories = wrongIds
        .map((id) => memoryRepo.getById(id))
        .whereType<Memory>()
        .toList();
    if (memories.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WrongEntriesReviewScreen(memories: memories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate next recall date if scheduled mode
    DateTime? nextRecallDate;
    if (mode == TrainingMode.scheduled && existingPlan != null) {
      final currentInterval = existingPlan!.intervalDays;
      final nextDays = AdaptiveAlgorithm.calculateNextInterval(currentInterval, overallScore);
      nextRecallDate = DateTime.now().add(Duration(days: nextDays));
    }

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training Progress indicator
                if (totalProgress > 1)
                  AppCard(
                    style: AppCardStyle.lavender,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Training Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.ctaPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$currentProgress/$totalProgress',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (totalProgress > 1) const SizedBox(height: AppSpacing.lg),

                // Overall Recall Accuracy
                Center(
                  child: Column(
                    children: [
                      // Circular progress indicator
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: overallScore / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(overallScore),
                                ),
                              ),
                            ),
                            // Score text
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$overallScore',
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Status message
                      Text(
                        _getStatusMessage(overallScore),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(overallScore),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overall recall accuracy',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Question Breakdown
                const Text(
                  'Question Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...questionResults.map((result) => _buildQuestionCard(result)),
                const SizedBox(height: AppSpacing.lg),

                // Next Recall Scheduled (if applicable)
                if (nextRecallDate != null)
                  AppCard(
                    style: AppCardStyle.lavender,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart.withOpacity(0.3),
                                AppColors.gradientEnd.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Next Recall Scheduled',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: AppColors.subtext,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date_utils.DateUtils.formatDateTime(nextRecallDate),
                                style: const TextStyle(
                                  color: AppColors.subtext,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (nextRecallDate != null) const SizedBox(height: AppSpacing.lg),

                // Action Buttons
                CustomButton(
                  text: _hasMultipleWrong(questionResults)
                      ? 'Review Wrong Entries'
                      : 'Review Original Entry',
                  onPressed: () => _reviewEntries(context, questionResults, memory),
                  isExpanded: true,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  textColor: Colors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                if (totalProgress > 1 && currentProgress < totalProgress)
                  CustomButton(
                    text: 'Continue (${totalProgress - currentProgress} left)',
                    onPressed: () {
                      Navigator.of(context).pop(true); // Continue to next quiz
                    },
                    isExpanded: true,
                  )
                else
                  CustomButton(
                    text: 'Done',
                    onPressed: () {
                      Navigator.of(context).pop(overallScore);
                    },
                    isExpanded: true,
                  ),
                const SizedBox(height: AppSpacing.lg),

                // Motivational Message
                AppCard(
                  style: AppCardStyle.lavender,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.ctaSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: AppColors.ctaSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Keep practicing! Recall improves with repetition.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestionResult result) {
    final isCorrect = result.score >= 70;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        style: AppCardStyle.lavender,
        borderRadius: 16,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.ctaPrimary.withOpacity(0.3)
                    : AppColors.error.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check : Icons.close,
                color: isCorrect ? AppColors.ctaPrimary : AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Question type and score
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.questionType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${result.score}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your answer: ${result.userAnswer}',
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.ctaPrimary;
    if (score >= 70) return AppColors.ctaSecondary;
    if (score >= 50) return AppColors.gradientMiddle;
    return AppColors.error;
  }

  String _getStatusMessage(int score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 70) return 'Good Job!';
    if (score >= 50) return 'Keep Trying';
    return 'Needs Work';
  }
}

