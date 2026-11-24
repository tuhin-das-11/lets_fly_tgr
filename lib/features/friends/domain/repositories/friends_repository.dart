import 'entities/friend_entity.dart';

abstract class FriendsRepository {
  Future<List<FriendEntity>> getFriends(String userId);
  Future<List<FriendEntity>> getPendingRequests(String userId);
  Future<void> sendFriendRequest({required String fromUserId, required String targetUsername});
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> declineFriendRequest(String friendshipId);
  Future<void> removeFriend(String friendshipId);
}
