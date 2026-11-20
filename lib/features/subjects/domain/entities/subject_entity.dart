/// Pure domain entity representing a user's study subject.
class SubjectEntity {
  final String id;
  final String userId;
  final String name;
  final String colorHex;
  final String iconName;
  final String category;
  final int targetMinutesDaily;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubjectEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.colorHex = '#4F46E5',
    this.iconName = 'book',
    this.category = 'General',
    this.targetMinutesDaily = 60,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  SubjectEntity copyWith({
    String? name,
    String? colorHex,
    String? iconName,
    String? category,
    int? targetMinutesDaily,
    int? sortOrder,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return SubjectEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      targetMinutesDaily: targetMinutesDaily ?? this.targetMinutesDaily,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
