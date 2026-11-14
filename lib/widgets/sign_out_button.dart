import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';

/// Outlined "Sign Out" button that signs out through the [AuthScope].
///
/// With [confirm], the user is asked first (used on Profile, where a tap may
/// be accidental). Builds nothing when there is no [AuthScope] above it.
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key, this.confirm = true});

  final bool confirm;

  Future<void> _signOut(BuildContext context, AuthService auth) async {
    if (confirm) {
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.maybeOf(context);
    if (auth == null) return const SizedBox.shrink();
    return OutlinedButton.icon(
      key: const Key('sign-out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkGreen,
        side: const BorderSide(color: AppColors.green, width: 1.5),
        minimumSize: const Size(160, 48),
      ),
      onPressed: () => _signOut(context, auth),
      icon: const Icon(Icons.logout_rounded),
      label: const Text(
        'Sign Out',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
