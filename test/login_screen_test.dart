import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/core/theme.dart';
import 'package:sts_kehadiran/screens/login_screen.dart';
import 'package:sts_kehadiran/screens/main_screen.dart';
import 'package:sts_kehadiran/screens/sign_up_screen.dart';
import 'package:sts_kehadiran/services/auth_service.dart';

import 'fakes/fake_auth_service.dart';
import 'helpers/test_app.dart';

final _email = find.byKey(const Key('login-email'));
final _password = find.byKey(const Key('login-password'));
final _submit = find.byKey(const Key('login-submit'));
final _forgot = find.byKey(const Key('login-forgot-password'));
final _signUp = find.byKey(const Key('login-sign-up'));
final _footer = find.byKey(const Key('login-footer'));

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = testEmail,
  String password = testPassword,
}) async {
  await tester.enterText(_email, email);
  await tester.enterText(_password, password);
  await tester.ensureVisible(_submit);
  await tester.pumpAndSettle();
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

  testWidgets('Signed-out users see the login form', (tester) async {
    await pumpApp(tester, FakeAuthService());
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
    expect(find.text('STS KEHADIRAN'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsNothing);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Don’t have an account yet?'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('Title uses the theme display style', (tester) async {
    await pumpApp(tester, FakeAuthService());
    final title = tester.widget<Text>(find.byKey(const Key('login-title')));
    final display = AppTheme.light().textTheme.displaySmall!;
    expect(title.style?.fontSize, display.fontSize);
    expect(title.style?.fontWeight, FontWeight.w800);
    expect(title.textAlign, TextAlign.center);
  });

  testWidgets('Background is the theme login gradient', (tester) async {
    await pumpApp(tester, FakeAuthService());
    final box = tester.widget<DecoratedBox>(
      find.byKey(const Key('login-background')),
    );
    expect((box.decoration as BoxDecoration).gradient, AppGradients.login);
  });

  for (final size in phoneSizes) {
    testWidgets('Fields and button line up as equal rows at $size', (
      tester,
    ) async {
      setScreen(tester, size);
      await pumpApp(tester, FakeAuthService());
      Rect field(Finder f) => tester.getRect(
        find.descendant(of: f, matching: find.byType(InputDecorator)),
      );
      final email = field(_email);
      final password = field(_password);
      final button = tester.getRect(_submit);
      for (final rect in [password, button]) {
        expect(rect.left, moreOrLessEquals(email.left));
        expect(rect.right, moreOrLessEquals(email.right));
      }
      for (final rect in [email, password, button]) {
        expect(rect.height, moreOrLessEquals(AppSizes.controlHeight));
      }
      // Forgot password sits under the button, against its right edge.
      final forgot = tester.getRect(_forgot);
      expect(forgot.top, greaterThan(button.bottom));
      expect(forgot.right, moreOrLessEquals(button.right));
    });
  }

  testWidgets('Links meet the 48 dp tap target and 16 sp text size', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService());
    for (final link in [_forgot, _signUp]) {
      final size = tester.getSize(link);
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
      final style = DefaultTextStyle.of(
        tester.element(find.descendant(of: link, matching: find.byType(Text))),
      ).style;
      expect(style.fontSize, greaterThanOrEqualTo(16));
    }
  });

  testWidgets('Signed-in users go straight to the dashboard', (tester) async {
    await pumpApp(tester, FakeAuthService.signedIn());
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

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
    expect(find.text('Login'), findsNothing);
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

  testWidgets('Sign up opens the registration placeholder and back returns', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService());
    await tester.ensureVisible(_signUp);
    await tester.tap(_signUp);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Sign up is under development.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
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

  for (final size in phoneSizes) {
    for (final scale in textScales) {
      testWidgets('Login has no overflow at $size, text x$scale', (
        tester,
      ) async {
        setScreen(tester, size, textScale: scale);
        await pumpApp(tester, FakeAuthService());
        // Show an error too, the tallest state of the form.
        await _fillAndSubmit(tester, password: 'wrong');
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('login-error')), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('login-scroll')),
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
        expect(_footer.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Open keyboard does not overflow and the form scrolls', (
    tester,
  ) async {
    setScreen(tester, const Size(360, 640));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await pumpApp(tester, FakeAuthService());
    await tester.showKeyboard(_password);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Everything above the keyboard is still reachable by scrolling.
    await tester.drag(
      find.byKey(const Key('login-scroll')),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(_footer).bottom, lessThanOrEqualTo(640 - 300));
    expect(_signUp.hitTestable(), findsOneWidget);
  });

  testWidgets('On a tall phone the form is centred and the footer pinned', (
    tester,
  ) async {
    setScreen(tester, const Size(412, 915));
    await pumpApp(tester, FakeAuthService());
    final scroll = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byKey(const Key('login-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scroll.position.maxScrollExtent, 0);

    final titleTop = tester.getTopLeft(find.byKey(const Key('login-title'))).dy;
    final formBottom = tester.getBottomLeft(_forgot).dy;
    // Equal space above and below the form: vertically centred above the
    // footer (the 16 dp top spacer and 24 dp form padding cancel out).
    expect(
      titleTop - AppSpacing.section,
      moreOrLessEquals(tester.getTopLeft(_footer).dy - formBottom),
    );
    // Footer sits at the bottom of the screen, above its 16 dp margin.
    expect(tester.getBottomLeft(_footer).dy, moreOrLessEquals(915 - 16));
  });
}
