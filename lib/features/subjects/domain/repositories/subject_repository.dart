import 'entities/subject_entity.dart';

/// Contract for Subject CRUD and reordering operations.
abstract class SubjectRepository {
  /// Stream of active subjects for reactive UI updates.
  Stream<List<SubjectEntity>> watchSubjects(String userId);

  /// Fetch all subjects (local with remote sync fallback).
  Future<List<SubjectEntity>> getSubjects(String userId);

  /// Create a new study subject.
  Future<SubjectEntity> createSubject({
    required String userId,
    required String name,
    required String colorHex,
    required String iconName,
    required String category,
    required int targetMinutesDaily,
  });

  /// Update existing subject details.
  Future<SubjectEntity> updateSubject(SubjectEntity subject);

  /// Delete a subject.
  Future<void> deleteSubject(String subjectId);

  /// Reorder subject prioritization.
  Future<void> reorderSubjects(List<String> subjectIdsInOrder);

  /// Toggle subject archived state.
  Future<void> toggleArchive(String subjectId, bool isArchived);
}
