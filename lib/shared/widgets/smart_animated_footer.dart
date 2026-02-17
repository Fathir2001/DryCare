import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A smart animated bottom navigation bar inspired by the "organic blob" design.
/// The bar is a rounded pill shape. The active item has a circular bubble that
/// protrudes above the bar, connected by a smooth organic curve — like the
/// circle grew out of the bar.
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
      duration: const Duration(milliseconds: 500),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
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

  // ── Active icon center X for a given index ──
  double _centerXForIndex(int index, double barWidth, double barMarginH) {
    final innerWidth = barWidth - barMarginH * 2;
    final itemWidth = innerWidth / widget.items.length;
    return barMarginH + itemWidth * index + itemWidth / 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Bar sizing
    const barMarginH = 24.0;
    const barHeight = 62.0;
    const barRadius = 31.0;
    const circleRadius = 29.0;
    const circleRingWidth = 3.5;
    const circleOverlap = 16.0;

    // Colors
    final barColor = isDark ? const Color(0xFF1A1025) : const Color(0xFF2B2B38);
    final circleColor =
        isDark ? const Color(0xFF1A1025) : const Color(0xFF2B2B38);
    final ringColor = isDark ? const Color(0xFF3A2D4F) : Colors.white;
    final inactiveIconColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.55);

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, _) {
        final curvedProgress = CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeInOutCubic,
        ).value;

        final prevCX =
            _centerXForIndex(_previousIndex, screenWidth, barMarginH);
        final currCX =
            _centerXForIndex(widget.currentIndex, screenWidth, barMarginH);
        final activeCX = prevCX + (currCX - prevCX) * curvedProgress;

        // Circle center Y – sits on top of the bar with overlap
        const totalHeight = barHeight + circleRadius * 2 - circleOverlap + 10;
        const barTop = totalHeight - barHeight;
        const circleCY =
            barTop - circleRadius + circleOverlap + circleRingWidth;

        return SizedBox(
          height: totalHeight + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Bar background with organic notch ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                height: barHeight,
                child: CustomPaint(
                  painter: _OrganicBarPainter(
                    barMarginH: barMarginH,
                    barRadius: barRadius,
                    activeCenterX: activeCX,
                    circleRadius: circleRadius + circleRingWidth + 4,
                    barColor: barColor,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Organic ring + circle ──
              Positioned(
                left: activeCX - circleRadius - circleRingWidth,
                top: circleCY - circleRadius - circleRingWidth,
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: Size(
                      (circleRadius + circleRingWidth) * 2,
                      (circleRadius + circleRingWidth) * 2,
                    ),
                    painter: _CircleRingPainter(
                      ringColor: ringColor,
                      circleColor: circleColor,
                      ringWidth: circleRingWidth,
                    ),
                  ),
                ),
              ),

              // ── Active icon (gradient shader) ──
              Positioned(
                left: activeCX - circleRadius,
                top: circleCY - circleRadius,
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: circleRadius * 2,
                    height: circleRadius * 2,
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7B61FF),
                            Color(0xFF5DADE2),
                          ],
                        ).createShader(bounds),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            widget.items[widget.currentIndex].activeIcon,
                            key: ValueKey(widget.currentIndex),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Tap targets for all items ──
              Positioned(
                left: barMarginH,
                right: barMarginH,
                bottom: 6,
                height: barHeight,
                child: Row(
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
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: isSelected ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedScale(
                              scale: isSelected ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                widget.items[index].icon,
                                color: inactiveIconColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════
//  Organic bar painter — draws the pill bar
//  with a smooth semicircular notch cutout
// ═══════════════════════════════════════════
class _OrganicBarPainter extends CustomPainter {
  final double barMarginH;
  final double barRadius;
  final double activeCenterX;
  final double circleRadius;
  final Color barColor;
  final bool isDark;

  _OrganicBarPainter({
    required this.barMarginH,
    required this.barRadius,
    required this.activeCenterX,
    required this.circleRadius,
    required this.barColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final barLeft = barMarginH;
    final barRight = size.width - barMarginH;
    const barTop = 0.0;
    final barBottom = size.height;

    // Notch geometry — smooth semicircular cutout
    final notchR = circleRadius;

    // Build the pill-shaped bar path with notch
    final path = Path();

    // Start bottom-left → go clockwise
    path.moveTo(barLeft, barBottom - barRadius);

    // Bottom-left corner
    path.arcToPoint(
      Offset(barLeft + barRadius, barBottom),
      radius: Radius.circular(barRadius),
      clockwise: false,
    );

    // Bottom edge
    path.lineTo(barRight - barRadius, barBottom);

    // Bottom-right corner
    path.arcToPoint(
      Offset(barRight, barBottom - barRadius),
      radius: Radius.circular(barRadius),
      clockwise: false,
    );

    // Right edge
    path.lineTo(barRight, barTop + barRadius);

    // Top-right corner
    path.arcToPoint(
      Offset(barRight - barRadius, barTop),
      radius: Radius.circular(barRadius),
      clockwise: false,
    );

    // ── Top edge with smooth organic notch ──
    final notchRight = activeCenterX + notchR;
    final notchLeft = activeCenterX - notchR;

    // From top-right corner to notch right edge
    if (notchRight < barRight - barRadius) {
      path.lineTo(notchRight, barTop);
    }

    // Semicircular notch (arc going upward / counter-clockwise)
    path.arcTo(
      Rect.fromCircle(
        center: Offset(activeCenterX, barTop),
        radius: notchR,
      ),
      0,
      -math.pi,
      false,
    );

    // From notch left edge to top-left corner
    if (notchLeft > barLeft + barRadius) {
      path.lineTo(barLeft + barRadius, barTop);
    }

    // Top-left corner
    path.arcToPoint(
      Offset(barLeft, barTop + barRadius),
      radius: Radius.circular(barRadius),
      clockwise: false,
    );

    path.close();

    // Draw shadow, then bar
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OrganicBarPainter oldDelegate) {
    return oldDelegate.activeCenterX != activeCenterX ||
        oldDelegate.barColor != barColor;
  }
}

// ═══════════════════════════════════════════
//  Circle ring painter — outer ring + fill
// ═══════════════════════════════════════════
class _CircleRingPainter extends CustomPainter {
  final Color ringColor;
  final Color circleColor;
  final double ringWidth;

  _CircleRingPainter({
    required this.ringColor,
    required this.circleColor,
    required this.ringWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - ringWidth;

    // Ring
    canvas.drawCircle(
        center, outerRadius, Paint()..color = ringColor);
    // Inner circle
    canvas.drawCircle(
        center, innerRadius, Paint()..color = circleColor);
  }

  @override
  bool shouldRepaint(_CircleRingPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor ||
        oldDelegate.circleColor != circleColor;
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
