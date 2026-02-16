import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = ref.read(themeProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Customize your experience',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // Appearance section
            _buildSectionHeader(context, 'Appearance'),

            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.3),
                          AppColors.dustyRose.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          isDark ? 'Dark theme active' : 'Light theme active',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data section
            _buildSectionHeader(context, 'Data'),

            GlassCard(
              onTap: () => _showResetDialog(context, ref),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.severeRed.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.severeRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reset All Data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Clear questionnaire and tracking data',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),

            GlassCard(
              onTap: () => _showRetakeDialog(context, ref),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.coral.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retake Assessment',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Start the skin assessment over',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Legal section
            _buildSectionHeader(context, 'Legal'),

            GlassCard(
              onTap: () => _showInfoSheet(
                context,
                'Privacy Policy',
                AppConstants.privacyPolicy,
                Icons.privacy_tip_rounded,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.3),
                          AppColors.dustyRose.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),

            GlassCard(
              onTap: () => _showInfoSheet(
                context,
                'Medical Disclaimer',
                AppConstants.medicalDisclaimer,
                Icons.medical_information_rounded,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.3),
                          AppColors.dustyRose.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_information_rounded,
                      color: AppColors.coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Medical Disclaimer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} – ${AppConstants.appTagline}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Made with ❤️ for your skin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.coral,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Reset All Data?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          'This will clear your questionnaire results, daily tracking data, and streak. This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(localStorageProvider);
              await repo.resetAllData();
              ref.read(onboardingCompletedProvider.notifier).state = false;
              ref.read(questionnaireCompletedProvider.notifier).state = false;
              ref.read(drynessScoreProvider.notifier).state = 0;

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.severeRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRetakeDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Retake Assessment?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          'This will restart the skin assessment questionnaire. Your daily tracking data will be preserved.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                ),
              );
            },
            child: const Text(
              'Retake',
              style: TextStyle(
                color: AppColors.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.deepPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(icon, color: AppColors.coral, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.7,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
