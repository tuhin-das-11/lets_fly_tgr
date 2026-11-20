import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/active_session_model.dart';
import '../models/study_session_model.dart';

/// Remote data source managing active session synchronization and session commits via Supabase.
abstract class StudyTimerRemoteDataSource {
  Stream<ActiveSessionModel?> watchActiveSession(String userId);
  Future<ActiveSessionModel?> getActiveSession(String userId);
  Future<ActiveSessionModel> upsertActiveSession(ActiveSessionModel session);
  Future<void> deleteActiveSession(String userId);
  Future<StudySessionModel> commitCompletedSession(StudySessionModel session);
  Future<int> getTodayTotalSeconds(String userId);
}

class StudyTimerRemoteDataSourceImpl implements StudyTimerRemoteDataSource {
  final SupabaseClient _supabase;

  StudyTimerRemoteDataSourceImpl(this._supabase);

  @override
  Stream<ActiveSessionModel?> watchActiveSession(String userId) {
    return _supabase
        .from(SupabaseConstants.tableActiveSessions)
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((list) {
          if (list.isEmpty) return null;
          return ActiveSessionModel.fromJson(list.first);
        });
  }

  @override
  Future<ActiveSessionModel?> getActiveSession(String userId) async {
    try {
      final res = await _supabase
          .from(SupabaseConstants.tableActiveSessions)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (res == null) return null;
      return ActiveSessionModel.fromJson(res);
    } catch (e) {
      throw DatabaseException('Failed to retrieve active session: $e');
    }
  }

  @override
  Future<ActiveSessionModel> upsertActiveSession(ActiveSessionModel session) async {
    try {
      final res = await _supabase
          .from(SupabaseConstants.tableActiveSessions)
          .upsert(session.toJson())
          .select()
          .single();

      return ActiveSessionModel.fromJson(res);
    } catch (e) {
      throw DatabaseException('Failed to synchronize active session: $e');
    }
  }

  @override
  Future<void> deleteActiveSession(String userId) async {
    try {
      await _supabase
          .from(SupabaseConstants.tableActiveSessions)
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw DatabaseException('Failed to clear active session: $e');
    }
  }

  @override
  Future<StudySessionModel> commitCompletedSession(StudySessionModel session) async {
    try {
      final res = await _supabase
          .from(SupabaseConstants.tableStudySessions)
          .insert(session.toJson())
          .select()
          .single();

      return StudySessionModel.fromJson(res);
    } catch (e) {
      throw DatabaseException('Failed to record study session: $e');
    }
  }

  @override
  Future<int> getTodayTotalSeconds(String userId) async {
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final res = await _supabase
          .from(SupabaseConstants.tableStudySessions)
          .select('duration_seconds')
          .eq('user_id', userId)
          .gte('started_at', '$todayStr 00:00:00');

      int total = 0;
      for (final item in (res as List<dynamic>)) {
        total += (item['duration_seconds'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}
