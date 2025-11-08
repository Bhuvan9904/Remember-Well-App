import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import 'recall_queue_screen.dart';
import 'recall_quiz_screen.dart';
import 'battle_mode_screen.dart';
import 'guided_paths_screen.dart';
import 'recall_mode_info_screen.dart';
import '../widgets/replay_mode_info_screen.dart';
import '../widgets/random_recall_info_screen.dart';
import '../widgets/battle_mode_info_screen.dart';
import '../widgets/guided_paths_info_screen.dart';
import '../../../data/models/recall_attempt.dart';
import '../../../data/models/training_mode.dart';
import '../../../shared/widgets/app_card.dart';

class RecallHubScreen extends StatefulWidget {
  const RecallHubScreen({super.key});

  @override
  State<RecallHubScreen> createState() => _RecallHubScreenState();
}

class _RecallHubScreenState extends State<RecallHubScreen> {
  final _recallRepo = RecallRepository();
  final _memoryRepo = MemoryRepository();

  int _dueCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final due = _recallRepo.getDuePlans();
    setState(() {
      _dueCount = due.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Recall Training',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Challenge yourself with different training modes',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.subtext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Recalls Due Today card
                    _buildActiveRecallsCard(),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Training Modes section
                    const Text(
                      'Training Modes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtext,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Replay Mode
                    _ModeButton(
                      title: 'Replay Mode',
                      subtitle: 'Flashcard-style self-test with any memory',
                      icon: Icons.bolt,
                      gradient: [
                        AppColors.gradientMiddle,
                        AppColors.gradientEnd,
                      ],
                      onTap: () {
                        print('DEBUG: RecallHubScreen - Replay Mode tapped');
                        final all = _memoryRepo.getAll();
                        if (all.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No memories available yet'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReplayModeInfoScreen(
                              onStart: () async {
                                all.shuffle();
                                final memory = all.first;
                                final score = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RecallQuizScreen(
                                      memory: memory,
                                      selfTest: true,
                                      mode: TrainingMode.replay,
                                    ),
                                  ),
                                );
                                
                                // Create recall attempt for tracking
                                if (score is int && score > 0) {
                                  final attempt = RecallAttempt(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    memoryId: memory.id,
                                    attemptedAt: DateTime.now(),
                                    score: score,
                                    mode: TrainingMode.replay,
                                  );
                                  await _recallRepo.createAttempt(attempt);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Random Recall
                    _ModeButton(
                      title: 'Random Recall',
                      subtitle: 'Surprise quiz with 5 random memories',
                      icon: Icons.shuffle,
                      gradient: [
                        AppColors.gradientMiddle,
                        AppColors.gradientEnd,
                      ],
                      onTap: () {
                        print('DEBUG: RecallHubScreen - Random Recall tapped');
                        final all = _memoryRepo.getAll();
                        if (all.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No memories available yet'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RandomRecallInfoScreen(
                              onStart: () async {
                                all.shuffle();
                                final memory = all.first;
                                final score = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RecallQuizScreen(
                                      memory: memory,
                                      onlyWho: true,
                                      mode: TrainingMode.random,
                                    ),
                                  ),
                                );
                                
                                // Create recall attempt for tracking
                                if (score is int && score > 0) {
                                  final attempt = RecallAttempt(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    memoryId: memory.id,
                                    attemptedAt: DateTime.now(),
                                    score: score,
                                    mode: TrainingMode.random,
                                  );
                                  await _recallRepo.createAttempt(attempt);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Battle Mode
                    _ModeButton(
                      title: 'Battle Mode',
                      subtitle: 'Timed speed challenge (60 or 120 seconds)',
                      icon: Icons.compare_arrows,
                      gradient: [
                        AppColors.gradientMiddle,
                        AppColors.gradientEnd,
                      ],
                      onTap: () {
                        print('DEBUG: RecallHubScreen - Battle Mode tapped');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BattleModeInfoScreen(
                              onStart: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const BattleModeScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Guided Paths
                    _ModeButton(
                      title: 'Guided Paths',
                      subtitle: 'Focus on People, Places, or Sensory memories',
                      icon: Icons.center_focus_strong,
                      gradient: [
                        AppColors.gradientMiddle,
                        AppColors.gradientEnd,
                      ],
                      onTap: () {
                        print('DEBUG: RecallHubScreen - Guided Paths tapped');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GuidedPathsInfoScreen(
                              onStart: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GuidedPathsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActiveRecallsCard() {
    return AppCard(
      style: AppCardStyle.bluePurple,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      onTap: () {
        print('DEBUG: RecallHubScreen - Recalls Due Today card tapped');
        if (_dueCount > 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecallModeInfoScreen(
                title: 'Recalls Due Today',
                subtitle: 'Scheduled recall practice',
                icon: Icons.mail_outline,
                description: 'You have $_dueCount ${_dueCount == 1 ? 'memory' : 'memories'} ready to recall. Practice your scheduled recalls to strengthen your memory.',
                steps: [
                  'Review the list of memories due for recall',
                  'Tap on any memory card to start the quiz',
                  'Answer questions about each memory\'s details',
                  'Track your progress and see your improvement',
                ],
                details: {
                  '$_dueCount': _dueCount == 1 ? 'Memory' : 'Memories',
                  '~${_dueCount * 2}': 'Questions',
                },
                onStart: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecallQueueScreen()),
                  );
                },
              ),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mailbox icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recalls Due Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have $_dueCount ${_dueCount == 1 ? 'memory' : 'memories'} ready to recall',
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
          if (_dueCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('DEBUG: RecallHubScreen - Start Recalls button pressed');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecallModeInfoScreen(
                        title: 'Recalls Due Today',
                        subtitle: 'Scheduled recall practice',
                        icon: Icons.mail_outline,
                        description: 'You have $_dueCount ${_dueCount == 1 ? 'memory' : 'memories'} ready to recall. Practice your scheduled recalls to strengthen your memory.',
                        steps: [
                          'Review the list of memories due for recall',
                          'Tap on any memory card to start the quiz',
                          'Answer questions about each memory\'s details',
                          'Track your progress and see your improvement',
                        ],
                        details: {
                          '$_dueCount': _dueCount == 1 ? 'Memory' : 'Memories',
                          '~${_dueCount * 2}': 'Questions',
                        },
                        onStart: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RecallQueueScreen()),
                          );
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Recalls ($_dueCount)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x80F78330),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFF9F8C0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Start button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.ctaPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
    );
  }
}