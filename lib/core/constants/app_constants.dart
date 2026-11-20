/// App-wide constants, keys, and default values.
abstract class AppConstants {
  static const String appName = "LET'S FLY TGR";
  static const String appTagline = "Study Together. Focus Better. Fly Higher.";
  static const String appVersion = "1.0.0";

  // Shared Preferences / Secure Storage Keys
  static const String keyAuthToken = "auth_token";
  static const String keyRefreshToken = "refresh_token";
  static const String keyUserId = "user_id";
  static const String keyHasCompletedOnboarding = "has_completed_onboarding";
  static const String keyThemeMode = "user_theme_mode";

  // Study Timer Defaults
  static const int defaultDailyTargetMinutes = 240; // 4 Hours
  static const int heartbeatIntervalSeconds = 30;
  static const int maxActiveSessionStaleSeconds = 120;

  // Responsive Breakpoints (Logical Pixels)
  static const double breakpointCompact = 600.0;
  static const double breakpointMedium = 1024.0;
}
