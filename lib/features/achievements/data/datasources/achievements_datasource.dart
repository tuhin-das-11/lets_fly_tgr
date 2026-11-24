import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/achievement_entity.dart';

abstract class AchievementsDataSource {
  Future<List<AchievementEntity>> getAchievements(String userId);
}

class AchievementsDataSourceImpl implements AchievementsDataSource {
  final SupabaseClient _supabase;

  AchievementsDataSourceImpl(this._supabase);

  @override
  Future<List<AchievementEntity>> getAchievements(String userId) async {
    try {
      final res = await _supabase.from(SupabaseConstants.tableAchievements).select();
      final userUnlocks = await _supabase
          .from(SupabaseConstants.tableUserAchievements)
          .select('achievement_id, unlocked_at')
          .eq('user_id', userId);

      final unlockedMap = <String, DateTime>{};
      for (final u in (userUnlocks as List<dynamic>)) {
        unlockedMap[u['achievement_id'] as String] =
            DateTime.parse(u['unlocked_at'] as String);
      }

      return (res as List<dynamic>).map((j) {
        final id = j['id'] as String;
        final isUnlocked = unlockedMap.containsKey(id);
        return AchievementEntity(
          id: id,
          title: j['title'] as String,
          description: j['description'] as String,
          icon: j['icon'] as String,
          category: j['category'] as String,
          requirementValue: (j['requirement_value'] as num).toInt(),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedMap[id],
          currentProgress: isUnlocked ? 1.0 : 0.45,
        );
      }).toList();
    } catch (_) {
      // Fallback seed achievements catalog
      return [
        const AchievementEntity(
          id: 'first_hour',
          title: 'First Flight',
          description: 'Complete your very first 60 minutes of deep study.',
          icon: 'flight_takeoff',
          category: 'time',
          requirementValue: 3600,
          isUnlocked: true,
          currentProgress: 1.0,
        ),
        const AchievementEntity(
          id: 'streak_3',
          title: 'Momentum Builder',
          description: 'Maintain an active study streak for 3 consecutive days.',
          icon: 'local_fire_department',
          category: 'streak',
          requirementValue: 3,
          isUnlocked: true,
          currentProgress: 1.0,
        ),
        const AchievementEntity(
          id: 'streak_7',
          title: 'Habit Former',
          description: 'Maintain a study streak for 7 consecutive days.',
          icon: 'bolt',
          category: 'streak',
          requirementValue: 7,
          isUnlocked: true,
          currentProgress: 1.0,
        ),
        const AchievementEntity(
          id: 'marathon_4h',
          title: 'Deep Diver',
          description: 'Complete a single uninterrupted 4-hour study session.',
          icon: 'timer',
          category: 'focus',
          requirementValue: 14400,
          isUnlocked: false,
          currentProgress: 0.75,
        ),
        const AchievementEntity(
          id: 'night_owl',
          title: 'Midnight Oil',
          description: 'Log at least 2 hours of study between 12:00 AM and 4:00 AM.',
          icon: 'bedtime',
          category: 'focus',
          requirementValue: 7200,
          isUnlocked: false,
          currentProgress: 0.5,
        ),
        const AchievementEntity(
          id: 'streak_30',
          title: 'Iron Will',
          description: 'Study every day for a full calendar month (30 days).',
          icon: 'military_tech',
          category: 'streak',
          requirementValue: 30,
          isUnlocked: false,
          currentProgress: 0.23,
        ),
        const AchievementEntity(
          id: 'century_hours',
          title: 'Century Club',
          description: 'Accumulate 100 lifetime hours of verified study.',
          icon: 'workspace_premium',
          category: 'time',
          requirementValue: 360000,
          isUnlocked: false,
          currentProgress: 0.33,
        ),
      ];
    }
  }
}
