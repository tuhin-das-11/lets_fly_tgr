/// Server-authoritative active session domain entity for cross-device synchronization.
class ActiveSessionEntity {
  final String userId;
  final String subjectId;
  final String deviceId;
  final String platform; // 'android', 'windows', 'web'
  final DateTime startedAt;
  final DateTime lastHeartbeat;
  final String status; // 'running', 'paused'
  final int pausedSecondsTotal;
  final String sessionType;
  final DateTime updatedAt;

  const ActiveSessionEntity({
    required this.userId,
    required this.subjectId,
    required this.deviceId,
    required this.platform,
    required this.startedAt,
    required this.lastHeartbeat,
    this.status = 'running',
    this.pausedSecondsTotal = 0,
    this.sessionType = 'stopwatch',
    required this.updatedAt,
  });

  bool get isRunning => status == 'running';
  bool get isPaused => status == 'paused';

  /// Calculates real elapsed duration taking into account start time and paused segments.
  Duration calculateCurrentDuration() {
    final now = DateTime.now();
    if (isPaused) {
      final totalElapsed = lastHeartbeat.difference(startedAt).inSeconds;
      return Duration(seconds: (totalElapsed - pausedSecondsTotal).clamp(0, 86400));
    } else {
      final totalElapsed = now.difference(startedAt).inSeconds;
      return Duration(seconds: (totalElapsed - pausedSecondsTotal).clamp(0, 86400));
    }
  }

  ActiveSessionEntity copyWith({
    String? subjectId,
    String? deviceId,
    String? platform,
    String? status,
    int? pausedSecondsTotal,
    DateTime? lastHeartbeat,
    DateTime? updatedAt,
  }) {
    return ActiveSessionEntity(
      userId: userId,
      subjectId: subjectId ?? this.subjectId,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      startedAt: startedAt,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      status: status ?? this.status,
      pausedSecondsTotal: pausedSecondsTotal ?? this.pausedSecondsTotal,
      sessionType: sessionType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
