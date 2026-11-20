import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/subject_model.dart';

/// Remote data source accessing Supabase PostgreSQL subjects table.
abstract class SubjectRemoteDataSource {
  Future<List<SubjectModel>> getRemoteSubjects(String userId);
  Future<SubjectModel> createSubject(SubjectModel subject);
  Future<SubjectModel> updateSubject(SubjectModel subject);
  Future<void> deleteSubject(String subjectId);
  Future<void> reorderSubjects(List<String> subjectIdsInOrder);
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final SupabaseClient _supabase;

  SubjectRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<SubjectModel>> getRemoteSubjects(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tableSubjects)
          .select()
          .eq('user_id', userId)
          .order('sort_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch subjects from cloud: $e');
    }
  }

  @override
  Future<SubjectModel> createSubject(SubjectModel subject) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tableSubjects)
          .insert(subject.toJson())
          .select()
          .single();

      return SubjectModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to create subject in cloud: $e');
    }
  }

  @override
  Future<SubjectModel> updateSubject(SubjectModel subject) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tableSubjects)
          .update(subject.toJson())
          .eq('id', subject.id)
          .select()
          .single();

      return SubjectModel.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to update subject in cloud: $e');
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      await _supabase
          .from(SupabaseConstants.tableSubjects)
          .delete()
          .eq('id', subjectId);
    } catch (e) {
      throw DatabaseException('Failed to delete subject from cloud: $e');
    }
  }

  @override
  Future<void> reorderSubjects(List<String> subjectIdsInOrder) async {
    try {
      for (int i = 0; i < subjectIdsInOrder.length; i++) {
        await _supabase
            .from(SupabaseConstants.tableSubjects)
            .update({'sort_order': i})
            .eq('id', subjectIdsInOrder[i]);
      }
    } catch (e) {
      throw DatabaseException('Failed to persist subject order: $e');
    }
  }
}
