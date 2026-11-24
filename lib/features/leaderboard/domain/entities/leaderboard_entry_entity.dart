/// Domain entity for an entry in the study leaderboard.
class LeaderboardEntryEntity {
  final int rank;
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final int studySeconds;
  final int streakDays;
  final bool isVerifiedOnly;
  final bool isCurrentUser;

  const LeaderboardEntryEntity({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    required this.studySeconds,
    this.streakDays = 0,
    this.isVerifiedOnly = true,
    this.isCurrentUser = false,
  });

  String get formattedDuration {
    final hours = studySeconds ~/ 3600;
    final minutes = (studySeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
