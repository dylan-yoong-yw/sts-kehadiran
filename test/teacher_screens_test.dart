import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/main.dart';

void main() {
  for (final destination in [
    'Attendance',
    'Students',
    'Timetable',
    'Profile',
  ]) {
    testWidgets('$destination announces an unavailable screen', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text(destination));
      await tester.pumpAndSettle();
      expect(find.text('$destination: Not implemented yet.'), findsOneWidget);
      expect(find.text('Hello, Mr. Leong'), findsOneWidget);
    });
  }

  for (final action in ['View Reports', 'Manage Classes']) {
    testWidgets('$action stays a placeholder', (tester) async {
      await tester.pumpWidget(const MyApp());
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
