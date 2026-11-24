import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../repositories/leaderboard_repository_impl.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return LeaderboardRepositoryImpl(supabase);
});

class LeaderboardState {
  final List<LeaderboardEntryEntity> entries;
  final LeaderboardScope scope;
  final LeaderboardPeriod period;
  final bool isLoading;

  const LeaderboardState({
    this.entries = const [],
    this.scope = LeaderboardScope.global,
    this.period = LeaderboardPeriod.daily,
    this.isLoading = false,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntryEntity>? entries,
    LeaderboardScope? scope,
    LeaderboardPeriod? period,
    bool? isLoading,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      scope: scope ?? this.scope,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LeaderboardController extends StateNotifier<LeaderboardState> {
  final LeaderboardRepository _repository;
  final String _currentUserId;

  LeaderboardController(this._repository, this._currentUserId) : super(const LeaderboardState()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getLeaderboard(
        scope: state.scope,
        period: state.period,
        currentUserId: _currentUserId,
      );
      state = state.copyWith(entries: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setScope(LeaderboardScope scope) {
    state = state.copyWith(scope: scope);
    loadLeaderboard();
  }

  void setPeriod(LeaderboardPeriod period) {
    state = state.copyWith(period: period);
    loadLeaderboard();
  }
}

final leaderboardControllerProvider =
    StateNotifierProvider<LeaderboardController, LeaderboardState>((ref) {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return LeaderboardController(repo, userId);
});
