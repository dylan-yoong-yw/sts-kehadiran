import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/core/theme.dart';
import 'package:sts_kehadiran/screens/main_screen.dart';
import 'package:sts_kehadiran/widgets/dashboard_widgets.dart';
import 'package:sts_kehadiran/widgets/schedule_widgets.dart';

import 'fakes/fake_auth_service.dart';
import 'helpers/test_app.dart';

/// The dashboard on its own, at a fixed time so "next lesson" is stable.
Widget _dashboardAt(DateTime time) => MaterialApp(
  theme: AppTheme.light(),
  home: MainScreen(teacherName: 'Mr. Leong', now: () => time),
);

DateTime _at(int hour, [int minute = 0]) =>
    DateTime(2026, 11, 11, hour, minute);

Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const Key('dashboard-scroll')),
    const Offset(0, -4000),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Real font metrics keep the layout assertions representative of the
    // app. Ahem, Flutter's default test font, wraps text much more widely.
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fixtures/fonts/Roboto-Regular.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
    await font.load();
  });

  testWidgets('Main screen shows sample data and the current date', (
    tester,
  ) async {
    await pumpApp(tester, FakeAuthService.signedIn());
    expect(find.text('STS Kehadiran'), findsOneWidget);
    expect(find.text('Hello, Mr. Leong'), findsOneWidget);
    final today = DateTime.now();
    expect(find.textContaining('${today.year}'), findsOneWidget);
    expect(find.text('Today’s Attendance'), findsOneWidget);
    expect(find.text('Today’s Schedule'), findsOneWidget);
    for (final subject in ['Mathematics', 'Physics', 'Add. Maths']) {
      // Also shown in the Next lesson card when it is the next lesson.
      expect(find.text(subject), findsWidgets);
    }
    expect(find.textContaining('Have a great day'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today’s Attendance shows each class with its status (FR-03)', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardAt(_at(7)));
    expect(find.text('Submit to the admin by 7:30 AM'), findsOneWidget);
    for (final entry in {
      '3 Bestari': 'Not taken',
      '4 Cemerlang': 'Submitted',
    }.entries) {
      final row = find.ancestor(
        of: find.text(entry.key),
        matching: find.byType(ClassAttendanceRow),
      );
      expect(
        find.descendant(of: row, matching: find.text(entry.value)),
        findsOneWidget,
      );
    }
    final button = tester.getSize(
      find.widgetWithText(FilledButton, 'Take Attendance'),
    );
    expect(button.height, greaterThanOrEqualTo(56));
  });

  group('Next lesson card', () {
    Finder inCard(String text) => find.descendant(
      of: find.byKey(const Key('next-lesson')),
      matching: find.text(text),
    );

    testWidgets('shows the upcoming lesson and when it starts', (tester) async {
      await tester.pumpWidget(_dashboardAt(_at(9, 10)));
      expect(inCard('Next lesson'), findsOneWidget);
      expect(inCard('Physics'), findsOneWidget);
      expect(inCard('5 Bijak · 9:30–10:30'), findsOneWidget);
      expect(inCard('Starts in 20 min'), findsOneWidget);
      final highlighted = tester.widget<LessonRow>(
        find.ancestor(
          of: find.text('5 Bijak').last,
          matching: find.byType(LessonRow),
        ),
      );
      expect(highlighted.highlighted, isTrue);
    });

    testWidgets('shows hours when the lesson is later', (tester) async {
      await tester.pumpWidget(_dashboardAt(_at(6, 45)));
      expect(inCard('Mathematics'), findsOneWidget);
      expect(inCard('Starts in 1h 15 min'), findsOneWidget);
    });

    testWidgets('shows a lesson in progress as "Now"', (tester) async {
      await tester.pumpWidget(_dashboardAt(_at(8, 30)));
      expect(inCard('Now'), findsOneWidget);
      expect(inCard('Mathematics'), findsOneWidget);
      expect(inCard('In progress · ends 9:00'), findsOneWidget);
    });

    testWidgets('says when today’s lessons are over', (tester) async {
      await tester.pumpWidget(_dashboardAt(_at(13)));
      expect(inCard('No more lessons today'), findsOneWidget);
      expect(
        tester
            .widgetList<LessonRow>(find.byType(LessonRow))
            .where((row) => row.highlighted),
        isEmpty,
      );
    });
  });

  group('Quick Actions', () {
    const labels = ['View Reports', 'Contact Parents', 'Manage Classes'];

    List<Rect> tileRects(WidgetTester tester) => [
      for (final label in labels)
        tester.getRect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(QuickActionTile),
          ),
        ),
    ];

    testWidgets('are three large tiles side by side', (tester) async {
      setScreen(tester, const Size(390, 844));
      await tester.pumpWidget(_dashboardAt(_at(7)));
      await _scrollToBottom(tester);
      final rects = tileRects(tester);
      for (final rect in rects) {
        expect(rect.top, rects.first.top);
        expect(rect.height, greaterThanOrEqualTo(112));
        expect(rect.width, greaterThanOrEqualTo(48));
      }
      expect(find.text('Message Parents'), findsNothing);
    });

    testWidgets('stack as full-width rows with large text', (tester) async {
      setScreen(tester, const Size(360, 640), textScale: 2);
      await tester.pumpWidget(_dashboardAt(_at(7)));
      await _scrollToBottom(tester);
      final rects = tileRects(tester);
      for (final (i, rect) in rects.indexed) {
        expect(rect.width, rects.first.width);
        expect(rect.height, greaterThanOrEqualTo(48));
        if (i > 0) expect(rect.top, greaterThan(rects[i - 1].bottom));
      }
      expect(tester.takeException(), isNull);
    });
  });

  for (final className in ['3 Bestari', '4 Cemerlang']) {
    testWidgets('Selecting $className only shows a placeholder', (
      tester,
    ) async {
      await pumpApp(tester, FakeAuthService.signedIn());
      await tester.tap(find.text('Take Attendance'));
      await tester.pumpAndSettle();
      expect(find.text('Select a class'), findsOneWidget);
      await tester.tap(find.widgetWithText(SimpleDialogOption, className));
      await tester.pumpAndSettle();
      expect(find.text('Attendance placeholder: $className'), findsOneWidget);
      expect(
        find.text(
          'Not implemented yet. No attendance has been marked or saved.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  for (final size in phoneSizes) {
    for (final scale in textScales) {
      testWidgets('Dashboard has no overflow at $size, text x$scale', (
        tester,
      ) async {
        setScreen(tester, size, textScale: scale);
        await pumpApp(tester, FakeAuthService.signedIn());
        final navBefore = tester.getCenter(find.text('Home'));
        await _scrollToBottom(tester);
        expect(
          find.text('Sample classes and lessons').hitTestable(),
          findsOneWidget,
        );
        // The navigation bar stays put while the content scrolls.
        expect(tester.getCenter(find.text('Home')), navBefore);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('On a tall screen Quick Actions sit above the navigation bar', (
    tester,
  ) async {
    setScreen(tester, const Size(800, 1280));
    await pumpApp(tester, FakeAuthService.signedIn());
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scroll.position.maxScrollExtent, 0);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final navTop = tester
        .getTopLeft(find.byWidget(scaffold.bottomNavigationBar!))
        .dy;
    final captionBottom = tester
        .getBottomLeft(find.text('Sample classes and lessons'))
        .dy;
    // Only the section's own bottom margin separates them.
    expect(navTop - captionBottom, moreOrLessEquals(AppSpacing.section));
  });
}
