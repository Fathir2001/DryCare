class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'DryCare';
  static const String appTagline = 'Dry Skin Face Care';
  static const String appVersion = '1.0.0';

  // Hive boxes
  static const String userBox = 'user_box';
  static const String dashboardBox = 'dashboard_box';
  static const String settingsBox = 'settings_box';

  // Hive keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String questionnaireCompleted = 'questionnaire_completed';
  static const String drynessScore = 'dryness_score';
  static const String drynessLevel = 'dryness_level';
  static const String questionnaireAnswers = 'questionnaire_answers';
  static const String waterIntake = 'water_intake';
  static const String morningChecklist = 'morning_checklist';
  static const String nightChecklist = 'night_checklist';
  static const String streakCount = 'streak_count';
  static const String lastActiveDate = 'last_active_date';
  static const String isDarkMode = 'is_dark_mode';
  static const String reminderEnabled = 'reminder_enabled';

  // Scoring
  static const int maxScore = 30;
  static const int mildMax = 8;
  static const int moderateMax = 18;

  // Disclaimer
  static const String medicalDisclaimer =
      'DryCare provides general skincare guidance only and is not a medical diagnosis. '
      'Always consult with a qualified healthcare professional or dermatologist '
      'for medical advice.';

  // Privacy
  static const String privacyPolicy =
      'DryCare is committed to protecting your privacy. All data is stored locally '
      'on your device and is never transmitted to any external servers. '
      'We do not collect, store, or share any personal information. '
      'Your skincare assessment data, daily tracking information, and preferences '
      'remain entirely on your device. You can delete all your data at any time '
      'from the Settings screen.';
}
