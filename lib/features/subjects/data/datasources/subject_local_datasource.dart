import '../../../../core/database/app_database.dart';
import '../models/subject_model.dart';
import '../../domain/entities/subject_entity.dart';

/// Local data source interface for caching subjects in SQLite via Drift.
abstract class SubjectLocalDataSource {
  Future<List<SubjectModel>> getLocalSubjects(String userId);
  Future<void> saveSubjects(List<SubjectModel> subjects);
  Future<void> upsertSubject(SubjectModel subject);
  Future<void> deleteSubject(String subjectId);
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final AppDatabase _db;

  SubjectLocalDataSourceImpl(this._db);

  @override
  Future<List<SubjectModel>> getLocalSubjects(String userId) async {
    // In-memory / Drift fallback
    return [];
  }

  @override
  Future<void> saveSubjects(List<SubjectModel> subjects) async {
    // Cache batch
  }

  @override
  Future<void> upsertSubject(SubjectModel subject) async {
    // Upsert single
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    // Delete single
  }
}
