import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/core/validators.dart';

void main() {
  group('validateEmail', () {
    test('requires an email', () {
      expect(validateEmail(null), 'Please enter your email.');
      expect(validateEmail('   '), 'Please enter your email.');
    });

    test('rejects malformed addresses', () {
      for (final value in ['teacher', 'a@b', '@school.edu', 'a b@c.com']) {
        expect(
          validateEmail(value),
          'Please enter a valid email address.',
          reason: value,
        );
      }
    });

    test('accepts a valid address, ignoring surrounding spaces', () {
      expect(validateEmail('teacher@school.edu.my'), isNull);
      expect(validateEmail('  teacher@school.edu.my  '), isNull);
    });
  });

  group('validateTitle', () {
    test('accepts only the listed titles', () {
      for (final title in teacherTitles) {
        expect(validateTitle(title), isNull, reason: title);
      }
      expect(teacherTitles, ['Mr.', 'Ms.', 'Mdm.', 'Dr.']);
    });

    test('requires a title', () {
      for (final value in [null, '', 'Prof.', 'mr.']) {
        expect(
          validateTitle(value),
          'Please choose your title.',
          reason: '$value',
        );
      }
    });
  });

  group('validateName', () {
    test('requires a name', () {
      expect(validateName(null), 'Please enter your full name.');
      expect(validateName('  '), 'Please enter your full name.');
    });

    test('accepts a name up to the maximum length', () {
      expect(validateName('Dylan Yoong'), isNull);
      expect(validateName('a' * maxNameLength), isNull);
      expect(
        validateName('a' * (maxNameLength + 1)),
        'Name must be 100 characters or fewer.',
      );
    });
  });

  group('validateNewPassword', () {
    test('requires a password', () {
      expect(validateNewPassword(null), 'Please enter a password.');
      expect(validateNewPassword(''), 'Please enter a password.');
    });

    test('needs at least 8 characters', () {
      expect(
        validateNewPassword('1234567'),
        'Password must be at least 8 characters.',
      );
      expect(validateNewPassword('12345678'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('requires confirmation', () {
      expect(
        validateConfirmPassword('', 'secret123'),
        'Please confirm your password.',
      );
    });

    test('must match the password exactly', () {
      expect(
        validateConfirmPassword('secret124', 'secret123'),
        'Passwords do not match.',
      );
      expect(
        validateConfirmPassword('Secret123', 'secret123'),
        'Passwords do not match.',
      );
      expect(validateConfirmPassword('secret123', 'secret123'), isNull);
    });
  });
}
