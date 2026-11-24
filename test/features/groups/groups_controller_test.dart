import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/groups/domain/entities/group_entity.dart';
import 'package:lets_fly_tgr/features/groups/domain/entities/group_member_entity.dart';
import 'package:lets_fly_tgr/features/groups/domain/repositories/groups_repository.dart';
import 'package:lets_fly_tgr/features/groups/presentation/controllers/groups_controller.dart';

class MockGroupsRepository implements GroupsRepository {
  final List<GroupEntity> _groups = [];

  @override
  Stream<List<GroupEntity>> watchMyGroups(String userId) => Stream.value(_groups);

  @override
  Future<List<GroupEntity>> getMyGroups(String userId) async => List.from(_groups);

  @override
  Future<List<GroupEntity>> getDiscoverGroups() async => [];

  @override
  Future<GroupEntity> createGroup({
    required String ownerId,
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  }) async {
    final g = GroupEntity(
      id: 'group_test_1',
      name: name,
      description: description,
      isPrivate: isPrivate,
      inviteCode: 'TEST1234',
      ownerId: ownerId,
      createdAt: DateTime.now(),
    );
    _groups.add(g);
    return g;
  }

  @override
  Future<GroupEntity> joinGroupWithInviteCode({
    required String userId,
    required String inviteCode,
  }) async {
    final g = GroupEntity(
      id: 'group_joined_1',
      name: 'Joined Group',
      inviteCode: inviteCode,
      ownerId: 'peer',
      createdAt: DateTime.now(),
    );
    _groups.add(g);
    return g;
  }

  @override
  Future<void> joinPublicGroup({required String userId, required String groupId}) async {}

  @override
  Future<void> leaveGroup({required String userId, required String groupId}) async {
    _groups.removeWhere((g) => g.id == groupId);
  }

  @override
  Stream<List<GroupMemberEntity>> watchLiveRoom(String groupId) => Stream.value([]);
}

void main() {
  group('GroupsController Unit Tests', () {
    late MockGroupsRepository repo;
    late GroupsController controller;

    setUp(() {
      repo = MockGroupsRepository();
      controller = GroupsController(repo, 'user_test');
    });

    test('Creating a study group adds it to myGroups', () async {
      await controller.createGroup(
        name: 'Calculus Study Circle',
        description: 'Focus room',
        isPrivate: false,
      );

      expect(controller.state.myGroups.length, equals(1));
      expect(controller.state.myGroups.first.name, equals('Calculus Study Circle'));
      expect(controller.state.myGroups.first.inviteCode, equals('TEST1234'));
    });

    test('Leaving a group removes it from myGroups', () async {
      await controller.createGroup(
        name: 'Temporary Room',
        description: 'Testing leave',
        isPrivate: false,
      );
      expect(controller.state.myGroups.length, equals(1));

      await controller.leaveGroup('group_test_1');
      expect(controller.state.myGroups.length, equals(0));
    });
  });
}
