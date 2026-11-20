import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/pomodoro_config_entity.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroState {
  final PomodoroConfigEntity config;
  final PomodoroPhase currentPhase;
  final int remainingSeconds;
  final int totalPhaseSeconds;
  final int completedCycles;
  final bool isRunning;

  const PomodoroState({
    this.config = const PomodoroConfigEntity(),
    this.currentPhase = PomodoroPhase.focus,
    this.remainingSeconds = 25 * 60,
    this.totalPhaseSeconds = 25 * 60,
    this.completedCycles = 0,
    this.isRunning = false,
  });

  double get progressRatio => totalPhaseSeconds > 0
      ? (totalPhaseSeconds - remainingSeconds) / totalPhaseSeconds
      : 0.0;

  PomodoroState copyWith({
    PomodoroConfigEntity? config,
    PomodoroPhase? currentPhase,
    int? remainingSeconds,
    int? totalPhaseSeconds,
    int? completedCycles,
    bool? isRunning,
  }) {
    return PomodoroState(
      config: config ?? this.config,
      currentPhase: currentPhase ?? this.currentPhase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalPhaseSeconds: totalPhaseSeconds ?? this.totalPhaseSeconds,
      completedCycles: completedCycles ?? this.completedCycles,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class PomodoroController extends StateNotifier<PomodoroState> {
  Timer? _ticker;

  PomodoroController() : super(const PomodoroState());

  void selectPreset(PomodoroPreset preset) {
    _ticker?.cancel();
    final cfg = PomodoroConfigEntity.forPreset(preset);
    final totalSecs = cfg.focusMinutes * 60;
    state = PomodoroState(
      config: cfg,
      currentPhase: PomodoroPhase.focus,
      remainingSeconds: totalSecs,
      totalPhaseSeconds: totalSecs,
      completedCycles: 0,
      isRunning: false,
    );
  }

  void start() {
    state = state.copyWith(isRunning: true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _transitionToNextPhase();
      }
    });
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _ticker?.cancel();
    final secs = state.currentPhase == PomodoroPhase.focus
        ? state.config.focusMinutes * 60
        : (state.currentPhase == PomodoroPhase.shortBreak
            ? state.config.shortBreakMinutes * 60
            : state.config.longBreakMinutes * 60);

    state = state.copyWith(
      remainingSeconds: secs,
      totalPhaseSeconds: secs,
      isRunning: false,
    );
  }

  void _transitionToNextPhase() {
    _ticker?.cancel();
    if (state.currentPhase == PomodoroPhase.focus) {
      final newCompleted = state.completedCycles + 1;
      final isLongBreak = newCompleted % state.config.longBreakInterval == 0;
      final nextPhase = isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      final nextSeconds = isLongBreak
          ? state.config.longBreakMinutes * 60
          : state.config.shortBreakMinutes * 60;

      state = state.copyWith(
        currentPhase: nextPhase,
        remainingSeconds: nextSeconds,
        totalPhaseSeconds: nextSeconds,
        completedCycles: newCompleted,
        isRunning: state.config.autoStartBreaks,
      );
      if (state.config.autoStartBreaks) start();
    } else {
      final focusSecs = state.config.focusMinutes * 60;
      state = state.copyWith(
        currentPhase: PomodoroPhase.focus,
        remainingSeconds: focusSecs,
        totalPhaseSeconds: focusSecs,
        isRunning: state.config.autoStartPomodoros,
      );
      if (state.config.autoStartPomodoros) start();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
  return PomodoroController();
});
