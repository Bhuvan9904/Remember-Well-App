import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/models/recall_attempt.dart';
import '../../../shared/widgets/app_card.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> with AutomaticKeepAliveClientMixin {
  final _memoryRepo = MemoryRepository();
  final _recallRepo = RecallRepository();

  int _attempts = 0;
  double _avgScore = 0;
  int _streak = 0;
  List<RecallAttempt> _recentAttempts = [];
  int _recallStreak = 0;

  @override
  bool get wantKeepAlive => false; // Allow refreshing when navigating back

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when navigating back to this screen
    _load();
  }

  void _load() {
    setState(() {
      final allAttempts = _recallRepo.getAllAttempts();
      _attempts = allAttempts.length;
      _avgScore = _recallRepo.getAverageScore();
      _streak = _calculateStreak();
      _recentAttempts = allAttempts.take(10).toList();
      _recallStreak = _calculateRecallStreak(allAttempts);
    });
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
      if (dates[i].difference(expectedDate).inDays == 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateRecallStreak(List<RecallAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    final days = attempts
        .map((a) => DateTime(a.attemptedAt.year, a.attemptedAt.month, a.attemptedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    for (var i = 0; i < days.length; i++) {
      final expected = todayStart.subtract(Duration(days: i));
      if (days[i].difference(expected).inDays == 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return GradientBackground(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _load();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track your memory training journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subtext,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Stats grid (2x2)
                  _buildStatsGrid(),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Score performance section removed
                  
                  // Weekly Accuracy
                  _buildWeeklyAccuracyCard(),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Recent Recalls and Insight
                  _buildRecentRecallsSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildInsightCard(),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Recent activity removed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Streak card removed in favor of 2x2 stats grid

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.xs, // 8
      mainAxisSpacing: AppSpacing.xs, // 8
      childAspectRatio: 1.3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _StatCard(
          icon: Icons.center_focus_strong,
          title: 'Total Recalls',
          value: '$_attempts',
          gradient: const [],
        ),
        _StatCard(
          icon: Icons.show_chart,
          title: 'Avg Score',
          value: _avgScore > 0 ? '${_avgScore.toStringAsFixed(0)}%' : '—',
          gradient: const [],
        ),
        _StatCard(
          icon: Icons.local_fire_department,
          title: 'Logging Streak',
          value: '${_streak} days',
          gradient: const [],
        ),
        _StatCard(
          icon: Icons.bolt,
          title: 'Recall Streak',
          value: '${_recallStreak} days',
          gradient: const [],
        ),
      ],
    );
  }

  // _buildScorePerformance removed

  Widget _buildWeeklyAccuracyCard() {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: i)));
    const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final counts = <DateTime, int>{};
    for (final day in last7Days) {
      counts[day] = _recentAttempts.where((a) =>
          a.attemptedAt.year == day.year &&
          a.attemptedAt.month == day.month &&
          a.attemptedAt.day == day.day).length;
    }

    return AppCard(
      style: AppCardStyle.lavender,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 20,
      child: SizedBox(
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientStart.withOpacity(0.3),
                      AppColors.gradientEnd.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Weekly Accuracy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(7, (i) {
              final day = last7Days.reversed.toList()[i];
              final count = counts[day] ?? 0;
              final barHeight = (count / 5.0) * 100; // scaled for reduced chart area
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Fixed chart area with bottom-aligned bars for consistent baseline
                    Container(
                      height: 120,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 18,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekdayLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ),
    );
  }

  // Success rate card removed

  Widget _buildRecentRecallsSection() {
    if (_recentAttempts.isEmpty) {
      return const SizedBox.shrink();
    }
    final latest = _recentAttempts.first;
    final percent = latest.score;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Recalls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Scheduled',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${latest.attemptedAt.month}/${latest.attemptedAt.day}, ${latest.attemptedAt.year}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent / 100.0,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.ctaPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Achievements section removed

  Widget _buildInsightCard() {
    return AppCard(
      style: AppCardStyle.bluePurple,
      borderRadius: 20,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Insight',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "You're doing great! Your recall accuracy is excellent. Consider increasing recall intervals.",
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildSuccessStat removed
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_chart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}










