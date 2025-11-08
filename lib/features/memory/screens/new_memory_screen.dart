import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/repositories/recall_repository.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../data/models/memory.dart';
import '../../../data/models/recall_plan.dart';
import '../../../data/models/recall_status.dart';
import '../widgets/mood_slider.dart';
import '../widgets/tag_chip_input.dart';

class NewMemoryScreen extends StatefulWidget {
  const NewMemoryScreen({super.key});

  @override
  State<NewMemoryScreen> createState() => _NewMemoryScreenState();
}

class _NewMemoryScreenState extends State<NewMemoryScreen> {
  final _textController = TextEditingController();
  final _whoController = TextEditingController();
  final _associationsController = TextEditingController();
  
  final _memoryRepo = MemoryRepository();
  final _recallRepo = RecallRepository();
  final _prefsRepo = PreferencesRepository();
  
  List<String> _tags = [];
  int? _mood;
  int? _customInterval;
  
  bool _useCustomInterval = false;

  @override
  void dispose() {
    _textController.dispose();
    _whoController.dispose();
    _associationsController.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_textController.text.trim().length < AppConstants.minMemoryTextLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory text must be at least 3 characters')),
      );
      return;
    }

    // Create memory
    final memory = Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
      createdAt: DateTime.now(),
      tags: _tags.isEmpty ? null : _tags,
      who: _whoController.text.trim().isEmpty ? null : _whoController.text.trim(),
      associations: _associationsController.text.trim().isEmpty ? null : _associationsController.text.trim(),
      mood: _mood,
      photoPath: null,
      audioPath: null,
      customIntervalDays: _useCustomInterval ? _customInterval : null,
      useAdaptive: true,
    );

    // Save memory
    await _memoryRepo.create(memory);

    // Create recall plan
    final prefs = _prefsRepo.get();
    final interval = _useCustomInterval ? _customInterval! : prefs.defaultIntervalDays;
    
    final recallPlan = RecallPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memoryId: memory.id,
      dueAt: DateTime.now().add(Duration(days: interval)),
      intervalDays: interval,
      status: RecallStatus.pending,
      createdAt: DateTime.now(),
      snoozeCount: 0,
    );

    await _recallRepo.createPlan(recallPlan);

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to refresh home
    }
  }


  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Memory'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required: What happened today?
              CustomTextField(
                controller: _textController,
                label: 'What happened today? *',
                hint: 'Describe your memory...',
                maxLines: 8,
                maxLength: AppConstants.maxMemoryTextLength,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Optional: Who?
              CustomTextField(
                controller: _whoController,
                label: 'Who?',
                hint: 'Person name or contact',
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Mood
              MoodSlider(
                value: _mood ?? 3,
                onChanged: (value) => setState(() => _mood = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Tags
              TagChipInput(
                tags: _tags,
                onChanged: (tags) => setState(() => _tags = tags),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Associations
              CustomTextField(
                controller: _associationsController,
                label: 'Associations/Cues',
                hint: 'e.g., Coffee mug = John',
              ),
              const SizedBox(height: 8),
              const Text(
                'What visual or sensory cues can help you remember?',
                style: TextStyle(
                  color: AppColors.subtext,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Recall Interval
              SwitchListTile(
                title: const Text(
                  'Use custom interval',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Override default recall timing',
                  style: TextStyle(color: AppColors.subtext, fontSize: 14),
                ),
                value: _useCustomInterval,
                onChanged: (value) => setState(() => _useCustomInterval = value),
              ),
              if (_useCustomInterval) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _customInterval?.toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Days (${AppConstants.minCustomInterval}-${AppConstants.maxCustomInterval})',
                    labelStyle: const TextStyle(color: AppColors.subtext),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _customInterval = int.tryParse(value);
                    });
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              
              // Save button
              CustomButton(
                text: 'Save Memory',
                onPressed: _saveMemory,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}