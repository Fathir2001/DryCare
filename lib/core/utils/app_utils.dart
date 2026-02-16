import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static String getDrynessLevel(int score) {
    if (score <= 8) return 'Mild Dryness';
    if (score <= 18) return 'Moderate Dryness';
    return 'Severe Dryness';
  }

  static Color getDrynessColor(int score) {
    if (score <= 8) return const Color(0xFF7BC67E);
    if (score <= 18) return const Color(0xFFFFB74D);
    return const Color(0xFFEF5350);
  }

  static IconData getDrynessIcon(int score) {
    if (score <= 8) return Icons.sentiment_satisfied_rounded;
    if (score <= 18) return Icons.sentiment_neutral_rounded;
    return Icons.sentiment_dissatisfied_rounded;
  }

  static String getDrynessExplanation(int score) {
    if (score <= 8) {
      return 'Your skin shows mild signs of dryness. With a few simple adjustments to your routine, you can keep your skin healthy and hydrated!';
    }
    if (score <= 18) {
      return 'Your skin is showing moderate dryness. It\'s important to give your skin extra attention with proper hydration and moisturizing routines.';
    }
    return 'Your skin appears to be significantly dry and may need special care. A consistent skincare routine with rich moisturizers and lifestyle changes can make a big difference.';
  }

  static String getMotivationalMessage(int score) {
    if (score <= 8) {
      return '✨ Great job! You\'re already taking good care of your skin. Keep it up!';
    }
    if (score <= 18) {
      return '💪 Don\'t worry! With the right routine, your skin will improve. Let\'s start your journey!';
    }
    return '🌟 Every journey starts with a single step. We\'re here to help you achieve healthier, more comfortable skin!';
  }

  static List<String> getSkincareRoutine(int score) {
    if (score <= 8) {
      return [
        'Use a gentle, hydrating cleanser morning and night',
        'Apply lightweight moisturizer after cleansing',
        'Use SPF 30+ sunscreen daily',
        'Drink at least 2L of water daily',
        'Use a hydrating mist throughout the day',
      ];
    }
    if (score <= 18) {
      return [
        'Switch to a cream-based, soap-free cleanser',
        'Apply hyaluronic acid serum on damp skin',
        'Use a rich moisturizer with ceramides',
        'Apply SPF 30+ sunscreen every morning',
        'Use a humidifier in dry environments',
        'Avoid hot water when washing your face',
        'Drink at least 2L of water daily',
      ];
    }
    return [
      'Use an ultra-gentle, fragrance-free cream cleanser',
      'Apply hyaluronic acid serum on damp skin immediately',
      'Layer a ceramide-rich moisturizer on top',
      'Seal with a facial oil (jojoba or squalane)',
      'Apply SPF 30+ mineral sunscreen daily',
      'Use a sleeping mask 2-3 times per week',
      'Strictly avoid hot water on your face',
      'Run a humidifier while sleeping',
      'Increase water intake to 2.5L+ daily',
      'Add omega-3 rich foods to your diet',
    ];
  }

  static List<String> getHydrationAdvice(int score) {
    if (score <= 8) {
      return [
        'Maintain your good water intake habits',
        'Eat water-rich fruits like watermelon and cucumber',
        'Limit caffeine to 2 cups per day',
      ];
    }
    if (score <= 18) {
      return [
        'Set hourly water reminders',
        'Start your morning with a glass of warm water',
        'Include hydrating foods: cucumbers, berries, oranges',
        'Reduce alcohol and excessive caffeine',
        'Consider herbal teas for extra hydration',
      ];
    }
    return [
      'Drink water consistently throughout the day (2.5L+)',
      'Start every meal with a glass of water',
      'Eat plenty of water-rich foods daily',
      'Avoid dehydrating beverages (alcohol, excess caffeine)',
      'Add electrolytes to water for better absorption',
      'Track your water intake daily',
      'Keep a water bottle with you at all times',
    ];
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
