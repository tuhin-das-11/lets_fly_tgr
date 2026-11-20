import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_datasource.dart';
import '../repositories/groups_repository_impl.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return GroupsRepositoryImpl(
    GroupsRemoteDataSourceImpl(supabase),
  );
});

class GroupsState {
  final List<GroupEntity> myGroups;
  final List<GroupEntity> discoverGroups;
  final bool isLoading;
  final String? errorMessage;

  const GroupsState({
    this.myGroups = const [],
    this.discoverGroups = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GroupsState copyWith({
    List<GroupEntity>? myGroups,
    List<GroupEntity>? discoverGroups,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GroupsState(
      myGroups: myGroups ?? this.myGroups,
      discoverGroups: discoverGroups ?? this.discoverGroups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class GroupsController extends StateNotifier<GroupsState> {
  final GroupsRepository _repository;
  final String _userId;

  GroupsController(this._repository, this._userId) : super(const GroupsState()) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final my = await _repository.getMyGroups(_userId);
      final disc = await _repository.getDiscoverGroups();
      state = state.copyWith(myGroups: my, discoverGroups: disc, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required bool isPrivate,
    int maxMembers = 50,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _repository.createGroup(
        ownerId: _userId,
        name: name,
        description: description,
        isPrivate: isPrivate,
        maxMembers: maxMembers,
      );
      state = state.copyWith(
        myGroups: [...state.myGroups, created],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> joinWithCode(String inviteCode) async {
    state = state.copyWith(isLoading: true);
    try {
      final joined = await _repository.joinGroupWithInviteCode(
        userId: _userId,
        inviteCode: inviteCode,
      );
      state = state.copyWith(
        myGroups: [...state.myGroups, joined],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.leaveGroup(userId: _userId, groupId: groupId);
      state = state.copyWith(
        myGroups: state.myGroups.where((g) => g.id != groupId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final groupsControllerProvider =
    StateNotifierProvider<GroupsController, GroupsState>((ref) {
  final repo = ref.watch(groupsRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return GroupsController(repo, userId);
});
