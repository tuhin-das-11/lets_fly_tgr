import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../repositories/friends_repository_impl.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FriendsRepositoryImpl(supabase);
});

class FriendsState {
  final List<FriendEntity> friends;
  final List<FriendEntity> pendingRequests;
  final bool isLoading;

  const FriendsState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.isLoading = false,
  });

  FriendsState copyWith({
    List<FriendEntity>? friends,
    List<FriendEntity>? pendingRequests,
    bool? isLoading,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FriendsController extends StateNotifier<FriendsState> {
  final FriendsRepository _repository;
  final String _userId;

  FriendsController(this._repository, this._userId) : super(const FriendsState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final f = await _repository.getFriends(_userId);
      final p = await _repository.getPendingRequests(_userId);
      state = state.copyWith(friends: f, pendingRequests: p, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendRequest(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendFriendRequest(fromUserId: _userId, targetUsername: username);
      await refresh();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    await _repository.acceptFriendRequest(friendshipId);
    await refresh();
  }

  Future<void> declineRequest(String friendshipId) async {
    await _repository.declineFriendRequest(friendshipId);
    await refresh();
  }
}

final friendsControllerProvider =
    StateNotifierProvider<FriendsController, FriendsState>((ref) {
  final repo = ref.watch(friendsRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return FriendsController(repo, userId);
});
