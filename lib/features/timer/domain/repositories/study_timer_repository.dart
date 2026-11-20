import 'entities/active_session_entity.dart';
import 'entities/study_session_entity.dart';

/// Contract for Study Timer execution, cross-device sync, and session commitment.
abstract class StudyTimerRepository {
  /// Stream of active session changes for this user across all their devices.
  Stream<ActiveSessionEntity?> watchActiveSession(String userId);

  /// Fetch active session from cloud (server-authoritative).
  Future<ActiveSessionEntity?> getActiveSession(String userId);

  /// Starts a new active session on this device.
  Future<ActiveSessionEntity> startSession({
    required String userId,
    required String subjectId,
    required String deviceId,
    required String platform,
    String sessionType = 'stopwatch',
  });

  /// Pauses the running active session.
  Future<ActiveSessionEntity> pauseSession(String userId);

  /// Resumes a paused active session.
  Future<ActiveSessionEntity> resumeSession(String userId);

  /// Sends periodic 30s heartbeat to confirm session ownership.
  Future<void> sendHeartbeat(String userId);

  /// Stops the active session, commits it into study_sessions, and cleans active_sessions.
  Future<StudySessionEntity> stopAndCommitSession({
    required String userId,
    required String notes,
  });

  /// Cancels active session without recording (discards).
  Future<void> discardActiveSession(String userId);

  /// Force takeover of an active session running on another device.
  Future<ActiveSessionEntity> takeOverSession({
    required String userId,
    required String newDeviceId,
    required String newPlatform,
  });

  /// Retrieves today's total study duration for user.
  Future<Duration> getTodayTotalDuration(String userId);
}
