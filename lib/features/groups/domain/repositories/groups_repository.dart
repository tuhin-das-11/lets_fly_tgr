import 'entities/group_entity.dart';
import 'entities/group_member_entity.dart';

/// Contract for Study Groups, live rooms, and invitations.
abstract class GroupsRepository {
  /// Stream of user's joined groups.
  Stream<List<GroupEntity>> watchMyGroups(String userId);

  /// Fetch user's joined groups.
  Future<List<GroupEntity>> getMyGroups(String userId);

  /// Discover public study groups.
  Future<List<GroupEntity>> getDiscoverGroups();

  /// Create a new study group with auto-generated 8-char invite code.
  Future<GroupEntity> createGroup({
    required String ownerId,
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  });

  /// Join a group using an 8-character invite code.
  Future<GroupEntity> joinGroupWithInviteCode({
    required String userId,
    required String inviteCode,
  });

  /// Join a public group directly.
  Future<void> joinPublicGroup({
    required String userId,
    required String groupId,
  });

  /// Leave a study group.
  Future<void> leaveGroup({
    required String userId,
    required String groupId,
  });

  /// Real-time live room participants with active study state.
  Stream<List<GroupMemberEntity>> watchLiveRoom(String groupId);
}
