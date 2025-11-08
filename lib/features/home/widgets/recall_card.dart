import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/memory.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../features/recall/screens/recall_quiz_screen.dart';
import '../../../shared/widgets/app_card.dart';

class RecallCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;

  const RecallCard({
    super.key,
    required this.memory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get text snippet (first 50 chars)
    final snippet = memory.text.length > 50
        ? '${memory.text.substring(0, 50)}...'
        : memory.text;

    final VoidCallback handleTap = onTap ?? () {
      print('DEBUG: RecallCard - Default onTap used (no custom onTap provided)');
      print('DEBUG: Navigating directly to RecallQuizScreen');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecallQuizScreen(memory: memory),
        ),
      );
    };
    
    if (onTap != null) {
      print('DEBUG: RecallCard - Custom onTap provided, will use it');
    }

    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: handleTap,
      child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x8077218B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF77218B),
                  size: 20,
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      date_utils.DateUtils.formatDate(memory.createdAt),
                      style: const TextStyle(
                        color: AppColors.subtext,
                        fontSize: 11,
                      ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ctaPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Due',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.subtext,
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
