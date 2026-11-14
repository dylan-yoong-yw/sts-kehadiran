import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/sign_out_button.dart';

/// Shown while the signed-in user's profile is first read.
class AccountLoadingScreen extends StatelessWidget {
  const AccountLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AccountMessage(
    icon: CircularProgressIndicator(),
    title: 'Loading your account…',
    // A way out if the profile never arrives (e.g. offline on first use).
    actions: [SignOutButton(confirm: false)],
  );
}

/// Shown when `users/{uid}` is missing or has no known role (FR-01).
class AccountNotSetUpScreen extends StatelessWidget {
  const AccountNotSetUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = AuthScope.maybeOf(context)?.currentUser?.email;
    return _AccountMessage(
      icon: const Icon(
        Icons.manage_accounts_rounded,
        size: 56,
        color: AppColors.accent,
      ),
      title: 'Account not set up',
      message:
          'Your account has not been given access to STS Kehadiran yet. '
          'Please ask the school administrator to set it up. This screen '
          'updates on its own once they have.',
      detail: email == null ? null : 'Signed in as $email',
      actions: const [SignOutButton(confirm: false)],
    );
  }
}

/// Shown when the profile cannot be read, e.g. offline or permission denied.
class AccountErrorScreen extends StatelessWidget {
  const AccountErrorScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _AccountMessage(
    icon: const Icon(
      Icons.cloud_off_rounded,
      size: 56,
      color: AppColors.accent,
    ),
    title: 'Couldn’t load your account',
    message: 'Check your internet connection and try again.',
    actions: [
      FilledButton.icon(
        style: AppTheme.primaryButton,
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
      const SignOutButton(confirm: false),
    ],
  );
}

class _AccountMessage extends StatelessWidget {
  const _AccountMessage({
    required this.icon,
    required this.title,
    this.message,
    this.detail,
    required this.actions,
  });

  final Widget icon;
  final String title;
  final String? message;
  final String? detail;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: icon),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall?.copyWith(
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  if (message case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: text.bodyLarge,
                    ),
                  ],
                  if (detail case final detail?) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                  const SizedBox(height: 28),
                  for (final (i, action) in actions.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    action,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
