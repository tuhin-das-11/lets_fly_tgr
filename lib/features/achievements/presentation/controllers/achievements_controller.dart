import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/achievement_entity.dart';
import '../datasources/achievements_datasource.dart';

final achievementsDataSourceProvider = Provider<AchievementsDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AchievementsDataSourceImpl(supabase);
});

final achievementsProvider =
    FutureProvider.autoDispose<List<AchievementEntity>>((ref) async {
  final ds = ref.watch(achievementsDataSourceProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return await ds.getAchievements(userId);
});
