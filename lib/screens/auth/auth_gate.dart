import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import 'login_screen.dart';
import 'role_gate.dart';

/// Shows the login screen when signed out, and the [RoleGate] when signed in.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.profileService,
  });

  final AuthService authService;
  final ProfileService profileService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<AppUser?> _userChanges;

  @override
  void initState() {
    super.initState();
    _userChanges = widget.authService.authStateChanges();
  }

  @override
  void didUpdateWidget(AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authService != widget.authService) {
      _userChanges = widget.authService.authStateChanges();
    }
  }

  @override
  Widget build(BuildContext context) => AuthScope(
    service: widget.authService,
    child: StreamBuilder<AppUser?>(
      // Start from the restored session so a signed-in teacher never sees
      // the login screen flash on app start.
      initialData: widget.authService.currentUser,
      stream: _userChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return RoleGate(
          // A new key per account so a different user never sees the
          // previous user's name or interface.
          key: ValueKey(user.uid),
          user: user,
          profileService: widget.profileService,
        );
      },
    ),
  );
}
