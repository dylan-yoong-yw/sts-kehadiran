import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/main.dart';
import 'package:sts_kehadiran/services/auth_service.dart';
import 'package:sts_kehadiran/services/profile_service.dart';

import '../fakes/fake_profile_service.dart';

/// The app wired to test fakes instead of Firebase.
MyApp testApp(AuthService auth, {ProfileService? profiles}) =>
    MyApp(authService: auth, profileService: profiles ?? FakeProfileService());

/// Pumps the app, then one more frame so the teacher profile has loaded.
Future<void> pumpApp(
  WidgetTester tester,
  AuthService auth, {
  ProfileService? profiles,
}) async {
  await tester.pumpWidget(testApp(auth, profiles: profiles));
  await tester.pump();
}
