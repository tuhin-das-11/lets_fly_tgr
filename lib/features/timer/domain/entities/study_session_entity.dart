/// Completed study session domain entity.
class StudySessionEntity {
  final String id;
  final String userId;
  final String subjectId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final String deviceId;
  final String sessionType; // 'stopwatch', 'pomodoro_focus', 'manual'
  final bool isVerified;
  final String notes;
  final DateTime createdAt;

  const StudySessionEntity({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.deviceId,
    this.sessionType = 'stopwatch',
    this.isVerified = true,
    this.notes = '',
    required this.createdAt,
  });
}
