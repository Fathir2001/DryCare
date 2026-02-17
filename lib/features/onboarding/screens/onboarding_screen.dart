import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../questionnaire/screens/questionnaire_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Incremented on every page change to reset TweenAnimationBuilders.
  int _animationKey = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      emoji: '✨',
      title: 'Welcome to DryCare',
      subtitle: 'Your personal dry skin care companion',
      description:
          'Understand your skin better and build a daily routine designed just for you.',
    ),
    OnboardingPageData(
      emoji: '📋',
      title: 'Smart Skin Assessment',
      subtitle: 'Quick & personalized analysis',
      description:
          'Answer 10 simple questions and get a personalized skincare plan based on your lifestyle and habits.',
    ),
    OnboardingPageData(
      emoji: '💧',
      title: 'Daily Care Tracking',
      subtitle: 'Build healthy skin habits',
      description:
          'Track your hydration, follow morning & night routines, and watch your skin improve day by day.',
    ),
    OnboardingPageData(
      emoji: '🔒',
      title: '100% Private & Offline',
      subtitle: 'Your data stays on your device',
      description:
          'Everything works offline. No accounts, no cloud, no tracking. Your skin, your privacy.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _animationKey++;
    });
  }

  Future<void> _completeOnboarding() async {
    final repo = ref.read(localStorageProvider);
    await repo.setOnboardingCompleted();
    ref.read(onboardingCompletedProvider.notifier).state = true;

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const QuestionnaireScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : const SizedBox(height: 48),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      key: ValueKey('page_${index}_$_animationKey'),
                      page: _pages[index],
                      isFirstPage: index == 0,
                    );
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotColor: AppColors.dustyRose.withValues(alpha: 0.3),
                        activeDotColor: AppColors.coral,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button
                    GradientButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Start Assessment'
                          : 'Next',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.arrow_forward_rounded
                          : null,
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each page manages its own staggered entrance animation independently,
/// so swiping away doesn't break the outgoing page's visuals.
class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData page;
  final bool isFirstPage;

  const _OnboardingPage({
    super.key,
    required this.page,
    this.isFirstPage = false,
  });

  Widget _animatedEntry(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji / Logo
          _animatedEntry(
            0,
            isFirstPage
                ? Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.3),
                          AppColors.dustyRose.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.3),
                          AppColors.dustyRose.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        page.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 48),

          // Title + subtitle
          _animatedEntry(
            1,
            Column(
              children: [
                Text(
                  page.title,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.coral,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          _animatedEntry(
            2,
            Text(
              page.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 15,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;

  const OnboardingPageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
