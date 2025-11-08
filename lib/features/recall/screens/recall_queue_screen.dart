import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/models/memory.dart';
import 'recall_quiz_screen.dart';
import 'recall_quiz_info_screen.dart';
import '../../../core/utils/adaptive_algorithm.dart';
import '../../../data/models/recall_plan.dart';
import '../../../data/models/recall_status.dart';
import '../../../data/models/recall_attempt.dart';
import '../../../data/models/training_mode.dart';

class RecallQueueScreen extends StatefulWidget {
  const RecallQueueScreen({super.key});

  @override
  State<RecallQueueScreen> createState() => _RecallQueueScreenState();
}

class _RecallQueueScreenState extends State<RecallQueueScreen> {
  final _recallRepo = RecallRepository();
  final _memoryRepo = MemoryRepository();

  List<Memory> _dueMemories = [];
  var _duePlans = <dynamic>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDue();
  }

  Future<void> _loadDue() async {
    final plans = _recallRepo.getDuePlans();
    _duePlans = plans;
    final ids = plans.map((p) => p.memoryId).toList();
    _dueMemories = ids
        .map((id) => _memoryRepo.getById(id))
        .where((m) => m != null)
        .cast<Memory>()
        .toList();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _startQueue() async {
    for (var i = 0; i < _dueMemories.length; i++) {
      final memory = _dueMemories[i];
      if (!mounted) return;
      
      final score = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecallQuizScreen(memory: memory),
        ),
      );

      final RecallPlan? plan = _duePlans.firstWhere(
        (p) => p.memoryId == memory.id,
        orElse: () => null,
      );
      
      if (plan != null) {
        final int finalScore = (score is int) ? score : 0;
        
        // Create recall attempt for tracking
        if (finalScore > 0) {
          final attempt = RecallAttempt(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            memoryId: memory.id,
            attemptedAt: DateTime.now(),
            score: finalScore,
            mode: TrainingMode.scheduled,
          );
          await _recallRepo.createAttempt(attempt);
        }
        
        plan.status = RecallStatus.completed;
        await _recallRepo.updatePlan(plan);

        final int currentInterval = plan.intervalDays;
        final int nextDays = AdaptiveAlgorithm.calculateNextInterval(currentInterval, finalScore);
        
        final newPlan = RecallPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          memoryId: memory.id,
          dueAt: DateTime.now().add(Duration(days: nextDays)),
          intervalDays: nextDays,
          status: RecallStatus.pending,
          createdAt: DateTime.now(),
          snoozeCount: 0,
        );
        await _recallRepo.createPlan(newPlan);
      }
    }
    
    if (!mounted) return;
    _showComplete();
  }

  void _showComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.ctaPrimary.withOpacity(0.8),
                      AppColors.ctaPrimary,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Queue Complete! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All due recalls have been processed. Great job!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)..pop()..pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientStart,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _snoozeAll() async {
    if (_duePlans.isEmpty) return;
    final now = DateTime.now();
    int snoozedCount = 0;
    
    for (final p in _duePlans) {
      if ((p.snoozeCount ?? 0) >= 3) continue;
      p.dueAt = now.add(const Duration(hours: 2));
      p.snoozeCount = (p.snoozeCount ?? 0) + 1;
      await _recallRepo.updatePlan(p);
      snoozedCount++;
    }
    
    await _loadDue();
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$snoozedCount recalls snoozed by 2 hours'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _rescheduleAllTomorrow() async {
    if (_duePlans.isEmpty) return;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final target = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8);
    
    for (final p in _duePlans) {
      p.dueAt = target;
      await _recallRepo.updatePlan(p);
    }
    
    await _loadDue();
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All recalls rescheduled to tomorrow'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxSnoozes = 3;
    final bool snoozeEnabled = _duePlans.any((p) => (p.snoozeCount ?? 0) < maxSnoozes);
    
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recall Queue'),
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _dueMemories.isEmpty
                ? const _Empty()
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with count
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientMiddle,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Due Recalls (${_dueMemories.length})',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        
                        // List of memories
                        Expanded(
                          child: ListView.separated(
                            itemCount: _dueMemories.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final m = _dueMemories[index];
                              final plan = _duePlans.firstWhere(
                                (p) => p.memoryId == m.id,
                                orElse: () => null,
                              );
                              final int snoozeCount = (plan?.snoozeCount ?? 0) as int;
                              final int snoozesLeft = 3 - snoozeCount;
                              final snippet = m.text.length > 60
                                  ? '${m.text.substring(0, 60)}...'
                                  : m.text;
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  onTap: () async {
                                    print('DEBUG: RecallQueueScreen - Card tapped for memory: ${m.id}');
                                    print('DEBUG: Navigating to RecallQuizInfoScreen');
                                    try {
                                      final score = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) {
                                            print('DEBUG: Building RecallQuizInfoScreen');
                                            return RecallQuizInfoScreen(memory: m);
                                          },
                                        ),
                                      );
                                      print('DEBUG: Returned from quiz with score: $score');

                                      final RecallPlan? plan = _duePlans.firstWhere(
                                        (p) => p.memoryId == m.id,
                                        orElse: () => null,
                                      );
                                      
                                      if (plan != null && score != null) {
                                      final int finalScore = (score is int) ? score : 0;
                                      
                                      // Create recall attempt for tracking
                                      if (finalScore > 0) {
                                        final attempt = RecallAttempt(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          memoryId: m.id,
                                          attemptedAt: DateTime.now(),
                                          score: finalScore,
                                          mode: TrainingMode.scheduled,
                                        );
                                        await _recallRepo.createAttempt(attempt);
                                      }
                                      
                                      plan.status = RecallStatus.completed;
                                      await _recallRepo.updatePlan(plan);

                                      final int currentInterval = plan.intervalDays;
                                      final int nextDays = AdaptiveAlgorithm.calculateNextInterval(currentInterval, finalScore);
                                      
                                      final newPlan = RecallPlan(
                                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                                        memoryId: m.id,
                                        dueAt: DateTime.now().add(Duration(days: nextDays)),
                                        intervalDays: nextDays,
                                        status: RecallStatus.pending,
                                        createdAt: DateTime.now(),
                                        snoozeCount: 0,
                                      );
                                      await _recallRepo.createPlan(newPlan);
                                      }
                                      
                                      if (mounted) {
                                        await _loadDue();
                                      }
                                    } catch (e, stackTrace) {
                                      print('DEBUG: ERROR in RecallQueueScreen onTap: $e');
                                      print('DEBUG: Stack trace: $stackTrace');
                                    }
                                  },
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.gradientStart.withOpacity(0.2),
                                          AppColors.gradientMiddle.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    snippet,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (m.tags?.isNotEmpty ?? false) ...[
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 4,
                                          children: m.tags!.take(2).map((tag) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.gradientStart.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                tag,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.alarm,
                                            size: 12,
                                            color: snoozesLeft > 0 ? Colors.black54 : AppColors.warning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Snoozes left: $snoozesLeft / 3',
                                            style: TextStyle(
                                              color: snoozesLeft > 0 ? Colors.black54 : AppColors.warning,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.black54),
                                    onSelected: (value) async {
                                      if (value == 'snooze' && (plan?.snoozeCount ?? 0) < 3) {
                                        plan!.dueAt = DateTime.now().add(const Duration(hours: 2));
                                        plan.snoozeCount = (plan.snoozeCount ?? 0) + 1;
                                        await _recallRepo.updatePlan(plan);
                                        await _loadDue();
                                      } else if (value == 'tomorrow') {
                                        final t = DateTime.now().add(const Duration(days: 1));
                                        final target = DateTime(t.year, t.month, t.day, 8);
                                        plan!.dueAt = target;
                                        await _recallRepo.updatePlan(plan);
                                        await _loadDue();
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'snooze',
                                        enabled: (plan?.snoozeCount ?? 0) < 3,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.snooze, size: 20),
                                            const SizedBox(width: 8),
                                            const Text('Snooze +2h'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'tomorrow',
                                        child: Row(
                                          children: [
                                            Icon(Icons.schedule, size: 20),
                                            SizedBox(width: 8),
                                            Text('Reschedule to tomorrow'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _startQueue,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gradientStart,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: snoozeEnabled ? _snoozeAll : null,
                                icon: const Icon(Icons.snooze),
                                label: Text(
                                  snoozeEnabled ? 'Snooze All' : 'Limit Reached',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                    color: snoozeEnabled ? AppColors.warning : Colors.grey,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _rescheduleAllTomorrow,
                                icon: const Icon(Icons.schedule),
                                label: const Text('Tomorrow'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: AppColors.ctaSecondary, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientStart.withOpacity(0.2),
                  AppColors.gradientMiddle.withOpacity(0.2),
                ],
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.gradientStart,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up! 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No recalls due right now',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}