/// Domain entity for an authorized Notion database page or workspace document.
class NotionPageEntity {
  final String id;
  final String title;
  final String? icon;
  final String? coverUrl;
  final String? url;
  final DateTime lastEditedTime;
  final String? linkedSubjectId;
  final String? excerpt;

  const NotionPageEntity({
    required this.id,
    required this.title,
    this.icon,
    this.coverUrl,
    this.url,
    required this.lastEditedTime,
    this.linkedSubjectId,
    this.excerpt,
  });

  NotionPageEntity copyWith({
    String? title,
    String? icon,
    String? coverUrl,
    String? url,
    DateTime? lastEditedTime,
    String? linkedSubjectId,
    String? excerpt,
  }) {
    return NotionPageEntity(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      coverUrl: coverUrl ?? this.coverUrl,
      url: url ?? this.url,
      lastEditedTime: lastEditedTime ?? this.lastEditedTime,
      linkedSubjectId: linkedSubjectId ?? this.linkedSubjectId,
      excerpt: excerpt ?? this.excerpt,
    );
  }
}
