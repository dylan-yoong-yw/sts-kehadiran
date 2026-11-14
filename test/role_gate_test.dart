import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/models/app_user.dart';
import 'package:sts_kehadiran/models/user_profile.dart';
import 'package:sts_kehadiran/screens/admin/admin_shell.dart';
import 'package:sts_kehadiran/screens/auth/account_status_screens.dart';
import 'package:sts_kehadiran/screens/auth/login_screen.dart';
import 'package:sts_kehadiran/screens/teacher/teacher_shell.dart';

import 'fakes/fake_auth_service.dart';
import 'fakes/fake_profile_service.dart';
import 'helpers/test_app.dart';

/// The fake auth service signs [testEmail] in with this uid.
const _uid = 'teacher-1';

const _signedIn = AppUser(uid: _uid, email: testEmail);

void _expectTeacher() {
  expect(find.byType(TeacherShell), findsOneWidget);
  expect(find.byType(AdminShell), findsNothing);
  expect(find.byType(AccountNotSetUpScreen), findsNothing);
}

void _expectAdmin() {
  expect(find.byType(AdminShell), findsOneWidget);
  expect(find.byType(TeacherShell), findsNothing);
  expect(find.byType(AccountNotSetUpScreen), findsNothing);
}

void _expectNotSetUp() {
  expect(find.byType(AccountNotSetUpScreen), findsOneWidget);
  expect(find.text('Account not set up'), findsOneWidget);
  expect(find.text('Signed in as $testEmail'), findsOneWidget);
  expect(find.byType(TeacherShell), findsNothing);
  expect(find.byType(AdminShell), findsNothing);
}

/// Lets a profile update travel through the stream and be shown.
Future<void> _deliver(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('A teacher sees the teacher interface', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(profiles: {_uid: teacherLeong}),
    );
    _expectTeacher();
    expect(find.text('Hello, Mr. Leong'), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
  });

  testWidgets('An admin sees the admin interface', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(profiles: {_uid: adminAdam}),
    );
    _expectAdmin();
    expect(find.text('Hello, Mr. Adam'), findsOneWidget);
    expect(find.text('Today’s agenda'), findsOneWidget);
    expect(find.text('Take Attendance'), findsNothing);
  });

  testWidgets('An admin without a name is greeted as "Admin"', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(
        profiles: {_uid: const UserProfile(role: UserRole.admin)},
      ),
    );
    expect(find.text('Hello, Admin'), findsOneWidget);
  });

  testWidgets('A missing profile shows "Account not set up"', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(profiles: {_uid: null}),
    );
    _expectNotSetUp();
  });

  testWidgets('A profile without a known role shows "Account not set up"', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(
        profiles: {_uid: const UserProfile(title: 'Mr.', name: 'Adam')},
      ),
    );
    _expectNotSetUp();
  });

  testWidgets('"Account not set up" signs out straight away', (tester) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(profiles: {_uid: null}),
    );
    final signOut = find.byKey(const Key('sign-out'));
    expect(tester.getSize(signOut).height, greaterThanOrEqualTo(48));
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Shows a loading screen until the profile arrives', (
    tester,
  ) async {
    final profiles = FakeProfileService(profiles: {_uid: adminAdam})
      ..gate = Completer<void>();
    await pumpApp(tester, FakeAuthService(user: _signedIn), profiles: profiles);
    expect(find.byType(AccountLoadingScreen), findsOneWidget);
    expect(find.text('Loading your account…'), findsOneWidget);
    expect(find.byType(TeacherShell), findsNothing);
    expect(find.byType(AdminShell), findsNothing);

    profiles.gate!.complete();
    await _deliver(tester);
    _expectAdmin();
  });

  testWidgets('An unreadable profile shows an error that can be retried', (
    tester,
  ) async {
    final profiles = FakeProfileService(
      profiles: {_uid: teacherLeong},
      error: Exception('unavailable'),
    );
    await pumpApp(tester, FakeAuthService(user: _signedIn), profiles: profiles);
    expect(find.byType(AccountErrorScreen), findsOneWidget);
    expect(find.text('Couldn’t load your account'), findsOneWidget);
    expect(find.byType(TeacherShell), findsNothing);
    expect(tester.takeException(), isNull);

    profiles.error = null;
    final retry = find.text('Try again');
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Try again')).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(retry);
    await _deliver(tester);
    expect(profiles.reads, 2);
    _expectTeacher();
  });

  testWidgets('A role change in Firestore takes effect immediately', (
    tester,
  ) async {
    final profiles = FakeProfileService(profiles: {_uid: teacherLeong});
    await pumpApp(tester, FakeAuthService(user: _signedIn), profiles: profiles);
    _expectTeacher();

    profiles.update(_uid, adminAdam);
    await _deliver(tester);
    _expectAdmin();

    profiles.update(_uid, const UserProfile(name: 'Adam', role: null));
    await _deliver(tester);
    _expectNotSetUp();

    profiles.update(_uid, teacherLeong);
    await _deliver(tester);
    _expectTeacher();
    // Only one read: the change arrived through the open stream.
    expect(profiles.reads, 1);
  });

  testWidgets('Signing in through the login screen routes an admin', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(),
      profiles: FakeProfileService(profiles: {_uid: adminAdam}),
    );
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login-email')), testEmail);
    await tester.enterText(
      find.byKey(const Key('login-password')),
      testPassword,
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    _expectAdmin();
    expect(find.text('Hello, Mr. Adam'), findsOneWidget);
  });

  testWidgets('Signing out of the admin interface returns to login', (
    tester,
  ) async {
    await pumpApp(
      tester,
      FakeAuthService(user: _signedIn),
      profiles: FakeProfileService(profiles: {_uid: adminAdam}),
    );
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AdminShell), findsNothing);
  });

  for (final size in phoneSizes) {
    testWidgets('Account screens have no overflow at $size, text x2', (
      tester,
    ) async {
      setScreen(tester, size, textScale: 2);
      final profiles = FakeProfileService(profiles: {_uid: null});
      await pumpApp(
        tester,
        FakeAuthService(user: _signedIn),
        profiles: profiles,
      );
      _expectNotSetUp();
      expect(tester.takeException(), isNull);
    });
  }
}
