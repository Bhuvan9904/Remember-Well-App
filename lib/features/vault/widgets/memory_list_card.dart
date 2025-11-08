import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/memory.dart';
import '../../../shared/widgets/app_card.dart';

class MemoryListCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;

  const MemoryListCard({
    super.key,
    required this.memory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final snippet = memory.text.length > 60
        ? '${memory.text.substring(0, 60)}...'
        : memory.text;

    // Calculate days ago
    final daysAgo = DateTime.now().difference(memory.createdAt).inDays;
    final relativeTime = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '$daysAgo days ago';

    // Build metadata line 2: Who
    final metadataLine2 = memory.who ?? '';

    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 16,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon on the left
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: memory.mood != null
                      ? Text(
                          _getMoodEmoji(memory.mood!),
                          style: const TextStyle(fontSize: 24),
                        )
                      : const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content in the middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        snippet,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Metadata line 1: Days ago
                      Text(
                        relativeTime,
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 13,
                        ),
                      ),
                      // Metadata line 2: Who • Place
                      if (metadataLine2.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          metadataLine2,
                          style: const TextStyle(
                            color: AppColors.subtext,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      // Tags - always show if available
                      if (memory.tags != null && memory.tags!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: memory.tags!.map((tag) {
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
                                  fontSize: 11,
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
                // Chevron icon on the right
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.subtext,
                    size: 20,
                  ),
                ),
              ],
            ),
    );
  }

  String _getMoodEmoji(int mood) {
    final emojis = ['', '😟', '😐', '😊', '😄', '🤩'];
    return emojis[mood];
  }
}
