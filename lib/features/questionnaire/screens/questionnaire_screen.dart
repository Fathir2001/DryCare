import 'package:flutter/material.dart';
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
  late PageController _pageController;
  int _currentQuestion = 0;
  final List<int> _answers = List.filled(10, -1);
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;

  final List<QuestionModel> _questions = QuestionnaireDataSource.questions;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int score) {
    setState(() {
      _answers[questionIndex] = score;
    });

    // Auto-advance after a brief delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (questionIndex < _questions.length - 1) {
        _goToNextQuestion();
      }
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestion >= _questions.length - 1) return;

    _slideController.reset();
    _fadeController.value = 0.0;

    setState(() => _currentQuestion++);

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _slideController.forward();
    _fadeController.animateTo(1.0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void _goToPreviousQuestion() {
    if (_currentQuestion <= 0) return;

    _slideController.reset();
    _fadeController.value = 0.0;

    setState(() => _currentQuestion--);

    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _slideController.forward();
    _fadeController.animateTo(1.0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
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
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestion + 1) / _questions.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with back button, progress, and question counter
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
                    Text(
                      '${_currentQuestion + 1}/${_questions.length}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return _buildQuestionPage(question, index, isDark);
                  },
                ),
              ),

              // Submit button (only on last question when answered)
              if (_currentQuestion == _questions.length - 1 &&
                  _answers[_currentQuestion] != -1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: GradientButton(
                    text: 'See My Results',
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

  Widget _buildQuestionPage(QuestionModel question, int index, bool isDark) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Question icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.deepPurple.withValues(alpha: 0.3),
                        AppColors.dustyRose.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      question.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Question text
              Center(
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Options
              ...List.generate(question.options.length, (optIndex) {
                final option = question.options[optIndex];
                final isSelected = _answers[index] == option.score;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOptionCard(option, isSelected, isDark, () {
                    _selectAnswer(index, option.score);
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      AnswerOption option, bool isSelected, bool isDark, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GlassCard(
        margin: EdgeInsets.zero,
        borderRadius: 16,
        borderColor: isSelected
            ? AppColors.coral
            : isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.deepPurple.withValues(alpha: 0.08),
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.coral : AppColors.textSecondary,
                  width: 2,
                ),
                color: isSelected ? AppColors.coral : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary)
                      : (isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
