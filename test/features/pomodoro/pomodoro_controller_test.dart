import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/pomodoro/domain/entities/pomodoro_config_entity.dart';
import 'package:lets_fly_tgr/features/pomodoro/presentation/controllers/pomodoro_controller.dart';

void main() {
  group('PomodoroController Unit Tests', () {
    late PomodoroController controller;

    setUp(() {
      controller = PomodoroController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial preset defaults to Classic 25 minutes', () {
      expect(controller.state.config.preset, equals(PomodoroPreset.classic));
      expect(controller.state.remainingSeconds, equals(25 * 60));
      expect(controller.state.currentPhase, equals(PomodoroPhase.focus));
      expect(controller.state.isRunning, isFalse);
    });

    test('Switching preset to Deep Work sets 90 minutes', () {
      controller.selectPreset(PomodoroPreset.deepWork);

      expect(controller.state.config.preset, equals(PomodoroPreset.deepWork));
      expect(controller.state.remainingSeconds, equals(90 * 60));
      expect(controller.state.currentPhase, equals(PomodoroPhase.focus));
    });

    test('Start and pause update running state', () {
      controller.start();
      expect(controller.state.isRunning, isTrue);

      controller.pause();
      expect(controller.state.isRunning, isFalse);
    });
  });
}
