import 'package:flutter/material.dart';
import '../../../data/models/memory.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart' as date_utils;

class WrongEntriesReviewScreen extends StatefulWidget {
  final List<Memory> memories;

  const WrongEntriesReviewScreen({super.key, required this.memories});

  @override
  State<WrongEntriesReviewScreen> createState() => _WrongEntriesReviewScreenState();
}

class _WrongEntriesReviewScreenState extends State<WrongEntriesReviewScreen> {
  int _index = 0;

  void _next() {
    if (_index < widget.memories.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memories[_index];
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Review ${_index + 1}/${widget.memories.length}')
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppCard(
                style: AppCardStyle.lavender,
                borderRadius: 16,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      date_utils.DateUtils.formatDate(memory.createdAt),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Text
              AppCard(
                style: AppCardStyle.lavender,
                borderRadius: 16,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  memory.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ),

              if ((memory.who ?? '').isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _infoCard(Icons.person, 'Who', memory.who!),
              ],
              if ((memory.associations ?? '').isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _infoCard(Icons.link, 'Associations / Cues', memory.associations!),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index == 0 ? null : _prev,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ctaPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_index == widget.memories.length - 1 ? 'Done' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




