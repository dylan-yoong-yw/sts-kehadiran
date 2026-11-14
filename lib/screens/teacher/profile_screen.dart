import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/feature_placeholder.dart';
import '../../widgets/sign_out_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => FeaturePlaceholder(
    title: 'Profile',
    action: AuthScope.maybeOf(context) == null ? null : const SignOutButton(),
  );
}
