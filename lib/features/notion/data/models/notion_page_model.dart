import '../domain/entities/notion_page_entity.dart';

/// DTO for Notion page serialization from Notion API responses.
class NotionPageModel extends NotionPageEntity {
  const NotionPageModel({
    required super.id,
    required super.title,
    super.icon,
    super.coverUrl,
    super.url,
    required super.lastEditedTime,
    super.linkedSubjectId,
    super.excerpt,
  });

  factory NotionPageModel.fromJson(Map<String, dynamic> json) {
    String title = 'Untitled Note';
    // Parse Notion properties format
    final properties = json['properties'] as Map<String, dynamic>?;
    if (properties != null) {
      for (final val in properties.values) {
        if (val is Map<String, dynamic> && val['type'] == 'title') {
          final titleList = val['title'] as List<dynamic>?;
          if (titleList != null && titleList.isNotEmpty) {
            title = titleList.first['plain_text'] as String? ?? 'Untitled Note';
          }
        }
      }
    }

    String? iconEmoji;
    final iconObj = json['icon'] as Map<String, dynamic>?;
    if (iconObj != null && iconObj['type'] == 'emoji') {
      iconEmoji = iconObj['emoji'] as String?;
    }

    return NotionPageModel(
      id: json['id'] as String,
      title: title,
      icon: iconEmoji,
      url: json['url'] as String?,
      lastEditedTime: json['last_edited_time'] != null
          ? DateTime.parse(json['last_edited_time'] as String)
          : DateTime.now(),
      excerpt: json['excerpt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'url': url,
      'last_edited_time': lastEditedTime.toIso8601String(),
      'linked_subject_id': linkedSubjectId,
      'excerpt': excerpt,
    };
  }
}
