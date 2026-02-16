import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useFullGradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.useFullGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: useFullGradient
            ? AppColors.primaryGradient
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.deepPurple.withValues(alpha: 0.5),
                        AppColors.darkBackground,
                        AppColors.darkBackground,
                      ]
                    : [
                        AppColors.softPeach.withValues(alpha: 0.3),
                        AppColors.lightBackground,
                        AppColors.lightBackground,
                      ],
              ),
      ),
      child: child,
    );
  }
}
