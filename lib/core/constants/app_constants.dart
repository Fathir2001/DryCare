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
  static const String userName = 'user_name';
  static const String userAge = 'user_age';

  // Scoring
  static const int maxScore = 30;
  static const int mildMax = 8;
  static const int moderateMax = 18;

  // Disclaimer
  static const String medicalDisclaimer =
      'DryCare is a general skincare and wellness guide. Its questionnaire is based only on your answers; it does not diagnose, measure clinical severity, or treat a condition. Seek advice from a qualified healthcare professional for persistent or worsening dryness, painful cracks, bleeding, signs of infection, or other concerning symptoms. Follow any personal medical advice about fluid intake.';

  // Privacy
  static const String privacyPolicy =
      'DryCare stores the name and age you enter, questionnaire answers and score, daily water and routine records, streak, and preferences in local storage on this device. It has no account, advertising, analytics, or app backend. The app does not intentionally upload your entries. Font loading and final release network behavior should be verified before claiming that no data leaves the device. Android backup is disabled. Reset All Data erases the app\'s local records and preferences. Uninstalling the app also removes its local data. Contact information and the published policy URL will be supplied in the Play listing.';
}
