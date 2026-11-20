import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_datasource.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource _remoteDataSource;

  GroupsRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<GroupEntity>> watchMyGroups(String userId) {
    return Stream.fromFuture(getMyGroups(userId));
  }

  @override
  Future<List<GroupEntity>> getMyGroups(String userId) async {
    final list = await _remoteDataSource.getMyGroups(userId);
    if (list.isNotEmpty) return list;

    // Fallback seed groups for immediate rich offline & demo testing
    return [
      GroupEntity(
        id: 'group_gate_cse',
        name: 'GATE CSE 2027 Aspirants',
        description: 'Daily 6+ hours focus group for Computer Science engineering students.',
        inviteCode: 'GATE2027',
        ownerId: userId,
        maxMembers: 50,
        memberCount: 38,
        activeStudyingCount: 9,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      GroupEntity(
        id: 'group_deep_work',
        name: 'Deep Work Guild',
        description: 'Serious learners aiming for flow state sessions with zero phone distraction.',
        inviteCode: 'FLOW9988',
        ownerId: 'peer_deep_owner',
        maxMembers: 100,
        memberCount: 64,
        activeStudyingCount: 17,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  @override
  Future<List<GroupEntity>> getDiscoverGroups() async {
    final list = await _remoteDataSource.getDiscoverGroups();
    if (list.isNotEmpty) return list;

    return [
      GroupEntity(
        id: 'group_med_study',
        name: 'USMLE Step 1 Study Cohort',
        description: 'Medical students tackling pathology, anatomy, and high-yield reviews.',
        inviteCode: 'MEDSTEP1',
        ownerId: 'doc_user',
        memberCount: 82,
        activeStudyingCount: 21,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      GroupEntity(
        id: 'group_polyglot',
        name: 'Polyglot Society',
        description: 'Language immersion: Japanese, Korean, German, and Spanish learners.',
        inviteCode: 'LANGUAG1',
        ownerId: 'poly_user',
        memberCount: 29,
        activeStudyingCount: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  @override
  Future<GroupEntity> createGroup({
    required String ownerId,
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  }) async {
    return await _remoteDataSource.createGroup(
      ownerId: ownerId,
      name: name,
      description: description,
      isPrivate: isPrivate,
      maxMembers: maxMembers,
    );
  }

  @override
  Future<GroupEntity> joinGroupWithInviteCode({
    required String userId,
    required String inviteCode,
  }) async {
    return await _remoteDataSource.joinGroupByInviteCode(
      userId: userId,
      inviteCode: inviteCode,
    );
  }

  @override
  Future<void> joinPublicGroup({
    required String userId,
    required String groupId,
  }) async {
    await _remoteDataSource.joinGroup(userId: userId, groupId: groupId);
  }

  @override
  Future<void> leaveGroup({
    required String userId,
    required String groupId,
  }) async {
    await _remoteDataSource.leaveGroup(userId: userId, groupId: groupId);
  }

  @override
  Stream<List<GroupMemberEntity>> watchLiveRoom(String groupId) {
    return _remoteDataSource.watchLiveRoom(groupId);
  }
}
