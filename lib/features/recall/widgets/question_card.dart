import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

enum QuestionType { fillIn, mcq, sensory }

class QuestionCard extends StatefulWidget {
  final QuestionType type;
  final String question;
  final List<String>? options;
  final ValueChanged<String> onAnswered;

  const QuestionCard({
    super.key,
    required this.type,
    required this.question,
    this.options,
    required this.onAnswered,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedAnswer;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB595D9),
            Color(0xFFD4A5C7),
            Color(0xFFE8BEC2),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.type == QuestionType.fillIn) _buildFillIn(),
          if (widget.type == QuestionType.mcq && widget.options != null)
            _buildMCQ(),
          if (widget.type == QuestionType.sensory) _buildSensory(),
        ],
      ),
    );
  }

  Widget _buildFillIn() {
    return TextField(
      controller: _textController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Type your answer...',
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.ctaPrimary, width: 2),
        ),
      ),
      onChanged: (value) {
        _selectedAnswer = value;
        widget.onAnswered(value);
      },
    );
  }

  Widget _buildMCQ() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.options!.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _selectedAnswer == option
                ? AppColors.ctaPrimary.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedAnswer == option
                  ? AppColors.ctaPrimary
                  : Colors.white.withOpacity(0.2),
              width: _selectedAnswer == option ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            value: option,
            groupValue: _selectedAnswer,
            onChanged: (value) {
              setState(() {
                _selectedAnswer = value;
              });
              if (value != null) {
                widget.onAnswered(value);
              }
            },
            activeColor: AppColors.ctaPrimary,
            dense: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSensory() {
    final sensoryOptions = ['smell', 'sound', 'taste', 'color', 'texture'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: sensoryOptions.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _selectedAnswer == option
                ? AppColors.ctaPrimary.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedAnswer == option
                  ? AppColors.ctaPrimary
                  : Colors.white.withOpacity(0.2),
              width: _selectedAnswer == option ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option.capitalize(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: option,
            groupValue: _selectedAnswer,
            onChanged: (value) {
              setState(() {
                _selectedAnswer = value;
              });
              if (value != null) {
                widget.onAnswered(value);
              }
            },
            activeColor: AppColors.ctaPrimary,
            dense: true,
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
