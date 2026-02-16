import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_model.dart';
import '../../data/repositories/local_storage_repository.dart';

// Repository provider
final localStorageProvider = Provider<LocalStorageRepository>((ref) {
  return LocalStorageRepository();
});

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final repo = ref.read(localStorageProvider);
  return ThemeNotifier(repo);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageRepository _repo;

  ThemeNotifier(this._repo)
      : super(_repo.isDarkMode ? ThemeMode.dark : ThemeMode.light);

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    await _repo.setDarkMode(!isDark);
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

// Onboarding provider
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.isOnboardingCompleted;
});

// Questionnaire provider
final questionnaireCompletedProvider = StateProvider<bool>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.isQuestionnaireCompleted;
});

final currentQuestionProvider = StateProvider<int>((ref) => 0);

final answersProvider = StateProvider<List<int>>((ref) => []);

final drynessScoreProvider = StateProvider<int>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.drynessScore;
});

// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardModel>((ref) {
  final repo = ref.read(localStorageProvider);
  return DashboardNotifier(repo);
});

class DashboardNotifier extends StateNotifier<DashboardModel> {
  final LocalStorageRepository _repo;

  DashboardNotifier(this._repo) : super(_repo.getDashboardData()) {
    _checkDayReset();
  }

  void _checkDayReset() {
    final now = DateTime.now();
    final lastActive = state.lastActiveDate;

    if (now.year != lastActive.year ||
        now.month != lastActive.month ||
        now.day != lastActive.day) {
      // New day - check streak
      final yesterday = now.subtract(const Duration(days: 1));
      final isConsecutive = lastActive.year == yesterday.year &&
          lastActive.month == yesterday.month &&
          lastActive.day == yesterday.day;

      final newStreak = isConsecutive ? state.streakCount + 1 : 1;

      state = DashboardModel(
        waterIntake: 0,
        morningChecklist: List<bool>.filled(5, false),
        nightChecklist: List<bool>.filled(5, false),
        streakCount: newStreak,
        lastActiveDate: now,
      );
      _repo.saveDashboardData(state);
    }
  }

  void addWater() {
    if (state.waterIntake < 12) {
      state = state.copyWith(waterIntake: state.waterIntake + 1);
      _repo.saveDashboardData(state);
    }
  }

  void removeWater() {
    if (state.waterIntake > 0) {
      state = state.copyWith(waterIntake: state.waterIntake - 1);
      _repo.saveDashboardData(state);
    }
  }

  void toggleMorningItem(int index) {
    final newList = List<bool>.from(state.morningChecklist);
    newList[index] = !newList[index];
    state = state.copyWith(morningChecklist: newList);
    _repo.saveDashboardData(state);
  }

  void toggleNightItem(int index) {
    final newList = List<bool>.from(state.nightChecklist);
    newList[index] = !newList[index];
    state = state.copyWith(nightChecklist: newList);
    _repo.saveDashboardData(state);
  }
}

// Reminder provider
final reminderProvider = StateProvider<bool>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.isReminderEnabled;
});

// User profile providers
final userNameProvider = StateProvider<String>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.userName;
});

final userAgeProvider = StateProvider<int>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.userAge;
});
