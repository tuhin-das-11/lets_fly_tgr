import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/active_session_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/study_timer_repository.dart';
import '../datasources/study_timer_remote_datasource.dart';
import '../models/active_session_model.dart';
import '../models/study_session_model.dart';

/// Repository implementation ensuring server-authoritative cross-device session tracking.
class StudyTimerRepositoryImpl implements StudyTimerRepository {
  final StudyTimerRemoteDataSource _remoteDataSource;
  final _uuid = const Uuid();

  StudyTimerRepositoryImpl(this._remoteDataSource);

  @override
  Stream<ActiveSessionEntity?> watchActiveSession(String userId) {
    return _remoteDataSource.watchActiveSession(userId);
  }

  @override
  Future<ActiveSessionEntity?> getActiveSession(String userId) async {
    return await _remoteDataSource.getActiveSession(userId);
  }

  @override
  Future<ActiveSessionEntity> startSession({
    required String userId,
    required String subjectId,
    required String deviceId,
    required String platform,
    String sessionType = 'stopwatch',
  }) async {
    final now = DateTime.now();
    final model = ActiveSessionModel(
      userId: userId,
      subjectId: subjectId,
      deviceId: deviceId,
      platform: platform,
      startedAt: now,
      lastHeartbeat: now,
      status: 'running',
      pausedSecondsTotal: 0,
      sessionType: sessionType,
      updatedAt: now,
    );

    return await _remoteDataSource.upsertActiveSession(model);
  }

  @override
  Future<ActiveSessionEntity> pauseSession(String userId) async {
    final existing = await _remoteDataSource.getActiveSession(userId);
    if (existing == null) throw Exception('No running active session found');

    final updated = existing.copyWith(
      status: 'paused',
      lastHeartbeat: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _remoteDataSource.upsertActiveSession(ActiveSessionModel.fromEntity(updated));
  }

  @override
  Future<ActiveSessionEntity> resumeSession(String userId) async {
    final existing = await _remoteDataSource.getActiveSession(userId);
    if (existing == null) throw Exception('No active session to resume');

    final now = DateTime.now();
    // Accumulate the duration spent while paused
    final pauseDelta = now.difference(existing.lastHeartbeat).inSeconds;
    final updated = existing.copyWith(
      status: 'running',
      pausedSecondsTotal: existing.pausedSecondsTotal + pauseDelta,
      lastHeartbeat: now,
      updatedAt: now,
    );

    return await _remoteDataSource.upsertActiveSession(ActiveSessionModel.fromEntity(updated));
  }

  @override
  Future<void> sendHeartbeat(String userId) async {
    final existing = await _remoteDataSource.getActiveSession(userId);
    if (existing != null && existing.isRunning) {
      final updated = existing.copyWith(
        lastHeartbeat: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _remoteDataSource.upsertActiveSession(ActiveSessionModel.fromEntity(updated));
    }
  }

  @override
  Future<StudySessionEntity> stopAndCommitSession({
    required String userId,
    required String notes,
  }) async {
    final active = await _remoteDataSource.getActiveSession(userId);
    if (active == null) throw Exception('No active session found to commit');

    final now = DateTime.now();
    final duration = active.calculateCurrentDuration().inSeconds;

    final completedSession = StudySessionModel(
      id: _uuid.v4(),
      userId: userId,
      subjectId: active.subjectId,
      startedAt: active.startedAt,
      endedAt: now,
      durationSeconds: duration,
      deviceId: active.deviceId,
      sessionType: active.sessionType,
      isVerified: true,
      notes: notes,
      createdAt: now,
    );

    // Commit to permanent study log
    final committed = await _remoteDataSource.commitCompletedSession(completedSession);

    // Clear active session slot
    await _remoteDataSource.deleteActiveSession(userId);

    return committed;
  }

  @override
  Future<void> discardActiveSession(String userId) async {
    await _remoteDataSource.deleteActiveSession(userId);
  }

  @override
  Future<ActiveSessionEntity> takeOverSession({
    required String userId,
    required String newDeviceId,
    required String newPlatform,
  }) async {
    final existing = await _remoteDataSource.getActiveSession(userId);
    if (existing == null) throw Exception('No active session to take over');

    final updated = existing.copyWith(
      deviceId: newDeviceId,
      platform: newPlatform,
      lastHeartbeat: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _remoteDataSource.upsertActiveSession(ActiveSessionModel.fromEntity(updated));
  }

  @override
  Future<Duration> getTodayTotalDuration(String userId) async {
    final seconds = await _remoteDataSource.getTodayTotalSeconds(userId);
    return Duration(seconds: seconds);
  }
}
