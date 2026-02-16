import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// A smart animated bottom navigation bar with a wavy notch that follows
/// the selected tab. The active icon floats above the bar inside a
/// glowing circle, and a fluid curve wraps around it.
class SmartAnimatedFooter extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FooterItem> items;

  const SmartAnimatedFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<SmartAnimatedFooter> createState() => _SmartAnimatedFooterState();
}

class _SmartAnimatedFooterState extends State<SmartAnimatedFooter>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(SmartAnimatedFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _slideController.forward(from: 0);
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? const Color(0xFF1E1230)
        : const Color(0xFFF5F0F8);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : AppColors.deepPurple.withValues(alpha: 0.12);

    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 6),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Main bar with wave cutout ──
          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 70),
                painter: _WaveNavPainter(
                  currentIndex: widget.currentIndex,
                  previousIndex: _previousIndex,
                  progress: CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeInOutCubic,
                  ).value,
                  itemCount: widget.items.length,
                  color: barColor,
                  shadowColor: shadowColor,
                  isDark: isDark,
                ),
              );
            },
          ),

          // ── Tab icons ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.items.length, (index) {
                final isSelected = widget.currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (index != widget.currentIndex) {
                        HapticFeedback.lightImpact();
                        widget.onTap(index);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: _buildTabItem(index, isSelected, isDark),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, bool isSelected, bool isDark) {
    final item = widget.items[index];

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        // Only bounce the currently selected item
        final scale = isSelected ? _bounceAnimation.value : 1.0;
        final yOffset = isSelected ? -24.0 : 0.0;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with circle background for selected
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            width: isSelected ? 54 : 40,
            height: isSelected ? 54 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.deepPurple,
                        AppColors.dustyRose,
                      ],
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.deepPurple.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary),
              size: isSelected ? 26 : 22,
            ),
          ),

          // Label with smooth fade
          AnimatedOpacity(
            opacity: isSelected ? 0.0 : 0.7,
            duration: const Duration(milliseconds: 250),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: isSelected ? 0 : 18,
              child: isSelected
                  ? const SizedBox.shrink()
                  : Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  Custom painter for the wave notch
// ═══════════════════════════════════════════
class _WaveNavPainter extends CustomPainter {
  final int currentIndex;
  final int previousIndex;
  final double progress;
  final int itemCount;
  final Color color;
  final Color shadowColor;
  final bool isDark;

  _WaveNavPainter({
    required this.currentIndex,
    required this.previousIndex,
    required this.progress,
    required this.itemCount,
    required this.color,
    required this.shadowColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final itemWidth = size.width / itemCount;

    // Interpolate notch center between previous and current
    final prevCenter = itemWidth * previousIndex + itemWidth / 2;
    final currCenter = itemWidth * currentIndex + itemWidth / 2;
    final notchCenter = prevCenter + (currCenter - prevCenter) * progress;

    final notchRadius = 34.0;
    final notchDepth = 22.0;

    final path = Path();
    path.moveTo(0, notchDepth);

    // Left side up to notch curve
    final leftStart = notchCenter - notchRadius - 14;
    path.lineTo(leftStart.clamp(0, size.width), notchDepth);

    // Wave notch (cubic bézier curves)
    path.cubicTo(
      notchCenter - notchRadius + 6, notchDepth,  // control 1
      notchCenter - notchRadius + 4, 0,            // control 2
      notchCenter, 0,                               // end
    );
    path.cubicTo(
      notchCenter + notchRadius - 4, 0,            // control 1
      notchCenter + notchRadius - 6, notchDepth,   // control 2
      (notchCenter + notchRadius + 14).clamp(0, size.width), notchDepth, // end
    );

    // Right side
    path.lineTo(size.width, notchDepth);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow first
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
    // Draw bar
    canvas.drawPath(path, paint);

    // Draw subtle top border
    final borderPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : AppColors.deepPurple.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final borderPath = Path();
    borderPath.moveTo(0, notchDepth);
    borderPath.lineTo(leftStart.clamp(0, size.width), notchDepth);
    borderPath.cubicTo(
      notchCenter - notchRadius + 6, notchDepth,
      notchCenter - notchRadius + 4, 0,
      notchCenter, 0,
    );
    borderPath.cubicTo(
      notchCenter + notchRadius - 4, 0,
      notchCenter + notchRadius - 6, notchDepth,
      (notchCenter + notchRadius + 14).clamp(0, size.width), notchDepth,
    );
    borderPath.lineTo(size.width, notchDepth);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(_WaveNavPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.color != color;
  }
}

// ═══════════════════════════════════════════
//  Footer item data class
// ═══════════════════════════════════════════
class FooterItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FooterItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
