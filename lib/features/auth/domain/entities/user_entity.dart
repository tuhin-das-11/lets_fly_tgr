/// Pure domain entity representing an authenticated user profile.
class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String bio;
  final int totalStudySeconds;
  final int currentStreakDays;
  final int longestStreakDays;
  final String studyVisibility;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.bio = '',
    this.totalStudySeconds = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.studyVisibility = 'friends',
    required this.createdAt,
  });

  UserEntity copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    int? totalStudySeconds,
    int? currentStreakDays,
    int? longestStreakDays,
    String? studyVisibility,
  }) {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalStudySeconds: totalStudySeconds ?? this.totalStudySeconds,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      studyVisibility: studyVisibility ?? this.studyVisibility,
      createdAt: createdAt,
    );
  }
}
