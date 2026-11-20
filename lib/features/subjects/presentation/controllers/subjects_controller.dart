import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_datasource.dart';
import '../datasources/subject_remote_datasource.dart';
import '../repositories/subject_repository_impl.dart';

/// Provider for SubjectRepository.
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return SubjectRepositoryImpl(
    SubjectLocalDataSourceImpl(db),
    SubjectRemoteDataSourceImpl(supabase),
  );
});

/// Riverpod StateNotifier managing the user's subjects list.
class SubjectsController extends StateNotifier<AsyncValue<List<SubjectEntity>>> {
  final SubjectRepository _repository;
  final String _userId;

  SubjectsController(this._repository, this._userId) : super(const AsyncValue.loading()) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      final list = await _repository.getSubjects(_userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createSubject({
    required String name,
    required String colorHex,
    required String iconName,
    required String category,
    required int targetMinutesDaily,
  }) async {
    try {
      await _repository.createSubject(
        userId: _userId,
        name: name,
        colorHex: colorHex,
        iconName: iconName,
        category: category,
        targetMinutesDaily: targetMinutesDaily,
      );
      await loadSubjects();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateSubject(SubjectEntity subject) async {
    try {
      await _repository.updateSubject(subject);
      await loadSubjects();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _repository.deleteSubject(subjectId);
      await loadSubjects();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> reorderSubjects(List<String> subjectIdsInOrder) async {
    try {
      await _repository.reorderSubjects(subjectIdsInOrder);
      await loadSubjects();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final subjectsControllerProvider =
    StateNotifierProvider<SubjectsController, AsyncValue<List<SubjectEntity>>>((ref) {
  final repo = ref.watch(subjectRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return SubjectsController(repo, userId);
});
