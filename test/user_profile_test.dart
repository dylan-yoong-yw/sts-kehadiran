import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('combines title and name', () {
      expect(
        const UserProfile(title: 'Mr.', name: 'Dylan').displayName,
        'Mr. Dylan',
      );
      expect(const UserProfile(name: 'Dylan').displayName, 'Dylan');
      expect(const UserProfile(title: 'Mr.').displayName, isNull);
    });

    test('reads Firestore data and trims spaces', () {
      final profile = UserProfile.fromMap({
        'title': ' Mr. ',
        'name': ' Dylan ',
        'role': 'teacher',
      });
      expect(profile.displayName, 'Mr. Dylan');
      expect(profile.role, UserRole.teacher);
    });

    test('treats a blank title as no title', () {
      expect(
        UserProfile.fromMap({'title': '  ', 'name': 'Dylan'}).displayName,
        'Dylan',
      );
    });

    test('treats a blank or non-text name as no name', () {
      expect(UserProfile.fromMap({}).displayName, isNull);
      expect(UserProfile.fromMap({'name': '  '}).displayName, isNull);
      expect(UserProfile.fromMap({'name': 42}).displayName, isNull);
    });
  });

  group('UserRole.parse', () {
    test('reads teacher and admin, ignoring case and spaces', () {
      expect(UserRole.parse('teacher'), UserRole.teacher);
      expect(UserRole.parse('admin'), UserRole.admin);
      expect(UserRole.parse(' Admin '), UserRole.admin);
    });

    test('is null for a missing or unknown role', () {
      for (final value in [null, '', 'principal', 42, true]) {
        expect(UserRole.parse(value), isNull, reason: '$value');
      }
    });
  });
}
