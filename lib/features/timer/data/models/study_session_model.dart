import '../domain/entities/study_session_entity.dart';

/// DTO for completed study sessions.
class StudySessionModel extends StudySessionEntity {
  const StudySessionModel({
    required super.id,
    required super.userId,
    required super.subjectId,
    required super.startedAt,
    required super.endedAt,
    required super.durationSeconds,
    required super.deviceId,
    super.sessionType = 'stopwatch',
    super.isVerified = true,
    super.notes = '',
    required super.createdAt,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      deviceId: json['device_id'] as String,
      sessionType: json['session_type'] as String? ?? 'stopwatch',
      isVerified: json['is_verified'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'duration_seconds': durationSeconds,
      'device_id': deviceId,
      'session_type': sessionType,
      'is_verified': isVerified,
      'notes': notes,
    };
  }
}
