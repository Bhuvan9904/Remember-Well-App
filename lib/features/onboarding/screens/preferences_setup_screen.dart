import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../data/repositories/preferences_repository.dart';

class PreferencesSetupScreen extends StatefulWidget {
  const PreferencesSetupScreen({super.key});

  @override
  State<PreferencesSetupScreen> createState() => _PreferencesSetupScreenState();
}

class _PreferencesSetupScreenState extends State<PreferencesSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: _PreferencesContent(),
        ),
      ),
    );
  }
}

class _PreferencesContent extends StatefulWidget {
  const _PreferencesContent();

  @override
  State<_PreferencesContent> createState() => _PreferencesContentState();
}

class _PreferencesContentState extends State<_PreferencesContent> {
  int _selectedInterval = AppConstants.defaultRecallInterval;
  bool _allowOverride = true;
  final _prefsRepo = PreferencesRepository();

  Future<void> _saveAndContinue() async {
    final prefs = _prefsRepo.get();
    prefs.defaultIntervalDays = _selectedInterval;
    prefs.allowPerMemoryOverride = _allowOverride;
    prefs.onboardingDone = true;
    await _prefsRepo.set(prefs);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your memory training experience',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Default Recall Interval Section
          const Text(
            'Default Recall Interval',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Interval selector
          AppCard(
            style: AppCardStyle.lavender,
            borderRadius: 20,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3 days')),
                ButtonSegment(value: 5, label: Text('5 days')),
                ButtonSegment(value: 7, label: Text('7 days')),
                ButtonSegment(value: 10, label: Text('10 days')),
              ],
              selected: {_selectedInterval},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedInterval = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.ctaSecondary,
                backgroundColor: Colors.transparent,
                selectedForegroundColor: Colors.white,
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                minimumSize: const Size(0, 40),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Allow per-memory override Section
          AppCard(
            style: AppCardStyle.lavender,
            borderRadius: 20,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allow per-memory override',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set custom intervals for individual memories',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Switch(
                  value: _allowOverride,
                  onChanged: (value) {
                    setState(() {
                      _allowOverride = value;
                    });
                  },
                  activeColor: AppColors.ctaPrimary,
                  activeTrackColor: AppColors.ctaPrimary.withOpacity(0.5),
                  inactiveThumbColor: Colors.white.withOpacity(0.5),
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          CustomButton(
            text: 'Get Started',
            onPressed: _saveAndContinue,
            isExpanded: true,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}


