import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/subjects/domain/entities/subject_entity.dart';
import 'package:lets_fly_tgr/features/subjects/domain/repositories/subject_repository.dart';
import 'package:lets_fly_tgr/features/subjects/presentation/controllers/subjects_controller.dart';

class MockSubjectRepository implements SubjectRepository {
  final List<SubjectEntity> _subjects = [];

  @override
  Stream<List<SubjectEntity>> watchSubjects(String userId) => Stream.value(_subjects);

  @override
  Future<List<SubjectEntity>> getSubjects(String userId) async => List.from(_subjects);

  @override
  Future<SubjectEntity> createSubject({
    required String userId,
    required String name,
    required String colorHex,
    required String iconName,
    required String category,
    required int targetMinutesDaily,
  }) async {
    final sub = SubjectEntity(
      id: 'sub_${_subjects.length + 1}',
      userId: userId,
      name: name,
      colorHex: colorHex,
      iconName: iconName,
      category: category,
      targetMinutesDaily: targetMinutesDaily,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _subjects.add(sub);
    return sub;
  }

  @override
  Future<SubjectEntity> updateSubject(SubjectEntity subject) async {
    final idx = _subjects.indexWhere((s) => s.id == subject.id);
    if (idx != -1) _subjects[idx] = subject;
    return subject;
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.id == subjectId);
  }

  @override
  Future<void> reorderSubjects(List<String> subjectIdsInOrder) async {}

  @override
  Future<void> toggleArchive(String subjectId, bool isArchived) async {}
}

void main() {
  group('SubjectsController Unit Tests', () {
    late MockSubjectRepository mockRepo;
    late SubjectsController controller;

    setUp(() {
      mockRepo = MockSubjectRepository();
      controller = SubjectsController(mockRepo, 'test_user');
    });

    test('Creating a subject updates the state list', () async {
      await controller.createSubject(
        name: 'Algorithms',
        colorHex: '#4F46E5',
        iconName: 'code',
        category: 'CS',
        targetMinutesDaily: 120,
      );

      final list = controller.state.value;
      expect(list, isNotNull);
      expect(list!.length, equals(1));
      expect(list.first.name, equals('Algorithms'));
      expect(list.first.targetMinutesDaily, equals(120));
    });

    test('Deleting a subject removes it from state', () async {
      await controller.createSubject(
        name: 'Physics',
        colorHex: '#10B981',
        iconName: 'science',
        category: 'Sci',
        targetMinutesDaily: 60,
      );
      expect(controller.state.value?.length, equals(1));

      final id = controller.state.value!.first.id;
      await controller.deleteSubject(id);

      expect(controller.state.value?.length, equals(0));
    });
  });
}
