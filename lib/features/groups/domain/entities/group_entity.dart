/// Domain entity for study groups.
class GroupEntity {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final bool isPrivate;
  final String inviteCode;
  final String ownerId;
  final int maxMembers;
  final int memberCount;
  final int activeStudyingCount;
  final DateTime createdAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl,
    this.isPrivate = false,
    required this.inviteCode,
    required this.ownerId,
    this.maxMembers = 50,
    this.memberCount = 1,
    this.activeStudyingCount = 0,
    required this.createdAt,
  });

  GroupEntity copyWith({
    String? name,
    String? description,
    String? avatarUrl,
    bool? isPrivate,
    int? memberCount,
    int? activeStudyingCount,
  }) {
    return GroupEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      inviteCode: inviteCode,
      ownerId: ownerId,
      maxMembers: maxMembers,
      memberCount: memberCount ?? this.memberCount,
      activeStudyingCount: activeStudyingCount ?? this.activeStudyingCount,
      createdAt: createdAt,
    );
  }
}
