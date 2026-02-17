import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../models/dashboard_model.dart';

class LocalStorageRepository {
  late Box _userBox;
  late Box _dashboardBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
    _dashboardBox = await Hive.openBox(AppConstants.dashboardBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // Onboarding
  bool get isOnboardingCompleted =>
      _userBox.get(AppConstants.onboardingCompleted, defaultValue: false);

  Future<void> setOnboardingCompleted() async {
    await _userBox.put(AppConstants.onboardingCompleted, true);
  }

  // Questionnaire
  bool get isQuestionnaireCompleted =>
      _userBox.get(AppConstants.questionnaireCompleted, defaultValue: false);

  Future<void> saveQuestionnaireResults(int score, List<int> answers) async {
    await _userBox.put(AppConstants.drynessScore, score);
    await _userBox.put(
        AppConstants.drynessLevel, AppUtils.getDrynessLevel(score));
    await _userBox.put(AppConstants.questionnaireAnswers, answers);
    await _userBox.put(AppConstants.questionnaireCompleted, true);
  }

  int get drynessScore =>
      _userBox.get(AppConstants.drynessScore, defaultValue: 0);

  String get drynessLevel =>
      _userBox.get(AppConstants.drynessLevel, defaultValue: 'Unknown');

  List<int> get questionnaireAnswers {
    final dynamic raw = _userBox.get(AppConstants.questionnaireAnswers);
    if (raw == null) return [];
    return List<int>.from(raw);
  }

  // Dashboard
  DashboardModel getDashboardData() {
    final waterIntake =
        _dashboardBox.get(AppConstants.waterIntake, defaultValue: 0) as int;

    final dynamic morningRaw = _dashboardBox.get(AppConstants.morningChecklist);
    final morningChecklist = morningRaw != null
        ? List<bool>.from(morningRaw)
        : List<bool>.filled(5, false);

    final dynamic nightRaw = _dashboardBox.get(AppConstants.nightChecklist);
    final nightChecklist = nightRaw != null
        ? List<bool>.filled(5, false)
        : List<bool>.filled(5, false);
    if (nightRaw != null) {
      final raw = List<bool>.from(nightRaw);
      for (int i = 0; i < raw.length && i < nightChecklist.length; i++) {
        nightChecklist[i] = raw[i];
      }
    }

    final streakCount =
        _dashboardBox.get(AppConstants.streakCount, defaultValue: 0) as int;

    final lastActiveDateStr = _dashboardBox.get(AppConstants.lastActiveDate);
    final lastActiveDate = lastActiveDateStr != null
        ? DateTime.parse(lastActiveDateStr)
        : DateTime.now();

    return DashboardModel(
      waterIntake: waterIntake,
      morningChecklist: morningChecklist,
      nightChecklist: nightChecklist,
      streakCount: streakCount,
      lastActiveDate: lastActiveDate,
    );
  }

  Future<void> saveDashboardData(DashboardModel data) async {
    await _dashboardBox.put(AppConstants.waterIntake, data.waterIntake);
    await _dashboardBox.put(
        AppConstants.morningChecklist, data.morningChecklist);
    await _dashboardBox.put(AppConstants.nightChecklist, data.nightChecklist);
    await _dashboardBox.put(AppConstants.streakCount, data.streakCount);
    await _dashboardBox.put(
        AppConstants.lastActiveDate, data.lastActiveDate.toIso8601String());
  }

  Future<void> updateWaterIntake(int glasses) async {
    await _dashboardBox.put(AppConstants.waterIntake, glasses);
  }

  Future<void> updateMorningChecklist(List<bool> checklist) async {
    await _dashboardBox.put(AppConstants.morningChecklist, checklist);
  }

  Future<void> updateNightChecklist(List<bool> checklist) async {
    await _dashboardBox.put(AppConstants.nightChecklist, checklist);
  }

  Future<void> updateStreak(int streak, DateTime date) async {
    await _dashboardBox.put(AppConstants.streakCount, streak);
    await _dashboardBox.put(
        AppConstants.lastActiveDate, date.toIso8601String());
  }

  // Reset daily data (call when new day detected)
  Future<void> resetDailyData() async {
    await _dashboardBox.put(AppConstants.waterIntake, 0);
    await _dashboardBox.put(
        AppConstants.morningChecklist, List<bool>.filled(5, false));
    await _dashboardBox.put(
        AppConstants.nightChecklist, List<bool>.filled(5, false));
  }

  // Settings
  bool get isDarkMode =>
      _settingsBox.get(AppConstants.isDarkMode, defaultValue: true);

  Future<void> setDarkMode(bool value) async {
    await _settingsBox.put(AppConstants.isDarkMode, value);
  }

  bool get isReminderEnabled =>
      _settingsBox.get(AppConstants.reminderEnabled, defaultValue: false);

  Future<void> setReminderEnabled(bool value) async {
    await _settingsBox.put(AppConstants.reminderEnabled, value);
  }

  // User profile
  String get userName => _userBox.get(AppConstants.userName, defaultValue: '');

  int get userAge => _userBox.get(AppConstants.userAge, defaultValue: 0);

  Future<void> saveUserProfile(String name, int age) async {
    await _userBox.put(AppConstants.userName, name);
    await _userBox.put(AppConstants.userAge, age);
  }

  // Reset all data
  Future<void> resetAllData() async {
    await _userBox.clear();
    await _dashboardBox.clear();
    // Keep settings
  }
}
