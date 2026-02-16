import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../settings/screens/settings_screen.dart';
import '../../tips/screens/tips_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  static const List<String> _morningItems = [
    'Gentle cleanser',
    'Hydrating toner',
    'Vitamin C serum',
    'Moisturizer',
    'Sunscreen SPF 30+',
  ];

  static const List<String> _nightItems = [
    'Remove makeup/sunscreen',
    'Gentle cleanser',
    'Hydrating serum',
    'Eye cream',
    'Night moisturizer',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      _buildDashboardContent(isDark),
      const TipsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: GradientBackground(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, isDark),
                _buildNavItem(Icons.auto_stories_rounded, 'Tips', 1, isDark),
                _buildNavItem(Icons.settings_rounded, 'Settings', 2, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.coral.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.coral
                  : (isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.coral
                    : (isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(bool isDark) {
    final dashboard = ref.watch(dashboardProvider);
    final score = ref.watch(drynessScoreProvider);
    final level = AppUtils.getDrynessLevel(score);
    final levelColor = AppUtils.getDrynessColor(score);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Care',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils.formatDate(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  // Streak badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.coralGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${dashboard.streakCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Skin level & progress ring
            GlassCard(
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 40,
                    lineWidth: 8,
                    percent: dashboard.completionPercentage.clamp(0.0, 1.0),
                    center: Text(
                      '${(dashboard.completionPercentage * 100).round()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    progressColor: AppColors.coral,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.deepPurple.withValues(alpha: 0.1),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: levelColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                level,
                                style: TextStyle(
                                  color: levelColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete your routine for healthier skin!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Water tracker
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'Water Intake',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Text(
                        '${dashboard.waterIntake}/8 glasses',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Water drop visual
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (i) {
                      final isFilled = i < dashboard.waterIntake;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.water_drop_rounded,
                            color: isFilled
                                ? Colors.lightBlueAccent
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : AppColors.deepPurple
                                        .withValues(alpha: 0.15)),
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWaterButton(
                        Icons.remove_rounded,
                        () =>
                            ref.read(dashboardProvider.notifier).removeWater(),
                        isDark,
                      ),
                      const SizedBox(width: 24),
                      _buildWaterButton(
                        Icons.add_rounded,
                        () => ref.read(dashboardProvider.notifier).addWater(),
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Morning checklist
            _buildChecklist(
              '🌅',
              'Morning Routine',
              _morningItems,
              dashboard.morningChecklist,
              (index) =>
                  ref.read(dashboardProvider.notifier).toggleMorningItem(index),
              isDark,
            ),

            const SizedBox(height: 8),

            // Night checklist
            _buildChecklist(
              '🌙',
              'Night Routine',
              _nightItems,
              dashboard.nightChecklist,
              (index) =>
                  ref.read(dashboardProvider.notifier).toggleNightItem(index),
              isDark,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.deepPurple.withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildChecklist(
    String emoji,
    String title,
    List<String> items,
    List<bool> checked,
    Function(int) onToggle,
    bool isDark,
  ) {
    final completedCount = checked.where((e) => e).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completedCount == items.length
                      ? AppColors.mildGreen.withValues(alpha: 0.2)
                      : AppColors.coral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/${items.length}',
                  style: TextStyle(
                    color: completedCount == items.length
                        ? AppColors.mildGreen
                        : AppColors.coral,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (i) {
            final isChecked = i < checked.length && checked[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onToggle(i),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked
                              ? AppColors.mildGreen
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.deepPurple
                                      .withValues(alpha: 0.2)),
                          width: 2,
                        ),
                        color: isChecked
                            ? AppColors.mildGreen
                            : Colors.transparent,
                      ),
                      child: isChecked
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        items[i],
                        style: TextStyle(
                          fontSize: 15,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked
                              ? (isDark
                                  ? AppColors.textSecondary
                                      .withValues(alpha: 0.5)
                                  : AppColors.lightTextSecondary
                                      .withValues(alpha: 0.5))
                              : (isDark
                                  ? AppColors.textPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
