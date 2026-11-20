import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Supabase implementation of AuthRepository with automatic profile sync.
class AuthRepositoryImpl implements AuthRepository {
  final supa.SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return await _fetchProfile(user.id, user.email ?? '');
    });
  }

  Future<UserEntity?> _fetchProfile(String userId, String email) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Fallback profile if record hasn't landed via trigger yet
        return UserEntity(
          id: userId,
          email: email,
          displayName: 'New Flyer',
          username: 'flyer_${userId.substring(0, 6)}',
          createdAt: DateTime.now(),
        );
      }

      return UserModel.fromJson(response, email: email);
    } catch (e) {
      throw DatabaseException('Failed to retrieve user profile', details: e);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return await _fetchProfile(user.id, user.email ?? '');
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': displayName},
      );
      final user = res.user;
      if (user == null) throw const AuthException('Signup failed: user returned null');
      return (await _fetchProfile(user.id, email))!;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) throw const AuthException('Invalid login credentials');
      return (await _fetchProfile(user.id, email))!;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        supa.OAuthProvider.google,
        redirectTo: 'letsflytgr://auth-callback',
      );
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AuthException('Google sign-in completed but user session not found');
      }
      return (await _fetchProfile(user.id, user.email ?? ''))!;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signInWithPhoneOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyPhoneOtp({
    required String phoneNumber,
    required String token,
  }) async {
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: supa.OtpType.sms,
      );
      final user = res.user;
      if (user == null) throw const AuthException('OTP verification failed');
      return (await _fetchProfile(user.id, user.email ?? ''))!;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String displayName,
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('No active user logged in');

    try {
      final updates = {
        'display_name': displayName,
        'username': username,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      await _supabase
          .from(SupabaseConstants.tableProfiles)
          .update(updates)
          .eq('id', user.id);

      return (await _fetchProfile(user.id, user.email ?? ''))!;
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
