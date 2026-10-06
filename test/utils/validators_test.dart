// [AI-GENERATED] Issue #1, Agent, 2025-02-23
import 'package:flutter_test/flutter_test.dart';
import 'package:le_compagnon_investissement/utils/validators.dart';

void main() {
  group('Validators', () {
    test('Email format validation - valid', () {
      expect(Validators.isValidEmail('test@example.com'), isTrue);
      expect(Validators.isValidEmail('user.name@domain.co'), isTrue);
    });

    test('Email format validation - invalid', () {
      expect(Validators.isValidEmail('testexample.com'), isFalse);
      expect(Validators.isValidEmail('test@.com'), isFalse);
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail(''), isFalse);
    });

    test('Password validation - sufficient length', () {
      expect(Validators.isValidPassword('123456'), isTrue);
    });

    test('Password validation - too short', () {
      expect(Validators.isValidPassword('12345'), isFalse);
      expect(Validators.isValidPassword(''), isFalse);
    });
    
    test('Passwords match', () {
      expect(Validators.passwordsMatch('password123', 'password123'), isTrue);
    });

    test('Passwords do not match', () {
      expect(Validators.passwordsMatch('password123', 'Password123'), isFalse);
      expect(Validators.passwordsMatch('password123', 'different'), isFalse);
    });

    test('Field is not empty', () {
      expect(Validators.isNotEmpty('some text'), isTrue);
      expect(Validators.isNotEmpty('   text   '), isTrue);
    });

    test('Field is empty', () {
      expect(Validators.isNotEmpty(''), isFalse);
      expect(Validators.isNotEmpty('   '), isFalse);
    });
  });
}
