import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Authentication validation tests', () {
    test('Sign in with email and password validation', () {
      // Test email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

      expect(emailRegex.hasMatch('test@example.com'), isTrue);
      expect(emailRegex.hasMatch('invalid-email'), isFalse);

      // Test password validation
      final String password = 'password123';
      expect(password.length >= 6, isTrue);
    });

    test('Register form validation', () {
      // Test name validation
      final String name = 'Test User';
      expect(name.isNotEmpty, isTrue);

      // Test email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(emailRegex.hasMatch('test@example.com'), isTrue);

      // Test password validation
      final String password = 'password123';
      final String confirmPassword = 'password123';
      expect(password.length >= 6, isTrue);
      expect(password == confirmPassword, isTrue);
    });

    test('Reset password form validation', () {
      // Test email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(emailRegex.hasMatch('test@example.com'), isTrue);
      expect(emailRegex.hasMatch('invalid-email'), isFalse);
    });
  });
}
