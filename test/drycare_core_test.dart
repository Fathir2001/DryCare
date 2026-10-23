import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:drycare/core/utils/app_utils.dart';
import 'package:drycare/core/providers/app_providers.dart';
import 'package:drycare/data/models/dashboard_model.dart';
import 'package:drycare/data/repositories/local_storage_repository.dart';

void main() {
  test('questionnaire bands cover the complete 0 to 30 range', () {
    expect(AppUtils.getDrynessLevel(0), 'Few reported dryness signs');
    expect(AppUtils.getDrynessLevel(8), 'Few reported dryness signs');
    expect(AppUtils.getDrynessLevel(9), 'Some reported dryness signs');
    expect(AppUtils.getDrynessLevel(18), 'Some reported dryness signs');
    expect(AppUtils.getDrynessLevel(19), 'More reported dryness signs');
    expect(AppUtils.getDrynessLevel(30), 'More reported dryness signs');
  });

  test('dashboard completion counts checklist items and eight glasses', () {
    final model = DashboardModel(
      waterIntake: 12,
      morningChecklist: const [true, true, true, true, true],
      nightChecklist: const [true, true, true, true, true],
      lastActiveDate: DateTime(2026, 10, 22),
    );
    expect(model.completionPercentage, 1);
  });

  test('opening alone does not earn a streak; a completed routine does', () {
    var now = DateTime(2026, 10, 22, 10);
    final repo = _MemoryRepository(now);
    final notifier = DashboardNotifier(repo, clock: () => now);
    expect(notifier.state.streakCount, 0);
    for (var i = 0; i < 5; i++) {
      notifier.toggleMorningItem(i);
    }
    expect(notifier.state.streakCount, 1);
    now = DateTime(2026, 10, 23, 0, 1);
    notifier.checkDayReset();
    expect(notifier.state.waterIntake, 0);
    expect(notifier.state.morningChecklist.every((item) => !item), true);
    expect(notifier.state.streakCount, 1);
    for (var i = 0; i < 5; i++) {
      notifier.toggleNightItem(i);
    }
    expect(notifier.state.streakCount, 2);
    now = DateTime(2026, 10, 25);
    notifier.checkDayReset();
    expect(notifier.state.streakCount, 0);
  });

  test('local records survive reopen and comprehensive reset clears them',
      () async {
    final directory = await Directory.systemTemp.createTemp('drycare_test_');
    try {
      final repo = LocalStorageRepository();
      await repo.init(storagePath: directory.path);
      await repo.saveUserProfile('Test User', 25);
      await repo.saveQuestionnaireResults(12, List<int>.filled(10, 1));
      await repo.setDarkMode(true);
      await repo.saveDashboardData(DashboardModel(
        waterIntake: 3,
        lastActiveDate: DateTime(2026, 10, 22),
      ));
      expect(repo.userName, 'Test User');
      expect(repo.drynessScore, 12);
      expect(repo.getDashboardData().waterIntake, 3);
      await repo.resetAllData();
      expect(repo.userName, isEmpty);
      expect(repo.questionnaireAnswers, isEmpty);
      expect(repo.getDashboardData().waterIntake, 0);
      expect(repo.isDarkMode, false);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}

class _MemoryRepository extends LocalStorageRepository {
  DashboardModel data;
  DateTime? completed;

  _MemoryRepository(DateTime now) : data = DashboardModel(lastActiveDate: now);

  @override
  DashboardModel getDashboardData() => data;

  @override
  Future<void> saveDashboardData(DashboardModel value) async {
    data = value;
  }

  @override
  DateTime? get lastRoutineCompletedDate => completed;

  @override
  Future<void> saveLastRoutineCompletedDate(DateTime date) async {
    completed = date;
  }
}
