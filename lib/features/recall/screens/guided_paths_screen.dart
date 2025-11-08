import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/models/memory.dart';
import 'recall_quiz_screen.dart';

class GuidedPathsScreen extends StatefulWidget {
  const GuidedPathsScreen({super.key});

  @override
  State<GuidedPathsScreen> createState() => _GuidedPathsScreenState();
}

class _GuidedPathsScreenState extends State<GuidedPathsScreen> {
  final _memoryRepo = MemoryRepository();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guided Paths'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Focus your practice',
                style: TextStyle(color: AppColors.subtext),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPath(
                title: 'People',
                subtitle: 'Practice memories involving people',
                icon: Icons.people,
                onTap: _startPeople,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPath(
                title: 'Sensory',
                subtitle: 'Practice via tags or sensory cues',
                icon: Icons.center_focus_strong,
                onTap: _startSensory,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPath({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.subtext),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.subtext, size: 16),
        ],
      ),
    );
  }

  Future<void> _startPeople() async {
    final memories = _memoryRepo.getAll().where((m) => (m.who != null && m.who!.isNotEmpty)).toList();
    if (memories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No people-related memories yet'), backgroundColor: AppColors.warning),
      );
      return;
    }
    memories.shuffle();
    final Memory memory = memories.first;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecallQuizScreen(memory: memory, onlyWho: true),
      ),
    );
  }

  Future<void> _startSensory() async {
    // Simple first version: reuse tags with normal quiz
    final memories = _memoryRepo.getAll().where((m) => (m.tags != null && m.tags!.isNotEmpty)).toList();
    if (memories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tagged memories yet'), backgroundColor: AppColors.warning),
      );
      return;
    }
    memories.shuffle();
    final Memory memory = memories.first;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecallQuizScreen(memory: memory),
      ),
    );
  }
}







