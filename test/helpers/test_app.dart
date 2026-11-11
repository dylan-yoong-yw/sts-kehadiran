import 'package:flutter/widgets.dart';
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

/// Phone sizes the layout must support, in logical pixels.
const phoneSizes = [Size(360, 640), Size(390, 844), Size(412, 915)];

/// System font sizes the layout must support.
const textScales = [1.0, 1.3, 2.0];

/// Simulates a phone screen of [size] with the given system font scale.
void setScreen(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
