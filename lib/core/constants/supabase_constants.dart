/// Supabase table names, RPC names, and channel topics.
abstract class SupabaseConstants {
  // Database Tables
  static const String tableProfiles = 'profiles';
  static const String tableUserSettings = 'user_settings';
  static const String tableDevices = 'devices';
  static const String tableSubjects = 'subjects';
  static const String tableStudySessions = 'study_sessions';
  static const String tableActiveSessions = 'active_sessions';
  static const String tableGroups = 'groups';
  static const String tableGroupMembers = 'group_members';
  static const String tableGroupInvitations = 'group_invitations';
  static const String tableFriendships = 'friendships';
  static const String tableAchievements = 'achievements';
  static const String tableUserAchievements = 'user_achievements';
  static const String tableStudyGoals = 'study_goals';
  static const String tableNotifications = 'notifications';
  static const String tableAppBlockingRules = 'app_blocking_rules';
  static const String tableFocusSchedules = 'focus_schedules';
  static const String tablePomodoroSettings = 'pomodoro_settings';
  static const String tableConnectedIntegrations = 'connected_integrations';
  static const String tableAiUsage = 'ai_usage';
  static const String tableLeaderboardCache = 'leaderboard_cache';

  // Storage Buckets
  static const String bucketAvatars = 'avatars';
  static const String bucketGroupAvatars = 'group-avatars';

  // Realtime Channels
  static const String channelActiveSessions = 'public:active_sessions';
  static const String channelLiveRooms = 'room:live_study';
}
