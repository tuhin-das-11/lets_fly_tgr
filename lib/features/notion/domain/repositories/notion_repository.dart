import 'entities/notion_page_entity.dart';

/// Contract for official Notion Workspace integration via official Notion REST API.
abstract class NotionRepository {
  /// Check if user has an active Notion connection.
  Future<bool> isConnected(String userId);

  /// Connect Notion workspace using access token / OAuth exchange.
  Future<void> connectNotion({
    required String userId,
    required String accessToken,
    required String workspaceName,
    required String workspaceId,
  });

  /// Disconnect Notion integration and remove credentials.
  Future<void> disconnectNotion(String userId);

  /// Search and fetch authorized Notion pages and databases.
  Future<List<NotionPageEntity>> getAuthorizedPages(String userId);

  /// Fetch page block content (notes markdown/text).
  Future<String> getPageContent(String pageId);

  /// Create a study summary note inside an authorized Notion page.
  Future<NotionPageEntity> createStudyNote({
    required String userId,
    required String parentPageId,
    required String title,
    required String contentMarkdown,
    required String subjectName,
    required int durationSeconds,
  });

  /// Link an authorized Notion page to a specific subject.
  Future<void> linkPageToSubject({
    required String userId,
    required String pageId,
    required String subjectId,
  });
}
