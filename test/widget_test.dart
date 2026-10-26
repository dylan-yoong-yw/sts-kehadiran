import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Real font metrics keep the no-scroll layout assertions representative of
    // the app. Ahem, Flutter's default test font, wraps text much more widely.
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fixtures/fonts/Roboto-Regular.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
    await font.load();
  });
  for (final size in [
    const Size(320, 640),
    const Size(360, 740),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('All dashboard details fit without scrolling at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      await tester.pumpWidget(const MyApp());
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scroll.position.maxScrollExtent, 0);
      expect(
        find.text('Have a great day of teaching, Mr. Leong!').hitTestable(),
        findsOneWidget,
      );
      expect(find.text('View Reports').hitTestable(), findsOneWidget);
      expect(find.text('Manage Classes').hitTestable(), findsOneWidget);
      expect(find.text('Message Parents'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Main screen shows sample data and the current date', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('STS Kehadiran'), findsOneWidget);
    expect(find.text('Hello, Mr. Leong'), findsOneWidget);
    final today = DateTime.now();
    expect(find.textContaining('${today.year}'), findsOneWidget);
    expect(find.text('Today’s Attendance'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Add. Maths'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final className in ['3 Bestari', '4 Cemerlang']) {
    testWidgets('Selecting $className only shows a placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
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

  for (final width in [320.0, 390.0, 1280.0]) {
    testWidgets('Dashboard scrolls without overflow at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      final navBefore = tester.getCenter(find.text('Home'));
      await tester.drag(
        find.byKey(const Key('dashboard-scroll')),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Have a great day of teaching, Mr. Leong!').hitTestable(),
        findsOneWidget,
      );
      expect(tester.getCenter(find.text('Home')), navBefore);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Large text fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const MyApp(),
      ),
    );
    await tester.drag(
      find.byKey(const Key('dashboard-scroll')),
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
