import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sts_kehadiran/core/date_format.dart';
import 'package:sts_kehadiran/core/theme.dart';
import 'package:sts_kehadiran/models/admin_agenda.dart';
import 'package:sts_kehadiran/screens/admin/admin_shell.dart';
import 'package:sts_kehadiran/services/admin_agenda_service.dart';
import 'package:sts_kehadiran/services/auth_service.dart';
import 'package:sts_kehadiran/widgets/dashboard_widgets.dart';
import 'package:sts_kehadiran/widgets/placeholder_page.dart';

import 'fakes/fake_admin_agenda_service.dart';
import 'fakes/fake_auth_service.dart';
import 'helpers/test_app.dart';

/// Wednesday, as in the design.
final _wednesday = DateTime(2026, 10, 21, 8);

const _agendaItems = [
  '3 registers awaiting processing',
  '2 classes not yet submitted today',
];
const _quickActions = [
  'View Attendance Submission',
  'Contact Parents',
  'Manage Classes',
];
const _tabs = ['Home', 'Submissions', 'Classes', 'Profile'];

/// The admin interface on its own, with the sample agenda unless [agenda]
/// is given.
Widget _adminApp({
  AdminAgendaService agenda = const MockAdminAgendaService(),
  AuthService? auth,
  DateTime Function()? now,
}) => Provider<AdminAgendaService>.value(
  value: agenda,
  child: AuthScope(
    service: auth ?? FakeAuthService.signedIn(),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: AdminShell(adminName: 'Mr. Adam', now: now ?? () => _wednesday),
    ),
  ),
);

Future<void> _pumpAdmin(
  WidgetTester tester, {
  AdminAgendaService agenda = const MockAdminAgendaService(),
  AuthService? auth,
  DateTime Function()? now,
}) async {
  await tester.pumpWidget(_adminApp(agenda: agenda, auth: auth, now: now));
  await tester.pump();
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const Key('admin-home-scroll')),
    const Offset(0, -4000),
  );
  await tester.pumpAndSettle();
}

NavigationBar _navigationBar(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Real font metrics, as in widget_test.dart.
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fixtures/fonts/Roboto-Regular.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
    await font.load();
  });

  group('AgendaItem', () {
    test('uses singular and plural wording', () {
      expect(
        const AgendaItem(
          kind: AgendaItemKind.awaitingProcessing,
          count: 1,
        ).text,
        '1 register awaiting processing',
      );
      expect(
        const AgendaItem(kind: AgendaItemKind.notSubmitted, count: 1).text,
        '1 class not yet submitted today',
      );
      expect(
        MockAdminAgendaService.sample.items.map((item) => item.text),
        _agendaItems,
      );
    });

    test('leaves out items with nothing to do', () {
      const agenda = AdminAgenda([
        AgendaItem(kind: AgendaItemKind.awaitingProcessing, count: 0),
        AgendaItem(kind: AgendaItemKind.notSubmitted, count: 4),
      ]);
      expect(agenda.pending.map((item) => item.kind), [
        AgendaItemKind.notSubmitted,
      ]);
    });
  });

  testWidgets('Home shows the title, greeting, date and agenda', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    expect(find.text('STS Kehadiran'), findsOneWidget);
    expect(find.text('Hello, Mr. Adam'), findsOneWidget);
    expect(find.text('Wednesday, 21 October 2026'), findsOneWidget);
    expect(find.text('Today’s agenda'), findsOneWidget);
    for (final item in _agendaItems) {
      expect(find.text(item), findsOneWidget);
      // Body text is at least 16 sp.
      final style = tester.widget<Text>(find.text(item)).style!;
      expect(style.fontSize, greaterThanOrEqualTo(16));
    }
    expect(find.text('Go to Attendance Submission'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    for (final action in _quickActions) {
      expect(find.text(action), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('The date comes from the device clock by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      Provider<AdminAgendaService>.value(
        value: const MockAdminAgendaService(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AdminShell(adminName: 'Mr. Adam'),
        ),
      ),
    );
    expect(find.text(DateFormats.long(DateTime.now())), findsOneWidget);
  });

  group('Today’s agenda', () {
    testWidgets('shows a spinner while loading', (tester) async {
      await _pumpAdmin(tester, agenda: FakeAdminAgendaService());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(_agendaItems.first), findsNothing);
      // The button works before the agenda has loaded.
      expect(find.text('Go to Attendance Submission'), findsOneWidget);
    });

    testWidgets('shows an error with a working retry', (tester) async {
      final agenda = FakeAdminAgendaService();
      await _pumpAdmin(tester, agenda: agenda);
      agenda.fail();
      await tester.pump();
      expect(find.text('Couldn’t load today’s agenda.'), findsOneWidget);
      final retry = find.widgetWithText(TextButton, 'Try again');
      expect(tester.getSize(retry).height, greaterThanOrEqualTo(48));

      await tester.tap(retry);
      await tester.pump();
      expect(agenda.requests, 2);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      agenda.emit(MockAdminAgendaService.sample);
      await tester.pump();
      expect(find.text(_agendaItems.first), findsOneWidget);
      expect(find.text('Couldn’t load today’s agenda.'), findsNothing);
    });

    testWidgets('says when nothing needs attention', (tester) async {
      final agenda = FakeAdminAgendaService();
      await _pumpAdmin(tester, agenda: agenda);
      agenda.emit(const AdminAgenda([]));
      await tester.pump();
      expect(
        find.text('Nothing needs your attention right now.'),
        findsOneWidget,
      );
    });

    testWidgets('updates when the counts change', (tester) async {
      final agenda = FakeAdminAgendaService();
      await _pumpAdmin(tester, agenda: agenda);
      agenda.emit(MockAdminAgendaService.sample);
      await tester.pump();
      agenda.emit(
        const AdminAgenda([
          AgendaItem(kind: AgendaItemKind.awaitingProcessing, count: 1),
          AgendaItem(kind: AgendaItemKind.notSubmitted, count: 0),
        ]),
      );
      await tester.pump();
      expect(find.text('1 register awaiting processing'), findsOneWidget);
      expect(find.textContaining('not yet submitted'), findsNothing);
    });
  });

  testWidgets('"Go to Attendance Submission" opens that tab', (tester) async {
    await _pumpAdmin(tester);
    final button = find.byKey(const Key('go-to-submissions'));
    expect(tester.getSize(button).height, greaterThanOrEqualTo(56));
    expect(tester.getSize(button).width, greaterThan(300));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(_navigationBar(tester).selectedIndex, 1);
    expect(
      find.text('Attendance Submission is under development.').hitTestable(),
      findsOneWidget,
    );
  });

  for (final action in _quickActions) {
    testWidgets('$action opens a placeholder page and returns', (tester) async {
      await _pumpAdmin(tester);
      final tile = find.ancestor(
        of: find.text(action),
        matching: find.byType(QuickActionTile),
      );
      await tester.ensureVisible(tile);
      expect(tester.getSize(tile).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(tile).width, greaterThanOrEqualTo(48));
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderPage), findsOneWidget);
      expect(find.text('$action is under development.'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderPage), findsNothing);
      expect(find.text('Hello, Mr. Adam'), findsOneWidget);
    });
  }

  testWidgets('The navigation bar has four labelled destinations', (
    tester,
  ) async {
    await _pumpAdmin(tester);
    final bar = _navigationBar(tester);
    expect(bar.destinations, hasLength(4));
    for (final label in _tabs) {
      expect(find.text(label).hitTestable(), findsOneWidget);
    }
    for (final tooltip in [
      'Home',
      'Attendance Submission',
      'Classes',
      'Profile',
    ]) {
      final item = find.byTooltip(tooltip);
      expect(item, findsOneWidget);
      expect(tester.getSize(item).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(item).height, greaterThanOrEqualTo(48));
    }
  });

  for (final (i, title) in [
    (1, 'Attendance Submission'),
    (2, 'Classes'),
    (3, 'Profile'),
  ]) {
    testWidgets('The ${_tabs[i]} tab shows its placeholder and returns Home', (
      tester,
    ) async {
      await _pumpAdmin(tester);
      await tester.tap(find.text(_tabs[i]));
      await tester.pumpAndSettle();
      expect(_navigationBar(tester).selectedIndex, i);
      expect(find.text('$title is under development.'), findsOneWidget);
      expect(find.text('Hello, Mr. Adam').hitTestable(), findsNothing);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Mr. Adam').hitTestable(), findsOneWidget);
    });
  }

  testWidgets('Profile signs the admin out after confirming', (tester) async {
    final auth = FakeAuthService.signedIn();
    await _pumpAdmin(tester, auth: auth);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final signOut = find.byKey(const Key('sign-out'));
    expect(tester.getSize(signOut).height, greaterThanOrEqualTo(48));
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
    await tester.pumpAndSettle();
    expect(auth.currentUser, isNull);
  });

  for (final size in phoneSizes) {
    for (final scale in textScales) {
      testWidgets('Admin home has no overflow at $size, text x$scale', (
        tester,
      ) async {
        setScreen(tester, size, textScale: scale);
        await _pumpAdmin(tester);
        final navBefore = tester.getCenter(find.text('Home'));
        await _scrollToBottom(tester);
        for (final action in _quickActions) {
          expect(find.text(action).hitTestable(), findsOneWidget);
        }
        // The navigation bar stays put and its labels stay on one line.
        expect(tester.getCenter(find.text('Home')), navBefore);
        final lineHeight = tester.getSize(find.text('Home')).height;
        for (final label in _tabs) {
          expect(tester.getSize(find.text(label)).height, lineHeight);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('The grown card still fits when the agenda loads later', (
    tester,
  ) async {
    setScreen(tester, const Size(390, 844), textScale: 1.3);
    final agenda = FakeAdminAgendaService();
    await _pumpAdmin(tester, agenda: agenda);
    agenda.emit(MockAdminAgendaService.sample);
    await tester.pump();
    expect(find.text(_agendaItems.last), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in phoneSizes.skip(1)) {
    testWidgets('At $size the agenda card fills the spare height', (
      tester,
    ) async {
      setScreen(tester, size);
      await _pumpAdmin(tester);
      // Everything fits without scrolling…
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(const Key('admin-home-scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scroll.position.maxScrollExtent, 0);
      // …with no empty band: the card ends one section gap above Quick
      // Actions, and Quick Actions end one gap above the navigation bar.
      final card = find.ancestor(
        of: find.text('Today’s agenda'),
        matching: find.byType(DashboardCard),
      );
      final quickActionsTop = tester.getTopLeft(find.text('Quick Actions')).dy;
      expect(
        quickActionsTop - tester.getBottomLeft(card).dy,
        moreOrLessEquals(AppSpacing.section),
      );
      final lastTileBottom = tester
          .getBottomLeft(
            find.ancestor(
              of: find.text('Manage Classes'),
              matching: find.byType(QuickActionTile),
            ),
          )
          .dy;
      final navTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
      expect(navTop - lastTileBottom, moreOrLessEquals(AppSpacing.section));
      // The button sits at the bottom of the grown card.
      final buttonBottom = tester
          .getBottomLeft(find.byKey(const Key('go-to-submissions')))
          .dy;
      expect(
        tester.getBottomLeft(card).dy - buttonBottom,
        moreOrLessEquals(AppSpacing.card),
      );
    });
  }
}
