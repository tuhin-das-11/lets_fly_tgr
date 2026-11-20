import '../domain/entities/group_entity.dart';

/// DTO for group serialization.
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description = '',
    super.avatarUrl,
    super.isPrivate = false,
    required super.inviteCode,
    required super.ownerId,
    super.maxMembers = 50,
    super.memberCount = 1,
    super.activeStudyingCount = 0,
    required super.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      inviteCode: json['invite_code'] as String,
      ownerId: json['owner_id'] as String,
      maxMembers: (json['max_members'] as num?)?.toInt() ?? 50,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 1,
      activeStudyingCount: (json['active_studying_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'is_private': isPrivate,
      'invite_code': inviteCode,
      'owner_id': ownerId,
      'max_members': maxMembers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
