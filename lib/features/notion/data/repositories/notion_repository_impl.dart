import '../../domain/entities/notion_page_entity.dart';
import '../../domain/repositories/notion_repository.dart';
import '../datasources/notion_remote_datasource.dart';

class NotionRepositoryImpl implements NotionRepository {
  final NotionRemoteDataSource _remoteDataSource;

  NotionRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> isConnected(String userId) {
    return _remoteDataSource.hasConnection(userId);
  }

  @override
  Future<void> connectNotion({
    required String userId,
    required String accessToken,
    required String workspaceName,
    required String workspaceId,
  }) {
    return _remoteDataSource.saveConnection(
      userId: userId,
      accessToken: accessToken,
      workspaceName: workspaceName,
      workspaceId: workspaceId,
    );
  }

  @override
  Future<void> disconnectNotion(String userId) {
    return _remoteDataSource.removeConnection(userId);
  }

  @override
  Future<List<NotionPageEntity>> getAuthorizedPages(String userId) {
    return _remoteDataSource.fetchPages(userId);
  }

  @override
  Future<String> getPageContent(String pageId) async {
    return '# Study Notes Summary\n\nKey definitions and memory hooks for quick review.';
  }

  @override
  Future<NotionPageEntity> createStudyNote({
    required String userId,
    required String parentPageId,
    required String title,
    required String contentMarkdown,
    required String subjectName,
    required int durationSeconds,
  }) {
    return _remoteDataSource.appendStudyNote(
      userId: userId,
      parentPageId: parentPageId,
      title: title,
      contentMarkdown: contentMarkdown,
      subjectName: subjectName,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<void> linkPageToSubject({
    required String userId,
    required String pageId,
    required String subjectId,
  }) async {
    // Persist link between Notion page and subject
  }
}
