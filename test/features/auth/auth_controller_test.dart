import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/features/auth/domain/entities/user_entity.dart';
import 'package:lets_fly_tgr/features/auth/domain/repositories/auth_repository.dart';
import 'package:lets_fly_tgr/features/auth/presentation/controllers/auth_controller.dart';

class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _currentUser = UserEntity(
      id: 'mock-user-id',
      email: email,
      displayName: 'Mock User',
      username: 'mock_user',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _currentUser = UserEntity(
      id: 'mock-user-id',
      email: email,
      displayName: displayName,
      username: 'mock_user',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> signInWithGoogle() async => signInWithEmail(email: 'google@test.com', password: '');

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signInWithPhoneOtp(String phoneNumber) async {}

  @override
  Future<UserEntity> verifyPhoneOtp({required String phoneNumber, required String token}) async {
    return signInWithEmail(email: 'phone@test.com', password: '');
  }

  @override
  Future<UserEntity> updateProfile({
    required String displayName,
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    _currentUser = _currentUser?.copyWith(displayName: displayName, username: username, bio: bio);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

void main() {
  group('AuthController Unit Tests', () {
    late MockAuthRepository mockRepo;
    late AuthController authController;

    setUp(() {
      mockRepo = MockAuthRepository();
      authController = AuthController(mockRepo);
    });

    test('Initial state resolves and allows sign in', () async {
      await authController.signInWithEmail('test@letsfly.com', 'Secret123');
      expect(authController.state.value, isNotNull);
      expect(authController.state.value?.email, equals('test@letsfly.com'));
      expect(authController.state.value?.displayName, equals('Mock User'));
    });

    test('Sign out clears the user state', () async {
      await authController.signInWithEmail('test@letsfly.com', 'Secret123');
      expect(authController.state.value, isNotNull);

      await authController.signOut();
      expect(authController.state.value, isNull);
    });
  });
}
