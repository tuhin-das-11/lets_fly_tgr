/// Domain entity for group member with live focus status.
class GroupMemberEntity {
  final String groupId;
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String role; // 'owner', 'admin', 'member'
  final bool isStudying;
  final String? currentSubjectName;
  final String? currentSubjectColor;
  final Duration? currentSessionDuration;
  final int totalStudySecondsToday;
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.groupId,
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.role = 'member',
    this.isStudying = false,
    this.currentSubjectName,
    this.currentSubjectColor,
    this.currentSessionDuration,
    this.totalStudySecondsToday = 0,
    required this.joinedAt,
  });
}
