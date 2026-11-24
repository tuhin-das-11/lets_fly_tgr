class FriendEntity {
  final String friendshipId;
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final bool isStudyingNow;
  final String? currentSubjectName;
  final String? currentSubjectColor;
  final Duration? currentDuration;
  final int streakDays;
  final String status; // 'accepted', 'pending_incoming', 'pending_outgoing'

  const FriendEntity({
    required this.friendshipId,
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.isStudyingNow = false,
    this.currentSubjectName,
    this.currentSubjectColor,
    this.currentDuration,
    this.streakDays = 0,
    this.status = 'accepted',
  });
}
