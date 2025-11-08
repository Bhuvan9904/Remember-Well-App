import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MoodSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Today',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodValue = index + 1;
            final emoji = ['😟', '😐', '😊', '😄', '🤩'][index];
            
            return InkWell(
              onTap: () => onChanged(moodValue),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: value == moodValue
                          ? AppColors.ctaPrimary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMoodLabel(moodValue),
                    style: TextStyle(
                      color: value == moodValue ? AppColors.ctaPrimary : AppColors.subtext,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getMoodLabel(int value) {
    switch (value) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return '';
    }
  }
}


