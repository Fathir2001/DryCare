class DashboardModel {
  final int waterIntake; // glasses
  final List<bool> morningChecklist;
  final List<bool> nightChecklist;
  final int streakCount;
  final DateTime lastActiveDate;

  const DashboardModel({
    this.waterIntake = 0,
    this.morningChecklist = const [false, false, false, false, false],
    this.nightChecklist = const [false, false, false, false, false],
    this.streakCount = 0,
    required this.lastActiveDate,
  });

  DashboardModel copyWith({
    int? waterIntake,
    List<bool>? morningChecklist,
    List<bool>? nightChecklist,
    int? streakCount,
    DateTime? lastActiveDate,
  }) {
    return DashboardModel(
      waterIntake: waterIntake ?? this.waterIntake,
      morningChecklist: morningChecklist ?? this.morningChecklist,
      nightChecklist: nightChecklist ?? this.nightChecklist,
      streakCount: streakCount ?? this.streakCount,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  double get completionPercentage {
    int total = morningChecklist.length + nightChecklist.length + 8; // +8 for water goal
    int completed = morningChecklist.where((e) => e).length +
        nightChecklist.where((e) => e).length +
        (waterIntake.clamp(0, 8));
    return completed / total;
  }
}
