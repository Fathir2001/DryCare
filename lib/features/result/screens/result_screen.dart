import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final int score;

  const ResultScreen({super.key, required this.score});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnimation;
  late AnimationController _contentAnimController;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation =
        Tween<double>(begin: 0, end: widget.score / 30).animate(CurvedAnimation(
      parent: _scoreAnimController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animations sequentially
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scoreAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _contentAnimController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = AppUtils.getDrynessLevel(widget.score);
    final color = AppUtils.getDrynessColor(widget.score);
    final explanation = AppUtils.getDrynessExplanation(widget.score);
    final motivation = AppUtils.getMotivationalMessage(widget.score);
    final routine = AppUtils.getSkincareRoutine(widget.score);
    final hydration = AppUtils.getHydrationAdvice(widget.score);
    final userName = ref.watch(userNameProvider);
    final personalTitle = userName.isNotEmpty
        ? '$userName, your skin is:'
        : 'Your skin dryness level:';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Score circle
                AnimatedBuilder(
                  animation: _scoreAnimController,
                  builder: (context, child) {
                    return CircularPercentIndicator(
                      radius: 80,
                      lineWidth: 10,
                      percent: _scoreAnimation.value,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_scoreAnimation.value * 30).round()}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Text(
                            'of 30',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      progressColor: color,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.deepPurple.withValues(alpha: 0.1),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: false,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Personalized title
                Text(
                  personalTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Level title
                Text(
                  level,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                Icon(
                  AppUtils.getDrynessIcon(widget.score),
                  size: 48,
                  color: color,
                ),

                const SizedBox(height: 24),

                // Content sections with fade-in
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _contentAnimController,
                    curve: Curves.easeOut,
                  ),
                  child: Column(
                    children: [
                      // Explanation
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: AppColors.coral, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'About Your Skin',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              explanation,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.6,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Skincare routine
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🧴',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Skincare Routine',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...routine.map((step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.coral,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      // Hydration advice
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💧',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  'Hydration Tips',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...hydration.map((tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.water_drop_rounded,
                                        color: Colors.lightBlueAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      // Motivational message
                      GlassCard(
                        borderColor: color.withValues(alpha: 0.5),
                        child: Center(
                          child: Text(
                            motivation,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  height: 1.6,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Go to Dashboard button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GradientButton(
                          text: 'Go to Dashboard',
                          icon: Icons.dashboard_rounded,
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const DashboardScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.15),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 600),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
