import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../data/models/memory.dart';
import '../../../data/models/recall_attempt.dart';
import '../../../data/models/training_mode.dart';
import '../../recall/screens/recall_quiz_info_screen.dart';
import '../../memory/screens/memory_detail_screen.dart';
import '../widgets/recall_card.dart';
import '../../../shared/widgets/app_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _memoryRepo = MemoryRepository();
  final _recallRepo = RecallRepository();
  final _prefsRepo = PreferencesRepository();
  
  List<Memory> _dueMemories = [];
  List<Memory> _recentMemories = [];
  int _streak = 0;
  int _totalMemories = 0;
  int _totalRecalls = 0;
  int _avgScore = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastRefreshTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible (for IndexedStack)
    // Only refresh if it's been a while since last refresh to avoid excessive calls
    final now = DateTime.now();
    if (_lastRefreshTime == null || 
        now.difference(_lastRefreshTime!).inSeconds > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
          _lastRefreshTime = now;
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  // Method to manually refresh data (can be called externally)
  void refreshData() {
    _loadData();
  }

  Future<void> _resetOnboardingFlow() async {
    try {
      await _prefsRepo.updateOnboardingDone(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding reset. Launching intro flow...'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.intro, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset onboarding: $e')),
      );
    }
  }

  Future<void> _loadData() async {
    // Get due recall plans
    final duePlans = _recallRepo.getDuePlans();
    final memoryIds = duePlans.map((plan) => plan.memoryId).toSet();
    _dueMemories = memoryIds
        .map((id) => _memoryRepo.getById(id))
        .where((memory) => memory != null)
        .cast<Memory>()
        .toList();

    // No hardcoded fallback; show data-driven dues only

    // Calculate streak
    _streak = _calculateStreak();
    
    // TEMPORARY: Set hardcoded streak for preview
    if (_streak == 0) {
      _streak = 7;
    }

    // Get recent memories (last 5) - recently created memories
    final allMemories = _memoryRepo.getAll();
    _recentMemories = allMemories.take(5).toList();
    
    // Calculate memory stats
    _totalMemories = allMemories.length;
    print('DEBUG: Total memories: $_totalMemories');
    _calculateMemoryStats();

    // TEMPORARY: Commented out hardcoded recent activity to show empty state
    // Uncomment below to preview with hardcoded data
    // if (_recentAttempts.isEmpty) {
    //   _recentAttempts = [
    //     RecallAttempt(
    //       id: 'temp_attempt_1',
    //       memoryId: 'temp_1',
    //       attemptedAt: DateTime.now().subtract(const Duration(hours: 2)),
    //       score: 95,
    //     ),
    //     RecallAttempt(
    //       id: 'temp_attempt_2',
    //       memoryId: 'temp_2',
    //       attemptedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    //       score: 78,
    //     ),
    //   ];
    // }

    if (mounted) {
      setState(() {});
    }
  }

  int _calculateStreak() {
    final memories = _memoryRepo.getAll();
    if (memories.isEmpty) return 0;

    final dates = memories.map((m) {
      final date = m.createdAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    for (var i = 0; i < dates.length; i++) {
      final expectedDate = todayStart.subtract(Duration(days: i));
      if (dates[i].isAtSameMomentAs(expectedDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  void _calculateMemoryStats() {
    // Get all recall attempts
    final allAttempts = _recallRepo.getAllAttempts();
    _totalRecalls = allAttempts.length;
    
    print('DEBUG: Memory Card Stats Calculation');
    print('DEBUG: Total recall attempts: $_totalRecalls');
    
    // Calculate average score
    if (allAttempts.isNotEmpty) {
      final totalScore = allAttempts.fold<int>(0, (sum, attempt) => sum + attempt.score);
      _avgScore = (totalScore / allAttempts.length).round();
      print('DEBUG: Total score: $totalScore, Average: $_avgScore%');
    } else {
      _avgScore = 0;
      print('DEBUG: No attempts found, avg score set to 0');
    }
    
    // Calculate best streak from recall attempts
    if (allAttempts.isEmpty) {
      _bestStreak = 0;
      print('DEBUG: No attempts found, best streak set to 0');
      return;
    }
    
    // Get unique dates with recalls (count each day only once)
    final datesWithRecalls = allAttempts.map((attempt) {
      final date = attempt.attemptedAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList()..sort();
    
    print('DEBUG: Unique dates with recalls: ${datesWithRecalls.length}');
    
    if (datesWithRecalls.isEmpty) {
      _bestStreak = 0;
      print('DEBUG: No dates found, best streak set to 0');
      return;
    }
    
    // Calculate consecutive days streak
    int bestStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < datesWithRecalls.length; i++) {
      final daysDiff = datesWithRecalls[i].difference(datesWithRecalls[i - 1]).inDays;
      if (daysDiff == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }
    
    _bestStreak = bestStreak;
    print('DEBUG: Best streak calculated: $_bestStreak days');
    print('DEBUG: Final stats - Recalls: $_totalRecalls, Avg Score: $_avgScore%, Best Streak: $_bestStreak');
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: _buildContent(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).pushNamed(AppRoutes.newMemory);
            if (result == true) {
              _loadData(); // Refresh when returning from new memory
            }
          },
          backgroundColor: AppColors.ctaPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi there 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ready to capture today?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _resetOnboardingFlow,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.subtext,
                  tooltip: 'Replay onboarding flow',
                ),
              ],
            ),
          ),
          // Streak Card
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: _buildStreakCard(),
          ),
          // Memory Stats Card
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: _buildMemoryCard(),
          ),
          // Recalls Due Today section
          if (_dueMemories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  const Text(
                    'Recalls Due Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ctaSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_dueMemories.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _dueMemories.length,
                itemBuilder: (context, index) {
                  final memory = _dueMemories[index];
                    return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: RecallCard(
                      memory: memory,
                      onTap: () async {
                        print('DEBUG: HomeScreen - Card tapped for memory: ${memory.id}');
                        print('DEBUG: Navigating to RecallQuizInfoScreen');
                        try {
                          final score = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                print('DEBUG: Building RecallQuizInfoScreen from HomeScreen');
                                return RecallQuizInfoScreen(memory: memory);
                              },
                            ),
                          );
                          print('DEBUG: Returned from quiz with score: $score');
                          
                          // Create recall attempt if score was returned
                          if (score != null) {
                            final intScore = score is int ? score : (score is double ? score.toInt() : null);
                            if (intScore != null && intScore > 0) {
                              final attempt = RecallAttempt(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                memoryId: memory.id,
                                attemptedAt: DateTime.now(),
                                score: intScore,
                                mode: TrainingMode.scheduled,
                              );
                              await _recallRepo.createAttempt(attempt);
                            }
                          }
                          // Refresh data immediately after returning from quiz
                          if (mounted) {
                            await _loadData();
                          }
                        } catch (e, stackTrace) {
                          print('DEBUG: ERROR in HomeScreen onTap: $e');
                          print('DEBUG: Stack trace: $stackTrace');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: CustomButton(
                text: 'Start All Recalls (${_dueMemories.length})',
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.recallQueue);
                  // Refresh immediately when returning - attempts are already saved
                  if (mounted) {
                    await _loadData();
                  }
                },
                isExpanded: true,
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: EmptyStateWidget(
                icon: Icons.calendar_today,
                title: 'No Recalls Due',
                message: 'All caught up! Your next recalls will appear here.',
                buttonText: 'Start logging memories',
                onButtonTap: () async {
                  final result = await Navigator.of(context).pushNamed(AppRoutes.newMemory);
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
            ),
          // Recent Activity section
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_recentMemories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentMemories.length,
                itemBuilder: (context, index) {
                  final memory = _recentMemories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildRecentActivityCard(memory),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildRecentActivityEmptyState(),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return AppCard(
      style: AppCardStyle.bluePurple,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _streak > 0 ? '$_streak-Day Logging Streak' : 'Start Your Streak Today!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 4),
                Text(
                  _streak > 0 ? 'Keep it going! 🎉✨' : 'Log a memory to begin your journey!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard() {
    return AppCard(
      style: AppCardStyle.lavender,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and subtitle
          const Text(
            'Memory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_totalMemories ${_totalMemories == 1 ? 'memory' : 'memories'} • $_streak day streak',
            style: const TextStyle(
              color: AppColors.subtext,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Stats sections
          Row(
            children: [
              Expanded(
                child: _buildStatSection(
                  icon: Icons.psychology_outlined,
                  value: '$_totalRecalls',
                  label: 'Recalls',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatSection(
                  icon: Icons.emoji_events_outlined,
                  value: '$_avgScore%',
                  label: 'Avg Score',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatSection(
                  icon: Icons.calendar_today_outlined,
                  value: '$_bestStreak',
                  label: 'Best Streak',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtext,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(Memory memory) {
    // Get text snippet
    final snippet = memory.text.length > 50
        ? '${memory.text.substring(0, 50)}...'
        : memory.text;

    // Use same icon and color for all cards
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MemoryDetailScreen(memory: memory),
          ),
        );
      },
      child: Row(
          children: [
            // Icon indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0x8077218B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0x8077218B),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF77218B),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Memory info
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date_utils.DateUtils.getRelativeTime(memory.createdAt),
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 11,
                        ),
                      ),
                      if (memory.tags != null && memory.tags!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientMiddle.withOpacity(0.5),
                                AppColors.gradientEnd.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gradientEnd.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            memory.tags!.first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
    );
  }

  Widget _buildRecentActivityEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientMiddle.withOpacity(0.2),
              AppColors.gradientEnd.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your recall attempts will appear here\nonce you start practicing',
              textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subtext,
              height: 1.4,
            ),
            ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isAtSameMomentAs(DateTime other) {
    return difference(other).inDays == 0;
  }
}