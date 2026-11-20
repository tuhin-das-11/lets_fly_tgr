import 'package:flutter_test/flutter_test.dart';
import 'package:lets_fly_tgr/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns null on valid emails', () {
      expect(Validators.validateEmail('student@university.edu'), isNull);
      expect(Validators.validateEmail('john.doe@gmail.com'), isNull);
      expect(Validators.validateEmail('user_123@sub.domain.org'), isNull);
    });

    test('validateEmail returns error on invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('test@domain'), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('validatePassword enforces length and digits', () {
      expect(Validators.validatePassword('Password123'), isNull);
      expect(Validators.validatePassword('short1'), isNotNull); // < 8 chars
      expect(Validators.validatePassword('NoDigitsHere'), isNotNull); // No digit
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('validateUsername enforces length and allowed characters', () {
      expect(Validators.validateUsername('alex_walker'), isNull);
      expect(Validators.validateUsername('john123'), isNull);
      expect(Validators.validateUsername('ab'), isNotNull); // < 3 chars
      expect(Validators.validateUsername('user!invalid'), isNotNull); // special char
      expect(Validators.validateUsername(null), isNotNull);
    });

    test('validateDisplayName requires at least 2 characters', () {
      expect(Validators.validateDisplayName('Alex'), isNull);
      expect(Validators.validateDisplayName('A'), isNotNull);
      expect(Validators.validateDisplayName(''), isNotNull);
      expect(Validators.validateDisplayName(null), isNotNull);
    });
  });
}
