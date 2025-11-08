import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/utils/fuzzy_match.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/question_card.dart';
import '../../../data/models/memory.dart';
import '../../../data/repositories/memory_repository.dart';
import 'quiz_results_screen.dart';
import '../../../data/models/training_mode.dart';
import '../../../data/models/recall_plan.dart';
import '../../../data/repositories/recall_repository.dart';

class RecallQuizScreen extends StatefulWidget {
  final Memory? memory;
  final bool selfTest; // Replay mode: reveal then rate
  final bool onlyWho; // Limit to single Who question (e.g., Random Recall)
  final TrainingMode? mode; // Training mode for results screen

  const RecallQuizScreen({
    super.key,
    this.memory,
    this.selfTest = false,
    this.onlyWho = false,
    this.mode,
  });

  @override
  State<RecallQuizScreen> createState() => _RecallQuizScreenState();
}

class _RecallQuizScreenState extends State<RecallQuizScreen> {
  final Map<String, String> _answers = {};
  bool _isSubmitted = false;
  final _memoryRepo = MemoryRepository();
  final _recallRepo = RecallRepository();
  bool _revealed = false;
  RecallPlan? _existingPlan; // For scheduled recalls

  @override
  void initState() {
    super.initState();
    _loadExistingPlan();
  }

  void _loadExistingPlan() {
    if (widget.memory != null) {
      final plans = _recallRepo.getDuePlans();
      try {
        _existingPlan = plans.cast<RecallPlan>().firstWhere(
          (plan) => plan.memoryId == widget.memory!.id,
        );
      } catch (e) {
        _existingPlan = null;
      }
    }
  }

  Memory? get _memory => widget.memory;
  
  int get _totalQuestions {
    if (_memory == null) return 0;
    if (widget.onlyWho) return 1;
    int count = 1; // Who is always shown
    if (_memory!.place != null && _memory!.place!.isNotEmpty) {
      count++; // Place question if available
    }
    if (_memory!.tags != null && _memory!.tags!.isNotEmpty) {
      count++; // Tags question if available
    }
    return count;
  }
  
  int get _answeredCount {
    return _answers.values.where((answer) => answer.isNotEmpty).length;
  }
  
  List<String> _generateTagOptions(String correctTag) {
    // Get all unique tags from all memories
    final allMemories = _memoryRepo.getAll();
    final allTags = <String>{};
    for (var memory in allMemories) {
      if (memory.tags != null) {
        allTags.addAll(memory.tags!);
      }
    }
    
    // Remove the correct tag
    allTags.remove(correctTag);
    
    // If we have at least 2 other tags, use them as distractors
    if (allTags.length >= 2) {
      final otherTags = allTags.toList()..shuffle();
      return [correctTag, otherTags[0], otherTags[1]];
    }
    
    // Otherwise, use generic tag names
    final genericTags = ['work', 'personal', 'fun', 'important', 'family', 'friends'];
    final distractors = <String>[correctTag];
    for (var tag in genericTags) {
      if (tag != correctTag && !distractors.contains(tag)) {
        distractors.add(tag);
        if (distractors.length >= 3) break;
      }
    }
    return distractors;
  }

  @override
  Widget build(BuildContext context) {
    if (_memory == null) {
      return GradientBackground(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Recall Quiz'),
            elevation: 0,
          ),
          body: const Center(
            child: Text(
              'No memory selected',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final memory = _memory!; // Safe because we returned early if null
    
    // Self-test (Replay Mode): reveal then rate UI
    if (widget.selfTest) {
      return GradientBackground(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Replay 1/1'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Simple instruction text
                  const Text(
                    'Try to recall this memory',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Look away, think for a few seconds, and recall details.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSelfTestMeta(memory),
                  const SizedBox(height: AppSpacing.xl),
                  _buildRevealSection(memory),
                  const SizedBox(height: AppSpacing.xl),
                  if (_revealed) _buildRatingSection(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recall Quiz'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              
              // Memory context card with enhanced design
              _buildMemoryContext(),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Questions with better spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _buildQuestion(
                      'Who was involved in the memory?',
                      memory.who ?? '',
                      QuestionType.fillIn,
                      'who',
                      Icons.person,
                    ),
                    if (!widget.onlyWho) ...[
                      if (memory.tags != null && memory.tags!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildQuestion(
                          'Select a tag from this memory',
                          memory.tags!.first,
                          QuestionType.mcq,
                          'tag',
                          Icons.label,
                          customOptions: _generateTagOptions(memory.tags!.first),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.lg),
            child: CustomButton(
              text: _isSubmitted ? 'Review Results' : 'Submit Answers',
              onPressed: _isSubmitted ? _showResults : _submitAnswers,
              isExpanded: true,
            ),
          ),
        ),
      ),
    );
    
  }

  // Simplified two-step flow helpers

  Widget _buildSelfTestMeta(Memory memory) {
    final dateStr = date_utils.DateUtils.formatDate(memory.createdAt);
    final tags = (memory.tags ?? []);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientMiddle.withOpacity(0.9),
                AppColors.gradientEnd.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.gradientEnd.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date - prominent
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tags if available
                if (tags.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tags.first,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Who and Place
                if (memory.who != null && memory.who!.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: AppColors.subtext,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        memory.who!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevealSection(Memory memory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_revealed) ...[
          Center(
            child: Text(
              'When ready, tap reveal to see the memory text',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                onPressed: () => setState(() => _revealed = true),
                icon: const Icon(Icons.visibility, color: Colors.white, size: 24),
                label: const Text(
                  'Reveal Memory',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.ctaSecondary.withOpacity(0.5),
                ),
              ),
            ),
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                constraints: const BoxConstraints(minHeight: 220),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientMiddle.withOpacity(0.9),
                      AppColors.gradientEnd.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flashcard back indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BACK',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Memory text
                      Text(
                        memory.text,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: Text(
              'How well did you remember?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How much did you remember?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.md),
        _ratingButton('Didn\'t remember', 0, AppColors.error),
        const SizedBox(height: 10),
        _ratingButton('Partially', 50, AppColors.gradientMiddle),
        const SizedBox(height: 10),
        _ratingButton('Perfectly', 100, AppColors.ctaPrimary),
      ],
    );
  }

  Widget _ratingButton(String label, int score, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to results screen for self-test mode
        final memory = _memory;
        if (memory != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => QuizResultsScreen(
                memory: memory,
                overallScore: score,
                questionResults: [
                  QuizQuestionResult(
                    questionType: 'Self-Test',
                    questionLabel: 'Recall',
                    score: score,
                    userAnswer: 'Self-rated',
                    correctAnswer: 'Memory revealed',
                    memoryId: memory.id,
                  ),
                ],
                mode: widget.mode ?? TrainingMode.replay,
              ),
            ),
          );
        } else {
          Navigator.of(context).pop(score);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Text(
            '${score}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    
  }

  Widget _buildProgressIndicator() {
    final totalQuestions = _totalQuestions;
    if (totalQuestions <= 1) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildProgressSteps(totalQuestions),
          ),
          const SizedBox(height: 8),
          Text(
            '$_answeredCount / $totalQuestions Answered',
            style: const TextStyle(color: AppColors.subtext, fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildProgressSteps(int total) {
    final steps = <Widget>[];
    for (int i = 0; i < total; i++) {
      steps.add(
        Icon(
          Icons.check_circle,
          color: _answeredCount >= i + 1 ? AppColors.ctaPrimary : Colors.white38,
          size: 20,
        ),
      );
      if (i < total - 1) {
        steps.add(
          Container(
            width: 60,
            height: 2,
            color: _answeredCount >= i + 1 ? AppColors.ctaPrimary : Colors.white38,
          ),
        );
      }
    }
    return steps;
  }

  Widget _buildMemoryContext() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppCard(
        style: AppCardStyle.lavender,
        borderRadius: 16,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Try to Remember',
                      style: TextStyle(color: AppColors.subtext, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMemoryContext(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
    );
  }

  Widget _buildQuestion(String question, String correctAnswer, QuestionType type, String key, IconData icon, {List<String>? customOptions}) {
    if (!_answers.containsKey(key)) {
      _answers[key] = '';
    }

    List<String>? options;
    if (type == QuestionType.mcq) {
      if (customOptions != null) {
        options = customOptions..shuffle();
      } else {
      options = [
        correctAnswer,
        'Home',
        'Office',
      ]..shuffle();
      }
    }

    return QuestionCard(
      type: type,
      question: question,
      options: options,
      onAnswered: (answer) {
        setState(() {
          _answers[key] = answer;
        });
      },
    );
  }

  String _getMemoryContext() {
    if (_memory == null) return '';
    final text = _memory!.text;
    return text.length > 80 ? '${text.substring(0, 80)}...' : text;
  }

  void _submitAnswers() {
    if (_answers.values.every((answer) => answer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer at least one question'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });
    _showResults();
  }

  void _showResults() {
    final memory = _memory;
    if (memory == null) return;

    final scores = <String, int>{};
    int totalScore = 0;

    // Score Who
    final whoAnswer = _answers['who'];
    if (whoAnswer != null && whoAnswer.isNotEmpty && memory.who != null) {
      final whoScore = _scoreFillIn(whoAnswer, memory.who!);
      scores['Who'] = whoScore;
      totalScore += whoScore;
    }

    // Score Tag
    final tagAnswer = _answers['tag'];
    if (tagAnswer != null && tagAnswer.isNotEmpty && memory.tags != null && memory.tags!.isNotEmpty) {
      final tagScore = _scoreMCQ(tagAnswer, memory.tags![0]);
      scores['Tag'] = tagScore;
      totalScore += tagScore;
    }

    final avgScore = scores.isEmpty ? 0 : totalScore ~/ scores.length;

    // Build question results
    final questionResults = <QuizQuestionResult>[];
    
    // Who question
    if (whoAnswer != null && whoAnswer.isNotEmpty && memory.who != null) {
      questionResults.add(QuizQuestionResult(
        questionType: 'Fill-In',
        questionLabel: 'Who',
        score: scores['Who'] ?? 0,
        userAnswer: whoAnswer,
        correctAnswer: memory.who!,
        memoryId: memory.id,
      ));
    }
    
    // Place question
    // Tag question
    if (tagAnswer != null && tagAnswer.isNotEmpty && memory.tags != null && memory.tags!.isNotEmpty) {
      questionResults.add(QuizQuestionResult(
        questionType: 'Mcq',
        questionLabel: 'Tag',
        score: scores['Tag'] ?? 0,
        userAnswer: tagAnswer,
        correctAnswer: memory.tags![0],
        memoryId: memory.id,
      ));
    }

    // Navigate to results screen instead of showing dialog
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          memory: memory,
          overallScore: avgScore,
          questionResults: questionResults,
          mode: widget.mode ?? TrainingMode.scheduled,
          existingPlan: _existingPlan,
        ),
      ),
    );
  }


  int _scoreFillIn(String answer, String correct) {
    final similarity = FuzzyMatch.similarity(answer.toLowerCase().trim(), correct.toLowerCase().trim());
    return (similarity * 100).round();
  }

  int _scoreMCQ(String answer, String correct) {
    return answer.toLowerCase().trim() == correct.toLowerCase().trim() ? 100 : 0;
  }
}