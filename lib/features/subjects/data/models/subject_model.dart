import '../domain/entities/subject_entity.dart';

/// DTO for Subject serialization with Supabase and Drift.
class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.userId,
    required super.name,
    super.colorHex = '#4F46E5',
    super.iconName = 'book',
    super.category = 'General',
    super.targetMinutesDaily = 60,
    super.sortOrder = 0,
    super.isArchived = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      colorHex: json['color'] as String? ?? '#4F46E5',
      iconName: json['icon'] as String? ?? 'book',
      category: json['category'] as String? ?? 'General',
      targetMinutesDaily: (json['target_minutes_daily'] as num?)?.toInt() ?? 60,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': colorHex,
      'icon': iconName,
      'category': category,
      'target_minutes_daily': targetMinutesDaily,
      'sort_order': sortOrder,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SubjectModel.fromEntity(SubjectEntity entity) {
    return SubjectModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      colorHex: entity.colorHex,
      iconName: entity.iconName,
      category: entity.category,
      targetMinutesDaily: entity.targetMinutesDaily,
      sortOrder: entity.sortOrder,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
