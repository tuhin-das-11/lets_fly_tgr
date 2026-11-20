enum PomodoroPreset {
  classic, // 25 min focus, 5 min break
  extended, // 50 min focus, 10 min break
  deepWork, // 90 min focus, 15 min break
  custom,
}

class PomodoroConfigEntity {
  final PomodoroPreset preset;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval; // after how many focus sessions
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const PomodoroConfigEntity({
    this.preset = PomodoroPreset.classic,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });

  static PomodoroConfigEntity forPreset(PomodoroPreset preset) {
    switch (preset) {
      case PomodoroPreset.classic:
        return const PomodoroConfigEntity(
          preset: PomodoroPreset.classic,
          focusMinutes: 25,
          shortBreakMinutes: 5,
          longBreakMinutes: 15,
        );
      case PomodoroPreset.extended:
        return const PomodoroConfigEntity(
          preset: PomodoroPreset.extended,
          focusMinutes: 50,
          shortBreakMinutes: 10,
          longBreakMinutes: 20,
        );
      case PomodoroPreset.deepWork:
        return const PomodoroConfigEntity(
          preset: PomodoroPreset.deepWork,
          focusMinutes: 90,
          shortBreakMinutes: 15,
          longBreakMinutes: 30,
        );
      case PomodoroPreset.custom:
        return const PomodoroConfigEntity(preset: PomodoroPreset.custom);
    }
  }
}
