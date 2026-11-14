import 'package:flutter/material.dart';

import '../../widgets/feature_placeholder.dart';
import '../../widgets/sign_out_button.dart';

/// The admin's profile. Placeholder apart from signing out.
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const FeaturePlaceholder(title: 'Profile', action: SignOutButton());
}
