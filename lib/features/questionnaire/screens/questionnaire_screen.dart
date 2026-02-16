import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/questionnaire_datasource.dart';
import '../../../data/models/question_model.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../result/screens/result_screen.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen>
    with TickerProviderStateMixin {
  // ── Profile step ──
  bool _showIntro = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentQuestion = 0;
  final List<int> _answers = List.filled(10, -1);
  bool _showFunFact = false;
  bool _isTransitioning = false;

  final List<QuestionModel> _questions = QuestionnaireDataSource.questions;

  // ── Per-question accent colours ──
  static const List<Color> _accentColors = [
    Color(0xFF6C63FF), // 🧼 Vibrant purple
    Color(0xFFFF8C42), // 🍂 Warm orange
    Color(0xFFE84393), // 😣 Hot pink
    Color(0xFF0984E3), // 💧 Ocean blue
    Color(0xFF00B894), // 🧴 Emerald green
    Color(0xFF6C5CE7), // 🚿 Electric indigo
    Color(0xFFFFC312), // 🌤 Golden yellow
    Color(0xFFFF6B6B), // ☀️ Coral red
    Color(0xFF9B59B6), // 😴 Soft purple
    Color(0xFF00CEC9), // 🥒 Teal cyan
  ];

  // ── Fun facts shown after answering each question ──
  static const List<String> _funFacts = [
    '💡 Hot water strips natural oils from your skin in just 10 minutes!',
    '💡 Your skin sheds about 30,000+ dead cells every single hour!',
    '💡 Scratching dry skin causes micro-tears that worsen dryness!',
    '💡 Your skin is 64% water – hydration keeps it plump & glowing!',
    '💡 Moisturizing within 60s of bathing locks in 10× more moisture!',
    '💡 Hot showers damage your skin barrier in as little as 5 minutes!',
    '💡 Cold air holds 50% less moisture – that\'s why winter skin is drier!',
    '💡 UV rays penetrate clouds & windows – daily SPF is a must!',
    '💡 Skin repairs itself during deep sleep – beauty sleep is real!',
    '💡 Cucumbers are 96% water – nature\'s best hydrating snack!',
  ];

  // ── Encouragement chips that change each question ──
  static const List<String> _encouragements = [
    'Let\'s begin! 🌸',
    'Nice one! 💪',
    'Great going! ✨',
    'Awesome! 🌟',
    'Halfway! 🎯',
    'So insightful! 💫',
    'Almost done! 🚀',
    'Nearly there! 🌈',
    'One more! 🏁',
    'Final one! 🏆',
  ];

  // ── Animation controllers ──
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _optionsController;
  late AnimationController _funFactController;
  late AnimationController _pulseController;
  late AnimationController _transitionController;

  @override
  void initState() {
    super.initState();

    // Icon bounce-in
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Question text slide-up + fade
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Options cascade
    _optionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Fun-fact slide-up
    _funFactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Continuous glow pulse on the icon ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Page enter / exit (scale + opacity)
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _playEntryAnimations();
  }

  void _playEntryAnimations() {
    _iconController.reset();
    _textController.reset();
    _optionsController.reset();
    _funFactController.reset();
    _showFunFact = false;

    // Stagger: icon → text → options
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _optionsController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _iconController.dispose();
    _textController.dispose();
    _optionsController.dispose();
    _funFactController.dispose();
    _pulseController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  // ── Answer selection ──
  void _selectAnswer(int questionIndex, int score) {
    if (_isTransitioning) return;
    HapticFeedback.lightImpact();

    final isFirstAnswer = _answers[questionIndex] == -1;

    setState(() {
      _answers[questionIndex] = score;
      _showFunFact = true;
    });

    if (isFirstAnswer) {
      _funFactController.forward();

      // Auto-advance after fun-fact display
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted || _isTransitioning) return;
        if (questionIndex < _questions.length - 1) {
          _goToNextQuestion();
        }
      });
    }
  }

  // ── Navigation ──
  Future<void> _goToNextQuestion() async {
    if (_currentQuestion >= _questions.length - 1 || _isTransitioning) return;
    _isTransitioning = true;

    // Exit: scale-down + fade-out
    await _transitionController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
    if (!mounted) return;

    setState(() {
      _currentQuestion++;
      _showFunFact = false;
    });

    // Enter: scale-up with overshoot + fade-in
    _transitionController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
    _playEntryAnimations();

    await Future.delayed(const Duration(milliseconds: 450));
    _isTransitioning = false;
  }

  Future<void> _goToPreviousQuestion() async {
    if (_currentQuestion <= 0 || _isTransitioning) return;
    _isTransitioning = true;

    await _transitionController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
    if (!mounted) return;

    setState(() {
      _currentQuestion--;
      _showFunFact = false;
    });

    _transitionController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    );
    _playEntryAnimations();

    await Future.delayed(const Duration(milliseconds: 450));
    _isTransitioning = false;
  }

  Future<void> _submitAnswers() async {
    final totalScore = _answers.reduce((a, b) => a + b);
    final repo = ref.read(localStorageProvider);
    await repo.saveQuestionnaireResults(totalScore, _answers);
    ref.read(questionnaireCompletedProvider.notifier).state = true;
    ref.read(drynessScoreProvider.notifier).state = totalScore;

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ResultScreen(score: totalScore),
          transitionsBuilder: (_, animation, __, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  // ── Helpers ──
  Animation<double> _optionAnimation(int index) {
    final start = (index * 0.15).clamp(0.0, 1.0);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _optionsController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  INTRO PROFILE STEP
  // ═══════════════════════════════════════════════════════
  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    final repo = ref.read(localStorageProvider);
    await repo.saveUserProfile(name, age);
    ref.read(userNameProvider.notifier).state = name;
    ref.read(userAgeProvider.notifier).state = age;

    if (mounted) {
      setState(() => _showIntro = false);
      _playEntryAnimations();
    }
  }

  Widget _buildIntroScreen(bool isDark) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Hero emoji
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.deepPurple.withValues(alpha: 0.25),
                          AppColors.dustyRose.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepPurple.withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👋', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'Before we begin...',
                        style:
                            Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us a little about yourself so we can\npersonalize your experience ✨',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Name field
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: GlassCard(
                    margin: EdgeInsets.zero,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        hintText: 'e.g. Sarah',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                                  .withValues(alpha: 0.4)
                              : AppColors.lightTextSecondary
                                  .withValues(alpha: 0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: AppColors.coral,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Age field
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: GlassCard(
                    margin: EdgeInsets.zero,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your Age',
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        hintText: 'e.g. 25',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                                  .withValues(alpha: 0.4)
                              : AppColors.lightTextSecondary
                                  .withValues(alpha: 0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.cake_rounded,
                          color: AppColors.softPeach,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value.trim());
                        if (age == null || age < 5 || age > 120) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Continue button
                GradientButton(
                  text: 'Continue to Assessment 🌿',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _submitProfile,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showIntro) {
      return Scaffold(body: _buildIntroScreen(isDark));
    }

    final progress = (_currentQuestion + 1) / _questions.length;
    final accentColor = _accentColors[_currentQuestion];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentQuestion > 0
                          ? _goToPreviousQuestion
                          : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Expanded(
                      child: AnimatedProgressBar(
                        progress: progress,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.deepPurple.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Encouragement chip
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        _encouragements[_currentQuestion],
                        key: ValueKey(_currentQuestion),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Question counter
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      '${_currentQuestion + 1} of ${_questions.length}',
                      key: ValueKey('counter_$_currentQuestion'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondary.withValues(alpha: 0.6)
                            : AppColors.lightTextSecondary
                                .withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Main content with page transition ──
              Expanded(
                child: AnimatedBuilder(
                  animation: _transitionController,
                  builder: (context, child) {
                    final scale = 0.85 + (_transitionController.value * 0.15);
                    return Opacity(
                      opacity: _transitionController.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: _buildQuestionContent(isDark, accentColor),
                ),
              ),

              // ── Submit button (last question, answered) ──
              if (_currentQuestion == _questions.length - 1 &&
                  _answers[_currentQuestion] != -1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: GradientButton(
                    text: 'See My Results ✨',
                    icon: Icons.auto_awesome,
                    onPressed: _submitAnswers,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  QUESTION CONTENT
  // ═══════════════════════════════════════════════════════
  Widget _buildQuestionContent(bool isDark, Color accentColor) {
    final question = _questions[_currentQuestion];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Animated icon with pulsing glow ring ──
          AnimatedBuilder(
            animation: _iconController,
            builder: (context, child) {
              final bounce = TweenSequence<double>([
                TweenSequenceItem(
                    tween: Tween(begin: 0.0, end: 1.15), weight: 55),
                TweenSequenceItem(
                    tween: Tween(begin: 1.15, end: 0.92), weight: 20),
                TweenSequenceItem(
                    tween: Tween(begin: 0.92, end: 1.0), weight: 25),
              ]).evaluate(_iconController);
              return Transform.scale(scale: bounce, child: child);
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final glow = 0.15 + (_pulseController.value * 0.15);
                final pulseScale = 1.0 + (_pulseController.value * 0.06);
                return Transform.scale(
                  scale: pulseScale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: glow),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.25),
                            accentColor.withValues(alpha: 0.10),
                          ],
                        ),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          question.icon,
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // ── Question text with slide-up + fade ──
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_textController.value);
              return Transform.translate(
                offset: Offset(0, 30 * (1 - t)),
                child: Opacity(opacity: t, child: child),
              );
            },
            child: Text(
              question.question,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          // ── Options with staggered cascade ──
          ...List.generate(question.options.length, (optIndex) {
            final option = question.options[optIndex];
            final isSelected = _answers[_currentQuestion] == option.score;
            final optAnim = _optionAnimation(optIndex);

            return AnimatedBuilder(
              animation: optAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - optAnim.value)),
                  child: Opacity(opacity: optAnim.value, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(
                  option,
                  optIndex,
                  isSelected,
                  isDark,
                  accentColor,
                  () => _selectAnswer(_currentQuestion, option.score),
                ),
              ),
            );
          }),

          // ── Fun fact card ──
          if (_showFunFact)
            AnimatedBuilder(
              animation: _funFactController,
              builder: (context, child) {
                final t =
                    Curves.easeOutBack.transform(_funFactController.value);
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - t)),
                  child: Opacity(
                    opacity: _funFactController.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _funFacts[_currentQuestion],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  OPTION CARD
  // ═══════════════════════════════════════════════════════
  Widget _buildOptionCard(
    AnswerOption option,
    int index,
    bool isSelected,
    bool isDark,
    Color accentColor,
    VoidCallback onTap,
  ) {
    const labels = ['A', 'B', 'C', 'D'];

    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: GlassCard(
        margin: EdgeInsets.zero,
        borderRadius: 16,
        borderColor: isSelected
            ? accentColor
            : isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.deepPurple.withValues(alpha: 0.08),
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.7),
                      ])
                    : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.deepPurple.withValues(alpha: 0.06)),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.deepPurple.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          key: ValueKey('check'), size: 18, color: Colors.white)
                      : Text(
                          labels[index],
                          key: ValueKey('label_$index'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                      : (isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ),
            // Trailing check icon
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.check_circle_rounded,
                  color: accentColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
