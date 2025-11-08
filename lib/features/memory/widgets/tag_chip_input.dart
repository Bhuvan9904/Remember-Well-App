import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class TagChipInput extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;

  const TagChipInput({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<TagChipInput> createState() => _TagChipInputState();
}

class _TagChipInputState extends State<TagChipInput> {
  final _controller = TextEditingController();

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;
    final trimmedTag = tag.trim().toLowerCase();
    
    if (widget.tags.length >= AppConstants.maxTagsPerMemory) {
      _controller.clear();
      return;
    }
    
    if (trimmedTag.length > AppConstants.maxTagLength) {
      _controller.clear();
      return;
    }
    
    if (widget.tags.contains(trimmedTag)) {
      _controller.clear();
      return;
    }
    
    final newTags = List<String>.from(widget.tags)..add(trimmedTag);
    widget.onChanged(newTags);
    _controller.clear();
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(newTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add tag (max ${AppConstants.maxTagsPerMemory})',
            hintStyle: const TextStyle(color: AppColors.subtext),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.ctaPrimary),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppColors.gradientStart.withOpacity(0.3),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}


