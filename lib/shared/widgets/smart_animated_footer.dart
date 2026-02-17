import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// A Dynamic Island style bottom navigation bar.
/// Compact pill shape that expands on tap and shrinks back.
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
  late AnimationController _expandController;
  late AnimationController _iconSwapController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconFadeAnimation;
  bool _isExpanded = false;

  // Sizing constants
  static const double _collapsedWidth = 160.0;
  static const double _expandedWidth = 280.0;
  static const double _barHeight = 52.0;
  static const double _barRadius = 26.0;
  static const double _iconSize = 22.0;
  static const double _activeIconSize = 24.0;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 600),
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );

    _iconSwapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _iconFadeAnimation = CurvedAnimation(
      parent: _iconSwapController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(SmartAnimatedFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _triggerExpand();
      _iconSwapController.forward(from: 0);
    }
  }

  void _triggerExpand() {
    if (_isExpanded) return;
    setState(() => _isExpanded = true);
    _expandController.forward();

    // Auto-shrink after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _expandController.reverse().then((_) {
          if (mounted) setState(() => _isExpanded = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    _iconSwapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic Island is always dark, like iPhone's Dynamic Island
    final barColor = isDark
        ? const Color(0xFF1C1C1E) // near-black in dark mode
        : const Color(0xFF2C2C2E); // dark charcoal in light mode
    final activeColor = isDark ? AppColors.coral : AppColors.coral;
    final activeAccent = isDark ? AppColors.softPeach : AppColors.dustyRose;
    final inactiveColor = Colors.white.withValues(alpha: 0.5);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.5 : 0.15);
    final activeDotColor = activeColor;

    return SizedBox(
      height: _barHeight + 24,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final currentWidth = _collapsedWidth +
              (_expandedWidth - _collapsedWidth) * _expandAnimation.value;

          return Center(
            child: Container(
              width: currentWidth,
              height: _barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(_barRadius),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                  if (isDark)
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_barRadius),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.items.length, (index) {
                    final isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (index != widget.currentIndex) {
                            HapticFeedback.lightImpact();
                            widget.onTap(index);
                          } else {
                            _triggerExpand();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: _DynamicIslandItem(
                          icon: widget.items[index].icon,
                          activeIcon: widget.items[index].activeIcon,
                          label: widget.items[index].label,
                          isSelected: isSelected,
                          expandProgress: _expandAnimation.value,
                          activeColor: activeColor,
                          activeAccent: activeAccent,
                          inactiveColor: inactiveColor,
                          dotColor: activeDotColor,
                          iconSize: isSelected ? _activeIconSize : _iconSize,
                          iconFadeAnimation: _iconFadeAnimation,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DynamicIslandItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final double expandProgress;
  final Color activeColor;
  final Color activeAccent;
  final Color inactiveColor;
  final Color dotColor;
  final double iconSize;
  final Animation<double> iconFadeAnimation;

  const _DynamicIslandItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.expandProgress,
    required this.activeColor,
    required this.activeAccent,
    required this.inactiveColor,
    required this.dotColor,
    required this.iconSize,
    required this.iconFadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow effect for active
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(isSelected ? 6 : 4),
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor.withValues(alpha: 0.2),
                  )
                : null,
            child: ShaderMask(
              shaderCallback: (bounds) {
                if (isSelected) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [activeColor, activeAccent],
                  ).createShader(bounds);
                }
                return LinearGradient(
                  colors: [inactiveColor, inactiveColor],
                ).createShader(bounds);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey('${isSelected}_$icon'),
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),

          // Animated dot indicator below active icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isSelected ? 4.0 : 0.0,
            height: isSelected ? 4.0 : 0.0,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Footer item data class
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
