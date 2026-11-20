import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/timer/domain/entities/active_session_entity.dart';
import 'package:lets_fly_tgr/features/timer/domain/entities/study_session_entity.dart';
import 'package:lets_fly_tgr/features/timer/domain/repositories/study_timer_repository.dart';
import 'package:lets_fly_tgr/features/timer/presentation/controllers/study_timer_controller.dart';

class MockStudyTimerRepository implements StudyTimerRepository {
  ActiveSessionEntity? _active;
  int _todaySeconds = 0;

  @override
  Stream<ActiveSessionEntity?> watchActiveSession(String userId) => Stream.value(_active);

  @override
  Future<ActiveSessionEntity?> getActiveSession(String userId) async => _active;

  @override
  Future<ActiveSessionEntity> startSession({
    required String userId,
    required String subjectId,
    required String deviceId,
    required String platform,
    String sessionType = 'stopwatch',
  }) async {
    _active = ActiveSessionEntity(
      userId: userId,
      subjectId: subjectId,
      deviceId: deviceId,
      platform: platform,
      startedAt: DateTime.now(),
      lastHeartbeat: DateTime.now(),
      status: 'running',
      updatedAt: DateTime.now(),
    );
    return _active!;
  }

  @override
  Future<ActiveSessionEntity> pauseSession(String userId) async {
    _active = _active!.copyWith(status: 'paused', lastHeartbeat: DateTime.now());
    return _active!;
  }

  @override
  Future<ActiveSessionEntity> resumeSession(String userId) async {
    _active = _active!.copyWith(status: 'running', lastHeartbeat: DateTime.now());
    return _active!;
  }

  @override
  Future<void> sendHeartbeat(String userId) async {}

  @override
  Future<StudySessionEntity> stopAndCommitSession({
    required String userId,
    required String notes,
  }) async {
    final session = StudySessionEntity(
      id: 'session_1',
      userId: userId,
      subjectId: _active?.subjectId ?? 'sub_1',
      startedAt: _active?.startedAt ?? DateTime.now(),
      endedAt: DateTime.now(),
      durationSeconds: 1800,
      deviceId: 'device_1',
      notes: notes,
      createdAt: DateTime.now(),
    );
    _todaySeconds += 1800;
    _active = null;
    return session;
  }

  @override
  Future<void> discardActiveSession(String userId) async {
    _active = null;
  }

  @override
  Future<ActiveSessionEntity> takeOverSession({
    required String userId,
    required String newDeviceId,
    required String newPlatform,
  }) async {
    _active = _active!.copyWith(deviceId: newDeviceId, platform: newPlatform);
    return _active!;
  }

  @override
  Future<Duration> getTodayTotalDuration(String userId) async => Duration(seconds: _todaySeconds);
}

void main() {
  group('StudyTimerController Unit Tests', () {
    late MockStudyTimerRepository mockRepo;
    late StudyTimerController controller;

    setUp(() {
      mockRepo = MockStudyTimerRepository();
      controller = StudyTimerController(mockRepo, 'test_user');
    });

    test('Starting timer transitions to running status', () async {
      await controller.startTimer(subjectId: 'sub_math');

      expect(controller.state.isRunning, isTrue);
      expect(controller.state.isPaused, isFalse);
      expect(controller.state.currentSubjectId, equals('sub_math'));
    });

    test('Pausing and stopping session updates total study duration', () async {
      await controller.startTimer(subjectId: 'sub_math');
      await controller.pauseTimer();

      expect(controller.state.isRunning, isFalse);
      expect(controller.state.isPaused, isTrue);

      await controller.stopAndCommitSession(notes: 'Completed Calculus homework');

      expect(controller.state.isRunning, isFalse);
      expect(controller.state.activeSession, isNull);
      expect(controller.state.todayTotal.inSeconds, equals(1800));
    });
  });
}
