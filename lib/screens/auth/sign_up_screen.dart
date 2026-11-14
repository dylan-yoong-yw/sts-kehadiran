import 'package:flutter/material.dart';

import '../../widgets/feature_placeholder.dart';

/// Placeholder until teacher registration is built. Opened from the
/// "Sign up" link on the login screen.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SignUpScreen());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: const SafeArea(child: FeaturePlaceholder(title: 'Sign up')),
  );
}
