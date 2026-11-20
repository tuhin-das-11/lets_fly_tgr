import '../domain/entities/active_session_entity.dart';

/// DTO for server-authoritative active sessions.
class ActiveSessionModel extends ActiveSessionEntity {
  const ActiveSessionModel({
    required super.userId,
    required super.subjectId,
    required super.deviceId,
    required super.platform,
    required super.startedAt,
    required super.lastHeartbeat,
    super.status = 'running',
    super.pausedSecondsTotal = 0,
    super.sessionType = 'stopwatch',
    required super.updatedAt,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      deviceId: json['device_id'] as String,
      platform: json['platform'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      lastHeartbeat: DateTime.parse(json['last_heartbeat'] as String),
      status: json['status'] as String? ?? 'running',
      pausedSecondsTotal: (json['paused_seconds_total'] as num?)?.toInt() ?? 0,
      sessionType: json['session_type'] as String? ?? 'stopwatch',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subject_id': subjectId,
      'device_id': deviceId,
      'platform': platform,
      'started_at': startedAt.toIso8601String(),
      'last_heartbeat': lastHeartbeat.toIso8601String(),
      'status': status,
      'paused_seconds_total': pausedSecondsTotal,
      'session_type': sessionType,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ActiveSessionModel.fromEntity(ActiveSessionEntity entity) {
    return ActiveSessionModel(
      userId: entity.userId,
      subjectId: entity.subjectId,
      deviceId: entity.deviceId,
      platform: entity.platform,
      startedAt: entity.startedAt,
      lastHeartbeat: entity.lastHeartbeat,
      status: entity.status,
      pausedSecondsTotal: entity.pausedSecondsTotal,
      sessionType: entity.sessionType,
      updatedAt: entity.updatedAt,
    );
  }
}
