import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/notion/domain/entities/notion_page_entity.dart';
import 'package:lets_fly_tgr/features/notion/domain/repositories/notion_repository.dart';
import 'package:lets_fly_tgr/features/notion/presentation/controllers/notion_controller.dart';

class MockNotionRepository implements NotionRepository {
  bool _connected = false;
  final List<NotionPageEntity> _pages = [
    NotionPageEntity(
      id: 'mock_page_1',
      title: 'Operating Systems: Concurrency & Semaphores',
      lastEditedTime: DateTime.now(),
    ),
  ];

  @override
  Future<bool> isConnected(String userId) async => _connected;

  @override
  Future<void> connectNotion({
    required String userId,
    required String accessToken,
    required String workspaceName,
    required String workspaceId,
  }) async {
    _connected = true;
  }

  @override
  Future<void> disconnectNotion(String userId) async {
    _connected = false;
  }

  @override
  Future<List<NotionPageEntity>> getAuthorizedPages(String userId) async => _pages;

  @override
  Future<String> getPageContent(String pageId) async => 'Content';

  @override
  Future<NotionPageEntity> createStudyNote({
    required String userId,
    required String parentPageId,
    required String title,
    required String contentMarkdown,
    required String subjectName,
    required int durationSeconds,
  }) async {
    final note = NotionPageEntity(
      id: 'note_created',
      title: title,
      lastEditedTime: DateTime.now(),
      excerpt: contentMarkdown,
    );
    _pages.add(note);
    return note;
  }

  @override
  Future<void> linkPageToSubject({
    required String userId,
    required String pageId,
    required String subjectId,
  }) async {}
}

void main() {
  group('NotionController Unit Tests', () {
    late MockNotionRepository repo;
    late NotionController controller;

    setUp(() {
      repo = MockNotionRepository();
      controller = NotionController(repo, 'user_test');
    });

    test('Connecting workspace updates connection flag and loads pages', () async {
      await controller.connect('token_123', 'University Workspace');

      expect(controller.state.isConnected, isTrue);
      expect(controller.state.pages.length, equals(1));
      expect(controller.state.pages.first.title, contains('Operating Systems'));
    });

    test('Exporting session note appends to page list', () async {
      await controller.connect('token_123', 'University Workspace');

      await controller.exportSessionNote(
        parentPageId: 'mock_page_1',
        title: 'Study Session Nov 24: Threads & Deadlocks',
        markdown: 'Discussed Peterson algorithm and Banker algorithm.',
        subjectName: 'Computer Science',
        durationSeconds: 3600,
      );

      expect(controller.state.pages.length, equals(2));
      expect(controller.state.pages.first.title, contains('Threads & Deadlocks'));
    });
  });
}
