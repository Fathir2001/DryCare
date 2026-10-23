import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../models/dashboard_model.dart';

class LocalStorageRepository {
  late Box _userBox;
  late Box _dashboardBox;
  late Box _settingsBox;

  Future<void> init({String? storagePath}) async {
    if (storagePath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(storagePath);
    }
    _userBox = await Hive.openBox(AppConstants.userBox);
    _dashboardBox = await Hive.openBox(AppConstants.dashboardBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // Onboarding
  bool get isOnboardingCompleted =>
      _userBox.get(AppConstants.onboardingCompleted) == true;

  Future<void> setOnboardingCompleted() async {
    await _userBox.put(AppConstants.onboardingCompleted, true);
  }

  // Questionnaire
  bool get isQuestionnaireCompleted =>
      _userBox.get(AppConstants.questionnaireCompleted) == true;

  Future<void> saveQuestionnaireResults(int score, List<int> answers) async {
    await _userBox.put(AppConstants.drynessScore, score);
    await _userBox.put(
        AppConstants.drynessLevel, AppUtils.getDrynessLevel(score));
    await _userBox.put(AppConstants.questionnaireAnswers, answers);
    await _userBox.put(AppConstants.questionnaireCompleted, true);
  }

  int get drynessScore {
    final raw = _userBox.get(AppConstants.drynessScore);
    return raw is int ? raw.clamp(0, 30) : 0;
  }

  String get drynessLevel =>
      _userBox.get(AppConstants.drynessLevel, defaultValue: 'Unknown');

  List<int> get questionnaireAnswers {
    final dynamic raw = _userBox.get(AppConstants.questionnaireAnswers);
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw.whereType<int>().map((value) => value.clamp(0, 3)).toList();
  }

  // Dashboard
  DashboardModel getDashboardData() {
    final rawWater =
        _dashboardBox.get(AppConstants.waterIntake, defaultValue: 0);
    final waterIntake = rawWater is int ? rawWater.clamp(0, 12) : 0;

    final dynamic morningRaw = _dashboardBox.get(AppConstants.morningChecklist);
    final morningChecklist = _validatedChecklist(morningRaw);

    final dynamic nightRaw = _dashboardBox.get(AppConstants.nightChecklist);
    final nightChecklist = _validatedChecklist(nightRaw);

    final rawStreak =
        _dashboardBox.get(AppConstants.streakCount, defaultValue: 0);
    final streakCount = rawStreak is int ? rawStreak.clamp(0, 100000) : 0;

    final lastActiveDateStr = _dashboardBox.get(AppConstants.lastActiveDate);
    final lastActiveDate = lastActiveDateStr is String
        ? (DateTime.tryParse(lastActiveDateStr) ?? DateTime.now())
        : DateTime.now();

    return DashboardModel(
      waterIntake: waterIntake,
      morningChecklist: morningChecklist,
      nightChecklist: nightChecklist,
      streakCount: streakCount,
      lastActiveDate: lastActiveDate,
    );
  }

  List<bool> _validatedChecklist(dynamic raw) {
    final result = List<bool>.filled(5, false);
    if (raw is List) {
      for (var i = 0; i < raw.length && i < result.length; i++) {
        result[i] = raw[i] == true;
      }
    }
    return result;
  }

  DateTime? get lastRoutineCompletedDate {
    final value = _dashboardBox.get('last_routine_completed_date');
    return value is String ? DateTime.tryParse(value) : null;
  }

  Future<void> saveLastRoutineCompletedDate(DateTime date) async {
    await _dashboardBox.put(
        'last_routine_completed_date', date.toIso8601String());
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
  bool get isDarkMode => _settingsBox.get(AppConstants.isDarkMode) == true;

  Future<void> setDarkMode(bool value) async {
    await _settingsBox.put(AppConstants.isDarkMode, value);
  }

  // User profile
  String get userName {
    final raw = _userBox.get(AppConstants.userName);
    return raw is String ? raw : '';
  }

  int get userAge {
    final raw = _userBox.get(AppConstants.userAge);
    return raw is int ? raw.clamp(0, 120) : 0;
  }

  Future<void> saveUserProfile(String name, int age) async {
    await _userBox.put(AppConstants.userName, name);
    await _userBox.put(AppConstants.userAge, age);
  }

  // Reset all data
  Future<void> resetAllData() async {
    await _userBox.clear();
    await _dashboardBox.clear();
    await _settingsBox.clear();
  }
}
