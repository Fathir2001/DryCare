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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      ),
    );
    _fadeAnimations = _animationControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOut);
    }).toList();
    _slideAnimations = _animationControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 40),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    }).toList();

    _startPageAnimations();
  }

  void _startPageAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      _animationControllers[i].reset();
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _animationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _startPageAnimations();
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
            return FadeTransition(opacity: animation, child: child);
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
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
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
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated emoji
                          AnimatedBuilder(
                            animation: _animationControllers[0],
                            builder: (ctx, child) {
                              return Transform.translate(
                                offset: _slideAnimations[0].value,
                                child: Opacity(
                                  opacity: _fadeAnimations[0].value,
                                  child: child,
                                ),
                              );
                            },
                            child: index == 0
                                ? Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.deepPurple
                                              .withValues(alpha: 0.3),
                                          AppColors.dustyRose
                                              .withValues(alpha: 0.3),
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
                                          AppColors.deepPurple
                                              .withValues(alpha: 0.3),
                                          AppColors.dustyRose
                                              .withValues(alpha: 0.3),
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

                          // Title
                          AnimatedBuilder(
                            animation: _animationControllers[1],
                            builder: (ctx, child) {
                              return Transform.translate(
                                offset: _slideAnimations[1].value,
                                child: Opacity(
                                  opacity: _fadeAnimations[1].value,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  page.title,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
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
                          AnimatedBuilder(
                            animation: _animationControllers[2],
                            builder: (ctx, child) {
                              return Transform.translate(
                                offset: _slideAnimations[2].value,
                                child: Opacity(
                                  opacity: _fadeAnimations[2].value,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              page.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.6,
                                    fontSize: 15,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
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
