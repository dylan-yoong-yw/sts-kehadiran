import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/models/app_user.dart';
import 'package:sts_kehadiran/models/user_profile.dart';
import 'package:sts_kehadiran/screens/auth/login_screen.dart';

import 'fakes/fake_auth_service.dart';
import 'fakes/fake_profile_service.dart';
import 'helpers/test_app.dart';

const _dylan = AppUser(uid: 'dylan-uid', email: 'dylanyoong767@gmail.com');

void _expectName(String name) {
  expect(find.text('Hello, $name'), findsOneWidget);
}

void main() {
  testWidgets('Dashboard greets the signed-in teacher by profile name', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(
        profiles: {
          'dylan-uid': const UserProfile(
            title: 'Mr.',
            name: 'Dylan',
            role: UserRole.teacher,
          ),
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
        profiles: {
          'dylan-uid': const UserProfile(name: 'Dylan', role: UserRole.teacher),
        },
      ),
    );
    _expectName('Dylan');
  });

  // A missing or unreadable profile no longer falls back to the teacher
  // dashboard: without a role the app cannot tell teachers from admins.
  // Those cases are covered in role_gate_test.dart.

  testWidgets('A teacher profile without a name falls back to "Teacher"', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _dylan),
      profiles: FakeProfileService(
        defaultProfile: const UserProfile(role: UserRole.teacher),
      ),
    );
    _expectName('Teacher');
  });

  testWidgets('A teacher profile without a name uses the account name', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(
        user: const AppUser(uid: 'u1', displayName: 'Cikgu Aminah'),
      ),
      profiles: FakeProfileService(
        defaultProfile: const UserProfile(role: UserRole.teacher),
      ),
    );
    _expectName('Cikgu Aminah');
  });

  testWidgets('Editing the profile updates the dashboard', (tester) async {
    final profiles = FakeProfileService(
      profiles: {
        'dylan-uid': const UserProfile(
          title: 'Mr.',
          name: 'Dylan',
          role: UserRole.teacher,
        ),
      },
    );
    await pumpApp(tester, FakeAuthService(user: _dylan), profiles: profiles);
    _expectName('Mr. Dylan');

    profiles.update(
      'dylan-uid',
      const UserProfile(
        title: 'Dr.',
        name: 'Dylan Yoong',
        role: UserRole.teacher,
      ),
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
        'dylan-uid': const UserProfile(
          title: 'Mr.',
          name: 'Dylan',
          role: UserRole.teacher,
        ),
        'teacher-1': const UserProfile(
          title: 'Ms.',
          name: 'Tan',
          role: UserRole.teacher,
        ),
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
