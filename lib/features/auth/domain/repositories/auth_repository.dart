import 'entities/user_entity.dart';

/// Contract for authentication operations and profile retrieval.
abstract class AuthRepository {
  /// Stream of user auth state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Retrieves the current authenticated user or null.
  Future<UserEntity?> getCurrentUser();

  /// Email & Password Sign Up.
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Email & Password Sign In.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// OAuth Sign In via Google.
  Future<UserEntity> signInWithGoogle();

  /// Send password recovery email.
  Future<void> sendPasswordResetEmail(String email);

  /// Send phone OTP.
  Future<void> signInWithPhoneOtp(String phoneNumber);

  /// Verify phone OTP.
  Future<UserEntity> verifyPhoneOtp({
    required String phoneNumber,
    required String token,
  });

  /// Update user profile details.
  Future<UserEntity> updateProfile({
    required String displayName,
    required String username,
    String? bio,
    String? avatarUrl,
  });

  /// Sign out current session.
  Future<void> signOut();
}
