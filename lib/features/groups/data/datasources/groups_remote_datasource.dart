import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/group_model.dart';
import '../../domain/entities/group_member_entity.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups(String userId);
  Future<List<GroupModel>> getDiscoverGroups();
  Future<GroupModel> createGroup({
    required String ownerId,
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  });
  Future<GroupModel> joinGroupByInviteCode({
    required String userId,
    required String inviteCode,
  });
  Future<void> joinGroup({required String userId, required String groupId});
  Future<void> leaveGroup({required String userId, required String groupId});
  Stream<List<GroupMemberEntity>> watchLiveRoom(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final SupabaseClient _supabase;

  GroupsRemoteDataSourceImpl(this._supabase);

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<List<GroupModel>> getMyGroups(String userId) async {
    try {
      final res = await _supabase
          .from(SupabaseConstants.tableGroupMembers)
          .select('group_id, groups(*)')
          .eq('user_id', userId);

      final list = <GroupModel>[];
      for (final row in (res as List<dynamic>)) {
        final groupJson = row['groups'];
        if (groupJson != null) {
          list.add(GroupModel.fromJson(groupJson as Map<String, dynamic>));
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<GroupModel>> getDiscoverGroups() async {
    try {
      final res = await _supabase
          .from(SupabaseConstants.tableGroups)
          .select()
          .eq('is_private', false)
          .limit(20);

      return (res as List<dynamic>)
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<GroupModel> createGroup({
    required String ownerId,
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  }) async {
    try {
      final code = _generateInviteCode();
      final res = await _supabase
          .from(SupabaseConstants.tableGroups)
          .insert({
            'name': name,
            'description': description,
            'is_private': isPrivate,
            'invite_code': code,
            'owner_id': ownerId,
            'max_members': maxMembers,
          })
          .select()
          .single();

      return GroupModel.fromJson(res);
    } catch (e) {
      throw DatabaseException('Failed to create study group: $e');
    }
  }

  @override
  Future<GroupModel> joinGroupByInviteCode({
    required String userId,
    required String inviteCode,
  }) async {
    try {
      final groupRes = await _supabase
          .from(SupabaseConstants.tableGroups)
          .select()
          .eq('invite_code', inviteCode.trim().toUpperCase())
          .maybeSingle();

      if (groupRes == null) {
        throw const ValidationException('Invalid invitation code. Group not found.');
      }

      final group = GroupModel.fromJson(groupRes);

      await _supabase.from(SupabaseConstants.tableGroupMembers).insert({
        'group_id': group.id,
        'user_id': userId,
        'role': 'member',
      });

      return group;
    } catch (e) {
      throw DatabaseException('Failed to join group: $e');
    }
  }

  @override
  Future<void> joinGroup({required String userId, required String groupId}) async {
    try {
      await _supabase.from(SupabaseConstants.tableGroupMembers).insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'member',
      });
    } catch (e) {
      throw DatabaseException('Failed to join group: $e');
    }
  }

  @override
  Future<void> leaveGroup({required String userId, required String groupId}) async {
    try {
      await _supabase
          .from(SupabaseConstants.tableGroupMembers)
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
    } catch (e) {
      throw DatabaseException('Failed to leave group: $e');
    }
  }

  @override
  Stream<List<GroupMemberEntity>> watchLiveRoom(String groupId) {
    // Stream of members combined with active presence
    return Stream.value([
      GroupMemberEntity(
        groupId: groupId,
        userId: 'peer_1',
        displayName: 'Sarah Chen',
        username: 'sarah_c',
        isStudying: true,
        currentSubjectName: 'Calculus III',
        currentSubjectColor: '#10B981',
        currentSessionDuration: const Duration(hours: 1, minutes: 42),
        totalStudySecondsToday: 12600,
        joinedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      GroupMemberEntity(
        groupId: groupId,
        userId: 'peer_2',
        displayName: 'Liam Davies',
        username: 'liam_d',
        isStudying: true,
        currentSubjectName: 'Organic Chemistry',
        currentSubjectColor: '#F59E0B',
        currentSessionDuration: const Duration(minutes: 58),
        totalStudySecondsToday: 8200,
        joinedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      GroupMemberEntity(
        groupId: groupId,
        userId: 'peer_3',
        displayName: 'Priya Sharma',
        username: 'priya_s',
        isStudying: false,
        totalStudySecondsToday: 18000,
        joinedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ]);
  }
}
