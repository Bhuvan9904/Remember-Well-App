import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/models/memory.dart';
import '../../../data/models/recall_attempt.dart';
import '../../../data/models/training_mode.dart';
import '../../recall/widgets/question_card.dart';
import '../../../core/utils/fuzzy_match.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import 'quiz_results_screen.dart';

class BattleModeScreen extends StatefulWidget {
  const BattleModeScreen({super.key});

  @override
  State<BattleModeScreen> createState() => _BattleModeScreenState();
}

class _BattleModeScreenState extends State<BattleModeScreen> with WidgetsBindingObserver {
  final _memoryRepo = MemoryRepository();
  final _recallRepo = RecallRepository();

  int _durationSeconds = 60; // user selectable 60/120
  int _timeLeft = 60;
  Timer? _timer;

  List<Memory> _queue = [];
  int _index = 0;
  String _input = '';
  int _correctTotal = 0; // sum of 0/50/100
  int _attempted = 0;
  bool _running = false;
  List<QuizQuestionResult> _questionResults = []; // Track individual question results

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepare();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_running) return;
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  void _prepare() {
    final all = _memoryRepo.getAll();
    _queue = List<Memory>.from(all)..shuffle();
    _index = 0;
    _input = '';
    _attempted = 0;
    _correctTotal = 0;
    _questionResults = [];
    _timeLeft = _durationSeconds;
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft -= 1;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          _timer?.cancel();
          _running = false;
        }
      });
      if (_timeLeft == 0) {
        _showSummary();
      }
    });
  }

  void _start() {
    if (_queue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No memories available yet'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() {
      _running = true;
      _timeLeft = _durationSeconds;
    });
    _startTimer();
  }

  Memory? get _current => (_index < _queue.length) ? _queue[_index] : null;

  void _onSkip() {
    if (!_running) return;
    _handleSkip();
  }

  Future<void> _onSubmit() async {
    if (!_running) return;
    final memory = _current;
    if (memory == null) return;
    int score = 0;
    if (memory.who != null && _input.trim().isNotEmpty) {
      final s = FuzzyMatch.similarity(_input.toLowerCase().trim(), memory.who!.toLowerCase().trim());
      score = (s * 100).round();
      if (score >= 85) score = 100; else if (score >= 40) score = 50; else score = 0;
    }

    // Track question result
    _questionResults.add(QuizQuestionResult(
      questionType: 'Fill-In',
      questionLabel: 'Who',
      score: score,
      userAnswer: _input.trim().isNotEmpty ? _input : 'Skipped',
      correctAnswer: memory.who ?? '',
      memoryId: memory.id,
    ));

    if (score > 0) {
      final attempt = RecallAttempt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memoryId: memory.id,
        attemptedAt: DateTime.now(),
        score: score,
        mode: TrainingMode.battle,
      );
      await _recallRepo.createAttempt(attempt);
    }

    _advance(score: score);
  }

  void _advance({required int score}) {
    setState(() {
      _attempted += 1;
      _correctTotal += score;
      _input = '';
      _index += 1;
    });
    // If we've completed all questions before the timer ends, finish early
    if (_index >= _queue.length) {
      _running = false;
      _timer?.cancel();
      _showSummary();
    }
  }
  
  void _handleSkip() {
    final memory = _current;
    if (memory != null) {
      // Track skipped question as 0% score
      _questionResults.add(QuizQuestionResult(
        questionType: 'Fill-In',
        questionLabel: 'Who',
        score: 0,
        userAnswer: 'Skipped',
        correctAnswer: memory.who ?? '',
        memoryId: memory.id,
      ));
    }
    _advance(score: 0);
  }

  void _showSummary() {
    final accuracy = _attempted == 0 ? 0 : (_correctTotal / _attempted).round();
    
    // Use the first memory from the queue for the results screen
    // If no memories, create a placeholder
    final memory = _queue.isNotEmpty ? _queue.first : null;
    
    if (memory == null) {
      // Fallback to simple dialog if no memories
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Round Complete', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Attempts: $_attempted'),
                const SizedBox(height: 4),
                Text('Accuracy: $accuracy%'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    
    // Navigate to results screen instead of showing dialog
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          memory: memory,
          overallScore: accuracy,
          questionResults: _questionResults,
          mode: TrainingMode.battle,
          currentProgress: 1,
          totalProgress: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Battle Mode'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              if (!_running) _buildSetup() else _buildRound(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final accuracy = _attempted == 0 ? 0 : (_correctTotal / _attempted).round();
    return AppCard(
      style: AppCardStyle.lavender,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time: ${_timeLeft}s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Attempts: $_attempted', style: const TextStyle(color: AppColors.subtext)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$accuracy%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Choose duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _durationButton(60)),
            const SizedBox(width: 8),
            Expanded(child: _durationButton(120)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: _start,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ctaPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Start'),
        ),
      ],
    );
  }

  Widget _durationButton(int seconds) {
    final selected = _durationSeconds == seconds;
    return ElevatedButton(
      onPressed: () => setState(() => _durationSeconds = seconds),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.ctaSecondary : Colors.white.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text('$seconds s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRound() {
    final memory = _current;
    if (memory == null) {
      return const Center(child: Text('No memories', style: TextStyle(color: Colors.white)));
    }
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Context card: show which memory (without revealing 'who')
            AppCard(
              style: AppCardStyle.lavender,
              borderRadius: 16,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date_utils.DateUtils.formatDate(memory.createdAt),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if ((memory.tags ?? []).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text((memory.tags!).first, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            QuestionCard(
              key: ValueKey('battle-q-${_index}-${memory.id}'),
              type: QuestionType.fillIn,
              question: 'Who was involved in the memory?',
              options: null,
              onAnswered: (value) => _input = value,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ctaPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


