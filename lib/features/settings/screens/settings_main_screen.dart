import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../data/models/preferences.dart';
import '../../../shared/widgets/app_card.dart';
import 'premium_screen.dart';

class SettingsMainScreen extends StatefulWidget {
  const SettingsMainScreen({super.key});

  @override
  State<SettingsMainScreen> createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> {
  final _prefsRepo = PreferencesRepository();
  late Preferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = _prefsRepo.get();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your preferences and account',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Premium banner (optional placeholder)
                _buildPremiumBanner(),
                const SizedBox(height: AppSpacing.xl),
                
                // Recall Settings Section
                _buildSectionHeader('Recall & Reminders', Icons.psychology),
                const SizedBox(height: AppSpacing.md),
                _buildRecallSettingsCard(),
                const SizedBox(height: AppSpacing.xl),

                _buildSectionHeader('About & Help', Icons.info),
                const SizedBox(height: AppSpacing.md),
                _buildAboutCard(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text('Unlock unlimited memories, all recall modes, analytics, and more', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.gradientEnd,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('View Plans'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildAppInfoCard removed

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientStart.withOpacity(0.2),
                AppColors.gradientEnd.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.gradientStart,
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildRecallSettingsCard() {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 20,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Default Interval Setting
          _buildSettingItem(
            icon: Icons.timer,
            title: 'Default Interval',
            subtitle: 'How often to review memories',
            child: _buildIntervalSelector(),
          ),
          const Divider(color: Colors.white24),
          
          // Per-memory Override
          _buildSettingSwitch(
            icon: Icons.tune,
            title: 'Per-Memory Override',
            subtitle: 'Allow custom intervals per memory',
            value: _prefs.allowPerMemoryOverride,
            onChanged: (v) => setState(() => _prefs.allowPerMemoryOverride = v),
          ),
          const Divider(color: Colors.white24),
          
          // Adaptive Difficulty
          _buildSettingSwitch(
            icon: Icons.auto_graph,
            title: 'Adaptive Difficulty',
            subtitle: 'Adjust intervals based on performance',
            value: _prefs.adaptiveEnabled,
            onChanged: (v) => setState(() => _prefs.adaptiveEnabled = v),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gradientStart.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gradientStart.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _prefs.defaultIntervalDays,
          dropdownColor: Colors.black.withOpacity(0.9),
          style: const TextStyle(color: Colors.white),
          items: const [3, 5, 7, 10, 14]
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppColors.subtext),
                        const SizedBox(width: 8),
                        Text('$e days'),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _prefs.defaultIntervalDays = v ?? 3),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return AppCard(
      style: AppCardStyle.lavender,
      borderRadius: 20,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.copyright,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          const Divider(color: Colors.white24),
          _buildInfoItem(
            icon: Icons.code,
            title: 'Built with',
            subtitle: 'Flutter',
          ),
        ],
      ),
    );
  }


  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientStart.withOpacity(0.2),
                  AppColors.gradientEnd.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.subtext, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientStart.withOpacity(0.2),
                  AppColors.gradientEnd.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.subtext, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.ctaPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradientStart.withOpacity(0.2),
                  AppColors.gradientEnd.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.subtext, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
