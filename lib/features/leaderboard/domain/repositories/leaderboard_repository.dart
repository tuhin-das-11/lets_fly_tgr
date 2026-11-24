import 'entities/leaderboard_entry_entity.dart';

enum LeaderboardScope { global, friends, group }
enum LeaderboardPeriod { daily, weekly, monthly, allTime }

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntryEntity>> getLeaderboard({
    required LeaderboardScope scope,
    required LeaderboardPeriod period,
    required String currentUserId,
    String? groupId,
  });
}
