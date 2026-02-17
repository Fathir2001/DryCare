import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/smart_animated_footer.dart';
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
  late PageController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Track previous score for confetti
  int? _previousScore;
  bool _showConfetti = false;

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

  static const List<FooterItem> _footerItems = [
    FooterItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    FooterItem(
      icon: Icons.local_fire_department_outlined,
      activeIcon: Icons.local_fire_department_rounded,
      label: 'Tips',
    ),
    FooterItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Pulsing animation for score circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onFooterTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _checkScoreImprovement(int newScore) {
    if (_previousScore != null && newScore > _previousScore! + 5) {
      setState(() => _showConfetti = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    }
    _previousScore = newScore;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Swipeable screens
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDashboardContent(isDark),
                const TipsScreen(),
                const SettingsScreen(),
              ],
            ),
            // Confetti overlay
            if (_showConfetti) _buildConfettiOverlay(),
            // Dynamic Island floating at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: SmartAnimatedFooter(
                  currentIndex: _currentIndex,
                  items: _footerItems,
                  onTap: _onFooterTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return IgnorePointer(
      child: SizedBox.expand(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return CustomPaint(
              painter: _ConfettiPainter(progress: value),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(bool isDark) {
    final dashboard = ref.watch(dashboardProvider);
    final score = ref.watch(drynessScoreProvider);
    final level = AppUtils.getDrynessLevel(score);
    final levelColor = AppUtils.getDrynessColor(score);
    final userName = ref.watch(userNameProvider);
    final greeting = userName.isNotEmpty ? 'Hi, $userName! 👋' : 'Daily Care';

    // Check for score improvement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScoreImprovement(score);
    });

    // Determine active time period
    final hour = DateTime.now().hour;
    final isMorningActive = hour >= 5 && hour < 17;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) setState(() {});
        },
        color: AppColors.coral,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: Theme.of(context).textTheme.displayMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatDate(DateTime.now()),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    // Streak badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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

              // Skin level & progress ring with pulse
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Pulsing score circle
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: CircularPercentIndicator(
                            radius: 40,
                            lineWidth: 8,
                            percent:
                                dashboard.completionPercentage.clamp(0.0, 1.0),
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
                            animation: true,
                            animationDuration: 600,
                          ),
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
                    const SizedBox(height: 16),
                    // Sparkline progress trend
                    _SparklineWidget(
                      completion: dashboard.completionPercentage,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Water tracker with animated drops
              _WaterTrackerCard(
                waterIntake: dashboard.waterIntake,
                isDark: isDark,
                streakCount: dashboard.streakCount,
                onAdd: () => ref.read(dashboardProvider.notifier).addWater(),
                onRemove: () =>
                    ref.read(dashboardProvider.notifier).removeWater(),
              ),

              const SizedBox(height: 8),

              // Morning checklist with glow
              _AnimatedChecklist(
                emoji: '🌅',
                title: 'Morning Routine',
                items: _morningItems,
                checked: dashboard.morningChecklist,
                onToggle: (index) => ref
                    .read(dashboardProvider.notifier)
                    .toggleMorningItem(index),
                isDark: isDark,
                isActive: isMorningActive,
              ),

              const SizedBox(height: 8),

              // Night checklist with glow
              _AnimatedChecklist(
                emoji: '🌙',
                title: 'Night Routine',
                items: _nightItems,
                checked: dashboard.nightChecklist,
                onToggle: (index) =>
                    ref.read(dashboardProvider.notifier).toggleNightItem(index),
                isDark: isDark,
                isActive: !isMorningActive,
              ),

              // Padding for dynamic island
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sparkline Widget ─────────────────────────────────────────────────────────

class _SparklineWidget extends StatelessWidget {
  final double completion;
  final bool isDark;

  const _SparklineWidget({required this.completion, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Simulated 7-day trend - in a real app this would come from stored data
    final trend = [0.2, 0.35, 0.3, 0.5, 0.45, 0.6, completion];

    return SizedBox(
      height: 40,
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: _SparklinePainter(
          values: trend,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final bool isDark;

  _SparklinePainter({required this.values, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.coral.withValues(alpha: 0.3),
          AppColors.coral.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()..color = AppColors.coral;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (values.length - 1);
    final padding = 4.0;
    final chartHeight = size.height - padding * 2;

    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y = padding + chartHeight * (1 - values[i].clamp(0.0, 1.0));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = stepX * (i - 1);
        final prevY =
            padding + chartHeight * (1 - values[i - 1].clamp(0.0, 1.0));
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }

      if (i == values.length - 1) {
        // Current day dot
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
        canvas.drawCircle(
            Offset(x, y),
            6,
            Paint()
              ..color = AppColors.coral.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// ─── Water Tracker Card ───────────────────────────────────────────────────────

class _WaterTrackerCard extends StatelessWidget {
  final int waterIntake;
  final bool isDark;
  final int streakCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _WaterTrackerCard({
    required this.waterIntake,
    required this.isDark,
    required this.streakCount,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hydrationGoalMet = waterIntake >= 8;

    return GlassCard(
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
              Row(
                children: [
                  // Hydration streak indicator
                  if (hydrationGoalMet)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: Colors.lightBlueAccent, size: 14),
                          Text(
                            'Goal!',
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    '$waterIntake/8 glasses',
                    style: TextStyle(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated water drops
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(8, (i) {
              final isFilled = i < waterIntake;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('water_${i}_$isFilled'),
                  tween: Tween(begin: isFilled ? 0.0 : 1.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + i * 50),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: isFilled ? value : 1.0,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: isFilled
                        ? Colors.lightBlueAccent
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.deepPurple.withValues(alpha: 0.15)),
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
              _WaterButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRemove();
                },
                isDark: isDark,
              ),
              const SizedBox(width: 24),
              _WaterButton(
                icon: Icons.add_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onAdd();
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _WaterButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_WaterButton> createState() => _WaterButtonState();
}

class _WaterButtonState extends State<_WaterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: _tapAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _tapAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.deepPurple.withValues(alpha: 0.1),
          ),
          child: Icon(
            widget.icon,
            color: widget.isDark
                ? AppColors.textPrimary
                : AppColors.lightTextPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ─── Animated Checklist ───────────────────────────────────────────────────────

class _AnimatedChecklist extends StatelessWidget {
  final String emoji;
  final String title;
  final List<String> items;
  final List<bool> checked;
  final Function(int) onToggle;
  final bool isDark;
  final bool isActive;

  const _AnimatedChecklist({
    required this.emoji,
    required this.title,
    required this.items,
    required this.checked,
    required this.onToggle,
    required this.isDark,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = checked.where((e) => e).length;
    final progress = items.isEmpty ? 0.0 : completedCount / items.length;

    return GlassCard(
      borderColor: isActive
          ? AppColors.coral.withValues(alpha: isDark ? 0.4 : 0.25)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Glow effect for active time period
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: isActive
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coral.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          )
                        : null,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (isActive)
                        Text(
                          'Active now',
                          style: TextStyle(
                            color: AppColors.coral,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Progress ring around count
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.deepPurple.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        completedCount == items.length
                            ? AppColors.mildGreen
                            : AppColors.coral,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '$completedCount/${items.length}',
                      style: TextStyle(
                        color: completedCount == items.length
                            ? AppColors.mildGreen
                            : AppColors.coral,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (i) {
            final isChecked = i < checked.length && checked[i];
            return _AnimatedCheckItem(
              label: items[i],
              isChecked: isChecked,
              onToggle: () {
                HapticFeedback.selectionClick();
                onToggle(i);
              },
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }
}

class _AnimatedCheckItem extends StatefulWidget {
  final String label;
  final bool isChecked;
  final VoidCallback onToggle;
  final bool isDark;

  const _AnimatedCheckItem({
    required this.label,
    required this.isChecked,
    required this.onToggle,
    required this.isDark,
  });

  @override
  State<_AnimatedCheckItem> createState() => _AnimatedCheckItemState();
}

class _AnimatedCheckItemState extends State<_AnimatedCheckItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedCheckItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked && !oldWidget.isChecked) {
      _checkController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: widget.onToggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isChecked
                        ? AppColors.mildGreen
                        : (widget.isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.deepPurple.withValues(alpha: 0.2)),
                    width: 2,
                  ),
                  color: widget.isChecked
                      ? AppColors.mildGreen
                      : Colors.transparent,
                  boxShadow: widget.isChecked
                      ? [
                          BoxShadow(
                            color: AppColors.mildGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: widget.isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15,
                  decoration:
                      widget.isChecked ? TextDecoration.lineThrough : null,
                  color: widget.isChecked
                      ? (widget.isDark
                          ? AppColors.textSecondary.withValues(alpha: 0.5)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.5))
                      : (widget.isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary),
                ),
                child: Text(widget.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confetti Painter ─────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.coral,
      AppColors.softPeach,
      AppColors.dustyRose,
      AppColors.mildGreen,
      Colors.lightBlueAccent,
      AppColors.deepPurple,
    ];

    final paint = Paint();
    final rng = _SimpleRng(42);

    for (int i = 0; i < 60; i++) {
      final color = colors[i % colors.length];
      paint.color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));

      final startX = rng.next() * size.width;
      final startY = -20.0;
      final endY = size.height * (0.3 + rng.next() * 0.7);

      final x = startX + (rng.next() - 0.5) * 80 * progress;
      final y = startY + (endY - startY) * progress;
      final rotation = progress * 6.28 * (rng.next() - 0.5);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final w = 4.0 + rng.next() * 6;
      final h = 3.0 + rng.next() * 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Simple deterministic random for consistent confetti pattern
class _SimpleRng {
  int _state;
  _SimpleRng(this._state);

  double next() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state / 0x7fffffff;
  }
}
