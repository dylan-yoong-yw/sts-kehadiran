import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/screens/login_screen.dart';
import 'package:sts_kehadiran/screens/main_screen.dart';
import 'package:sts_kehadiran/services/auth_service.dart';

import 'fakes/fake_auth_service.dart';
import 'helpers/test_app.dart';

final _email = find.byKey(const Key('login-email'));
final _password = find.byKey(const Key('login-password'));
final _submit = find.byKey(const Key('login-submit'));

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = testEmail,
  String password = testPassword,
}) async {
  await tester.enterText(_email, email);
  await tester.enterText(_password, password);
  await tester.ensureVisible(_submit);
  await tester.tap(_submit);
}

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

  testWidgets('Signed-out users see the welcome message and sign-in form', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService());
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
    expect(find.text('STS Kehadiran'), findsOneWidget);
    expect(find.text('Welcome back, Teacher!'), findsOneWidget);
    expect(find.textContaining('Sign in to take attendance'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Signed-in users go straight to the dashboard', (tester) async {
    await pumpApp(tester, FakeAuthService.signedIn());
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  for (final entry in {
    5: 'Good morning!',
    13: 'Good afternoon!',
    20: 'Good evening!',
  }.entries) {
    testWidgets('Greeting at ${entry.key}:00 is "${entry.value}"', (
      tester,
    ) async {
      final service = FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(
          home: AuthScope(
            service: service,
            child: LoginScreen(now: () => DateTime(2026, 11, 11, entry.key)),
          ),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('Empty fields show validation errors without signing in', (
    tester,
  ) async {
    final service = FakeAuthService();
    await pumpApp(tester, service);
    await tester.tap(_submit);
    await tester.pump();
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);
    expect(service.signInAttempts, 0);

    await tester.enterText(_email, 'not-an-email');
    await tester.tap(_submit);
    await tester.pump();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(service.signInAttempts, 0);
  });

  testWidgets('Correct details sign in and open the dashboard', (tester) async {
    await pumpApp(tester, FakeAuthService());
    await _fillAndSubmit(tester, email: '  $testEmail  ');
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Hello, Mr. Leong'), findsOneWidget);
  });

  testWidgets('Wrong password shows an error and stays on login', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService());
    await _fillAndSubmit(tester, password: 'wrong');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Incorrect email or password.'), findsOneWidget);

    // The error clears on the next attempt.
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('Signing in shows progress and blocks double taps', (
    tester,
  ) async {
    final service = FakeAuthService()..signInGate = Completer<void>();
    await pumpApp(tester, service);
    await _fillAndSubmit(tester);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
    await tester.tap(_submit, warnIfMissed: false);
    await tester.pump();
    expect(service.signInAttempts, 1);

    service.signInGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('Password visibility can be toggled', (tester) async {
    await pumpApp(tester, FakeAuthService());
    EditableText field() => tester.widget<EditableText>(
      find.descendant(of: _password, matching: find.byType(EditableText)),
    );
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(field().obscureText, isTrue);
  });

  group('Forgot password', () {
    testWidgets('asks for an email first', (tester) async {
      final service = FakeAuthService();
      await pumpApp(tester, service);
      await tester.tap(find.text('Forgot password?'));
      await tester.pump();
      expect(find.textContaining('Enter your email above'), findsOneWidget);
      expect(service.resetRequests, isEmpty);
    });

    testWidgets('sends a reset link for the entered email', (tester) async {
      final service = FakeAuthService();
      await pumpApp(tester, service);
      await tester.enterText(_email, testEmail);
      await tester.tap(find.text('Forgot password?'));
      await tester.pump();
      expect(service.resetRequests, [testEmail]);
      expect(
        find.text(
          'If an account exists for $testEmail, a reset link has been '
          'sent.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the error when the request fails', (tester) async {
      final service = FakeAuthService()
        ..resetError = const AuthException('No internet connection.');
      await pumpApp(tester, service);
      await tester.enterText(_email, testEmail);
      await tester.tap(find.text('Forgot password?'));
      await tester.pump();
      expect(find.text('No internet connection.'), findsOneWidget);
    });
  });

  testWidgets('Signing out from Profile returns to the login screen', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService.signedIn());
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('Login fits without overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpApp(tester, FakeAuthService());
      // Show an error too, the tallest state of the form.
      await _fillAndSubmit(tester, password: 'wrong');
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('login-scroll')),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('For registered teachers only'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Login handles large text on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: testApp(FakeAuthService()),
      ),
    );
    expect(find.text('Welcome back, Teacher!'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('login-scroll')),
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
