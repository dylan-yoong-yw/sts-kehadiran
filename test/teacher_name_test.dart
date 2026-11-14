import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/models/app_user.dart';
import 'package:sts_kehadiran/models/teacher_profile.dart';
import 'package:sts_kehadiran/screens/auth/login_screen.dart';

import 'fakes/fake_auth_service.dart';
import 'fakes/fake_profile_service.dart';
import 'helpers/test_app.dart';

const _dylan = AppUser(uid: 'dylan-uid', email: 'dylanyoong767@gmail.com');

void _expectName(String name) {
  expect(find.text('Hello, $name'), findsOneWidget);
}

void main() {
  group('TeacherProfile', () {
    test('combines title and name', () {
      expect(
        const TeacherProfile(title: 'Mr.', name: 'Dylan').displayName,
        'Mr. Dylan',
      );
      expect(const TeacherProfile(name: 'Dylan').displayName, 'Dylan');
    });

    test('reads Firestore data and trims spaces', () {
      final profile = TeacherProfile.fromMap({
        'title': ' Mr. ',
        'name': ' Dylan ',
      });
      expect(profile?.displayName, 'Mr. Dylan');
    });

    test('treats a blank title as no title', () {
      expect(
        TeacherProfile.fromMap({'title': '  ', 'name': 'Dylan'})?.displayName,
        'Dylan',
      );
    });

    test('is null without a usable name', () {
      expect(TeacherProfile.fromMap(null), isNull);
      expect(TeacherProfile.fromMap({}), isNull);
      expect(TeacherProfile.fromMap({'title': 'Mr.', 'name': '  '}), isNull);
      expect(TeacherProfile.fromMap({'name': 42}), isNull);
    });
  });

  testWidgets('Dashboard greets the signed-in teacher by profile name', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(
        profiles: {
          'dylan-uid': const TeacherProfile(title: 'Mr.', name: 'Dylan'),
        },
      ),
    );
    _expectName('Mr. Dylan');
    expect(find.textContaining('Leong'), findsNothing);
  });

  testWidgets('A profile without a title shows just the name', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(
        profiles: {'dylan-uid': const TeacherProfile(name: 'Dylan')},
      ),
    );
    _expectName('Dylan');
  });

  testWidgets('A missing profile falls back to "Teacher"', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(defaultProfile: null),
    );
    _expectName('Teacher');
  });

  testWidgets('A missing profile uses the account display name if set', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(
        user: const AppUser(uid: 'u1', displayName: 'Cikgu Aminah'),
      ),
      profiles: FakeProfileService(defaultProfile: null),
    );
    _expectName('Cikgu Aminah');
  });

  testWidgets('An unreadable profile still shows the dashboard', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(error: Exception('permission-denied')),
    );
    _expectName('Teacher');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editing the profile updates the dashboard', (tester) async {
    final profiles = FakeProfileService(
      profiles: {
        'dylan-uid': const TeacherProfile(title: 'Mr.', name: 'Dylan'),
      },
    );
    await pumpApp(tester, FakeAuthService(user: _dylan), profiles: profiles);
    _expectName('Mr. Dylan');

    profiles.update(
      'dylan-uid',
      const TeacherProfile(title: 'Dr.', name: 'Dylan Yoong'),
    );
    // One frame delivers the update through the stream, the next shows it.
    await tester.pump();
    await tester.pump();
    _expectName('Dr. Dylan Yoong');
  });

  testWidgets('Switching accounts shows the new teacher’s name', (
    tester,
  ) async {
    final auth = FakeAuthService(user: _dylan);
    final profiles = FakeProfileService(
      profiles: {
        'dylan-uid': const TeacherProfile(title: 'Mr.', name: 'Dylan'),
        'teacher-1': const TeacherProfile(title: 'Ms.', name: 'Tan'),
      },
    );
    await pumpApp(tester, auth, profiles: profiles);
    _expectName('Mr. Dylan');

    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-email')), testEmail);
    await tester.enterText(
      find.byKey(const Key('login-password')),
      testPassword,
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    _expectName('Ms. Tan');
    expect(find.textContaining('Dylan'), findsNothing);
  });
}
