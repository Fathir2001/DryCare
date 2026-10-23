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
  final DateTime Function() _clock;

  DashboardNotifier(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(_repo.getDashboardData()) {
    checkDayReset();
  }

  void checkDayReset() {
    final now = _clock();
    final lastActive = state.lastActiveDate;

    if (now.year != lastActive.year ||
        now.month != lastActive.month ||
        now.day != lastActive.day) {
      final completed = _repo.lastRoutineCompletedDate;
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final keepStreak = completed != null &&
          completed.year == yesterday.year &&
          completed.month == yesterday.month &&
          completed.day == yesterday.day;

      state = DashboardModel(
        waterIntake: 0,
        morningChecklist: List<bool>.filled(5, false),
        nightChecklist: List<bool>.filled(5, false),
        streakCount: keepStreak ? state.streakCount : 0,
        lastActiveDate: now,
      );
      _repo.saveDashboardData(state);
    }
  }

  void addWater() {
    checkDayReset();
    if (state.waterIntake < 12) {
      state = state.copyWith(waterIntake: state.waterIntake + 1);
      _repo.saveDashboardData(state);
    }
  }

  void removeWater() {
    checkDayReset();
    if (state.waterIntake > 0) {
      state = state.copyWith(waterIntake: state.waterIntake - 1);
      _repo.saveDashboardData(state);
    }
  }

  void toggleMorningItem(int index) {
    checkDayReset();
    final newList = List<bool>.from(state.morningChecklist);
    newList[index] = !newList[index];
    state = state.copyWith(morningChecklist: newList);
    _repo.saveDashboardData(state);
    _recordCompletedRoutine();
  }

  void toggleNightItem(int index) {
    checkDayReset();
    final newList = List<bool>.from(state.nightChecklist);
    newList[index] = !newList[index];
    state = state.copyWith(nightChecklist: newList);
    _repo.saveDashboardData(state);
    _recordCompletedRoutine();
  }

  void _recordCompletedRoutine() {
    if (!state.morningChecklist.every((item) => item) &&
        !state.nightChecklist.every((item) => item)) {
      return;
    }
    final now = _clock();
    final previous = _repo.lastRoutineCompletedDate;
    if (previous != null &&
        previous.year == now.year &&
        previous.month == now.month &&
        previous.day == now.day) {
      return;
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final consecutive = previous != null &&
        previous.year == yesterday.year &&
        previous.month == yesterday.month &&
        previous.day == yesterday.day;
    state =
        state.copyWith(streakCount: consecutive ? state.streakCount + 1 : 1);
    _repo.saveLastRoutineCompletedDate(now);
    _repo.saveDashboardData(state);
  }
}

// User profile providers
final userNameProvider = StateProvider<String>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.userName;
});

final userAgeProvider = StateProvider<int>((ref) {
  final repo = ref.read(localStorageProvider);
  return repo.userAge;
});
