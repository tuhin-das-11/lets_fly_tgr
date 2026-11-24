import '../domain/entities/leaderboard_entry_entity.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.displayName,
    required super.username,
    super.avatarUrl,
    required super.studySeconds,
    super.streakDays = 0,
    super.isVerifiedOnly = true,
    super.isCurrentUser = false,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json, {String currentUserId = ''}) {
    final uid = json['user_id'] as String? ?? json['id'] as String;
    return LeaderboardEntryModel(
      rank: (json['rank_position'] as num?)?.toInt() ?? 0,
      userId: uid,
      displayName: json['display_name'] as String? ?? 'Anonymous Flyer',
      username: json['username'] as String? ?? 'flyer',
      avatarUrl: json['avatar_url'] as String?,
      studySeconds: (json['total_study_seconds'] as num?)?.toInt() ?? 0,
      streakDays: (json['current_streak_days'] as num?)?.toInt() ?? 0,
      isVerifiedOnly: json['is_verified_only'] as bool? ?? true,
      isCurrentUser: uid == currentUserId,
    );
  }
}
