import '../domain/entities/user_entity.dart';

/// Data Transfer Object with serialization for profiles.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.username,
    super.avatarUrl,
    super.bio = '',
    super.totalStudySeconds = 0,
    super.currentStreakDays = 0,
    super.longestStreakDays = 0,
    super.studyVisibility = 'friends',
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String email = ''}) {
    return UserModel(
      id: json['id'] as String,
      email: email.isNotEmpty ? email : (json['email'] as String? ?? ''),
      displayName: json['display_name'] as String? ?? 'Flyer',
      username: json['username'] as String? ?? 'flyer_${json['id'].toString().substring(0, 6)}',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      totalStudySeconds: (json['total_study_seconds'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['current_streak_days'] as num?)?.toInt() ?? 0,
      longestStreakDays: (json['longest_streak_days'] as num?)?.toInt() ?? 0,
      studyVisibility: json['study_visibility'] as String? ?? 'friends',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'total_study_seconds': totalStudySeconds,
      'current_streak_days': currentStreakDays,
      'longest_streak_days': longestStreakDays,
      'study_visibility': studyVisibility,
    };
  }
}
