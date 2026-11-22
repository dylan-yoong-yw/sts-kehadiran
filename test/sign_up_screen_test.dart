import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/screens/auth/login_screen.dart';
import 'package:sts_kehadiran/screens/auth/sign_up_screen.dart';
import 'package:sts_kehadiran/screens/teacher/teacher_shell.dart';
import 'package:sts_kehadiran/services/auth_service.dart';
import 'package:sts_kehadiran/services/sign_up_service.dart';

import 'fakes/fake_auth_service.dart';
import 'fakes/fake_profile_service.dart';
import 'helpers/test_app.dart';

final _title = find.byKey(const Key('sign-up-title'));
final _name = find.byKey(const Key('sign-up-name'));
final _email = find.byKey(const Key('sign-up-email'));
final _password = find.byKey(const Key('sign-up-password'));
final _confirm = find.byKey(const Key('sign-up-confirm-password'));
final _submit = find.byKey(const Key('sign-up-submit'));
final _progress = find.byKey(const Key('sign-up-progress'));
final _error = find.byKey(const Key('sign-up-error'));

const _newEmail = 'aina@school.edu.my';
const _newPassword = 'secret123';

/// Opens the app signed out, with no profile for a new uid, and taps
/// "Sign up" on the login screen.
Future<(FakeAuthService, FakeProfileService)> _openSignUp(
  WidgetTester tester,
) async {
  final auth = FakeAuthService();
  final profiles = FakeProfileService(defaultProfile: null);
  await pumpApp(tester, auth, profiles: profiles);
  final link = find.byKey(const Key('login-sign-up'));
  await tester.ensureVisible(link);
  await tester.tap(link);
  await tester.pumpAndSettle();
  expect(find.byType(SignUpScreen), findsOneWidget);
  return (auth, profiles);
}

Future<void> _chooseTitle(WidgetTester tester, String title) async {
  await tester.ensureVisible(_title);
  await tester.tap(_title);
  await tester.pumpAndSettle();
  await tester.tap(find.text(title).last);
  await tester.pumpAndSettle();
}

Future<void> _fill(
  WidgetTester tester, {
  String? title = 'Ms.',
  String name = 'Aina Binti Ali',
  String email = _newEmail,
  String password = _newPassword,
  String? confirm,
}) async {
  if (title != null) await _chooseTitle(tester, title);
  await tester.enterText(_name, name);
  await tester.enterText(_email, email);
  await tester.enterText(_password, password);
  await tester.enterText(_confirm, confirm ?? password);
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(_submit);
  await tester.pumpAndSettle();
  await tester.tap(_submit);
  await tester.pump();
}

EditableText _editable(WidgetTester tester, Finder field) =>
    tester.widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    );

void main() {
  setUpAll(() async {
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fixtures/fonts/Roboto-Regular.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
    await font.load();
  });

  testWidgets('Shows the sign-up form with the four titles', (tester) async {
    await _openSignUp(tester);
    expect(find.text('Create your account'), findsOneWidget);
    for (final label in [
      'Title',
      'Full name',
      'Email',
      'Password',
      'Confirm password',
      'Create account',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await tester.tap(_title);
    await tester.pumpAndSettle();
    for (final title in ['Mr.', 'Ms.', 'Mdm.', 'Dr.']) {
      expect(find.text(title), findsWidgets, reason: title);
    }
  });

  testWidgets('An empty form shows every required-field error', (tester) async {
    final (auth, _) = await _openSignUp(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('Please choose your title.'), findsOneWidget);
    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
    expect(auth.createdAccounts, isEmpty);
  });

  testWidgets('Rejects a bad email, a short password and a mismatch', (
    tester,
  ) async {
    final (auth, _) = await _openSignUp(tester);
    await _fill(
      tester,
      email: 'aina@school',
      password: 'short',
      confirm: 'different',
    );
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(auth.createdAccounts, isEmpty);
  });

  testWidgets('The toggle shows and hides both password fields', (
    tester,
  ) async {
    await _openSignUp(tester);
    expect(_editable(tester, _password).obscureText, isTrue);
    expect(_editable(tester, _confirm).obscureText, isTrue);

    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(_editable(tester, _password).obscureText, isFalse);
    expect(_editable(tester, _confirm).obscureText, isFalse);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(_editable(tester, _password).obscureText, isTrue);
    expect(_editable(tester, _confirm).obscureText, isTrue);
  });

  testWidgets('"Create account" is full width and as tall as the fields', (
    tester,
  ) async {
    await _openSignUp(tester);
    final button = tester.getRect(_submit);
    for (final field in [_title, _name, _email, _confirm]) {
      final rect = tester.getRect(field);
      expect(button.height, rect.height, reason: '$field');
      expect(button.width, rect.width, reason: '$field');
    }
  });

  testWidgets('Shows a spinner while creating the account, then opens the '
      'teacher interface with no classes', (tester) async {
    final (auth, profiles) = await _openSignUp(tester);
    auth.createAccountGate = Completer<void>();
    await _fill(tester);
    await _tapSubmit(tester);

    expect(_progress, findsOneWidget);
    expect(find.text('Create account'), findsNothing);
    expect(tester.widget<FilledButton>(_submit).onPressed, isNull);
    final emailField = tester.widget<TextField>(
      find.descendant(of: _email, matching: find.byType(TextField)),
    );
    expect(emailField.enabled, isFalse);
    // Tapping again while busy does not create a second account.
    await tester.tap(_submit, warnIfMissed: false);
    await tester.pump();

    auth.createAccountGate!.complete();
    await tester.pumpAndSettle();

    expect(auth.createdAccounts, [_newEmail]);
    expect(profiles.created[auth.newUid]?['role'], 'teacher');
    expect(profiles.created[auth.newUid]?['classIds'], isEmpty);
    expect(find.byType(SignUpScreen), findsNothing);
    expect(find.byType(TeacherShell), findsOneWidget);
    expect(find.text('Hello, Ms. Aina Binti Ali'), findsOneWidget);
    expect(find.text('No classes assigned yet'), findsOneWidget);
    expect(find.text('Take Attendance'), findsNothing);
  });

  testWidgets('A sign-up error is shown and the form can be retried', (
    tester,
  ) async {
    final (auth, _) = await _openSignUp(tester);
    auth.createAccountError = const AuthException(
      'An account with this email already exists. Try logging in instead.',
    );
    await _fill(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(_error, findsOneWidget);
    expect(
      find.text(
        'An account with this email already exists. Try logging in instead.',
      ),
      findsOneWidget,
    );
    expect(_progress, findsNothing);
    expect(tester.widget<FilledButton>(_submit).onPressed, isNotNull);
    expect(find.byType(SignUpScreen), findsOneWidget);

    auth.createAccountError = null;
    await _tapSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.byType(TeacherShell), findsOneWidget);
  });

  testWidgets('A failed profile write removes the account and says so', (
    tester,
  ) async {
    final (auth, profiles) = await _openSignUp(tester);
    profiles.createError = Exception('[cloud_firestore/permission-denied]');
    await _fill(tester);
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text(SignUpService.profileFailedMessage), findsOneWidget);
    expect(find.textContaining('cloud_firestore'), findsNothing);
    expect(auth.deletedUids, [auth.newUid]);
    expect(auth.currentUser, isNull);
    expect(find.byType(SignUpScreen), findsOneWidget);

    final link = find.byKey(const Key('sign-up-login'));
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TeacherShell), findsNothing);
  });

  testWidgets('"Log in" returns to the login screen', (tester) async {
    await _openSignUp(tester);
    final link = find.byKey(const Key('sign-up-login'));
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  for (final size in phoneSizes) {
    for (final scale in textScales) {
      testWidgets('No overflow at $size, text x$scale, with errors shown', (
        tester,
      ) async {
        setScreen(tester, size, textScale: scale);
        await _openSignUp(tester);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        expect(find.text('Please enter your full name.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
