class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category; // 'time', 'streak', 'focus', 'social'
  final int requirementValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double currentProgress; // 0.0 to 1.0

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirementValue,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0.0,
  });
}
