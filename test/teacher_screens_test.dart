import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_auth_service.dart';
import 'helpers/test_app.dart';

import 'package:sts_kehadiran/screens/attendance_screen.dart';
import 'package:sts_kehadiran/screens/main_screen.dart';
import 'package:sts_kehadiran/screens/profile_screen.dart';
import 'package:sts_kehadiran/screens/students_screen.dart';
import 'package:sts_kehadiran/screens/timetable_screen.dart';

const _tabs = ['Home', 'Attendance', 'Students', 'Timetable', 'Profile'];

void _expectNavigation(WidgetTester tester, String selectedTab) {
  // A single Scaffold owns the navigation on every tab.
  expect(find.byType(Scaffold), findsOneWidget);
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  expect(scaffold.bottomNavigationBar, isNotNull);
  final navigation = find.byWidget(scaffold.bottomNavigationBar!);
  for (final tab in _tabs) {
    expect(
      find.descendant(of: navigation, matching: find.text(tab)).hitTestable(),
      findsOneWidget,
    );
    final item = find.byTooltip(tab);
    expect(item, findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find.ancestor(of: item, matching: find.byType(Semantics)).first,
    );
    expect(semantics.properties.selected, tab == selectedTab);
    final icon = tester.widget<Icon>(
      find.descendant(of: item, matching: find.byType(Icon)),
    );
    expect(
      icon.color,
      tab == selectedTab ? const Color(0xFF008D67) : const Color(0xFF9BA6B5),
    );
  }
}

class _NavigationObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

void main() {
  for (final destination in {
    'Attendance': AttendanceScreen,
    'Students': StudentsScreen,
    'Timetable': TimetableScreen,
    'Profile': ProfileScreen,
  }.entries) {
    testWidgets('${destination.key} shows its placeholder and returns Home', (
      tester,
    ) async {
      await pumpApp(tester, FakeAuthService.signedIn());
      _expectNavigation(tester, 'Home');
      await tester.tap(find.byTooltip(destination.key));
      await tester.pumpAndSettle();
      expect(find.byType(destination.value), findsOneWidget);
      final screen = find.byType(destination.value);
      expect(
        find.descendant(of: screen, matching: find.text(destination.key)),
        findsOneWidget,
      );
      expect(
        find.text('${destination.key} is under development.').hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Hello, Mr. Leong'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      _expectNavigation(tester, destination.key);

      await tester.tap(find.byTooltip('Home'));
      await tester.pumpAndSettle();
      expect(find.text('STS Kehadiran'), findsOneWidget);
      expect(find.text('Hello, Mr. Leong'), findsOneWidget);
      expect(find.text('Today’s Attendance'), findsOneWidget);
      expect(find.text('Today’s Schedule'), findsOneWidget);
      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.textContaining('is under development.'), findsNothing);
      _expectNavigation(tester, 'Home');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Switching and reselecting tabs preserves Home without routes', (
    tester,
  ) async {
    // Force scrolling so this verifies a real offset survives tab switches.
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final observer = _NavigationObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const MainScreen(teacherName: 'Mr. Leong'),
      ),
    );
    final initialPushes = observer.pushes;
    await tester.drag(
      find.byKey(const Key('dashboard-scroll')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    final homeScroll = tester.state<ScrollableState>(find.byType(Scrollable));
    final scrollOffset = homeScroll.position.pixels;
    expect(scrollOffset, greaterThan(0));

    for (final tab in [
      'Profile',
      'Attendance',
      'Attendance',
      'Timetable',
      'Students',
      'Home',
      'Home',
    ]) {
      await tester.tap(find.byTooltip(tab));
      await tester.pumpAndSettle();
      _expectNavigation(tester, tab);
      expect(observer.pushes, initialPushes);
      expect(
        Navigator.of(tester.element(find.byType(MainScreen))).canPop(),
        isFalse,
      );
      if (tab != 'Home') {
        expect(find.text('$tab is under development.'), findsOneWidget);
        expect(find.textContaining('is under development.'), findsOneWidget);
      }
    }

    expect(find.text('Hello, Mr. Leong'), findsOneWidget);
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)),
      same(homeScroll),
    );
    expect(homeScroll.position.pixels, scrollOffset);
    expect(tester.takeException(), isNull);
  });

  for (final action in ['View Reports', 'Manage Classes']) {
    testWidgets('$action stays a placeholder', (tester) async {
      await pumpApp(tester, FakeAuthService.signedIn());
      await tester.scrollUntilVisible(
        find.text(action),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.text('$action: Not implemented yet.'), findsOneWidget);
    });
  }
}
