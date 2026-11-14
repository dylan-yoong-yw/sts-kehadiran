import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/feature_placeholder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, AuthService auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00C58B),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.maybeOf(context);
    return FeaturePlaceholder(
      title: 'Profile',
      action: auth == null
          ? null
          : OutlinedButton.icon(
              key: const Key('sign-out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF064C3D),
                side: const BorderSide(color: Color(0xFF00C58B), width: 1.5),
                minimumSize: const Size(160, 48),
              ),
              onPressed: () => _confirmSignOut(context, auth),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}
