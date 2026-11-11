import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/teacher_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

/// Shows the login screen when signed out and the dashboard when signed in.
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
        return _SignedInHome(
          // A new key per account so a different teacher never sees the
          // previous teacher's name.
          key: ValueKey(user.uid),
          user: user,
          profileService: widget.profileService,
        );
      },
    ),
  );
}

/// Loads the signed-in teacher's profile and shows it on the dashboard.
class _SignedInHome extends StatefulWidget {
  const _SignedInHome({
    super.key,
    required this.user,
    required this.profileService,
  });

  final AppUser user;
  final ProfileService profileService;

  @override
  State<_SignedInHome> createState() => _SignedInHomeState();
}

class _SignedInHomeState extends State<_SignedInHome> {
  late final Stream<TeacherProfile?> _profile = widget.profileService
      .watchProfile(widget.user.uid);

  @override
  Widget build(BuildContext context) => StreamBuilder<TeacherProfile?>(
    stream: _profile,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        debugPrint('Could not load teacher profile: ${snapshot.error}');
      }
      // Until the profile loads, or if it is missing or unreadable, fall back
      // to the account's display name, then to "Teacher".
      final authName = widget.user.displayName?.trim();
      final name =
          snapshot.data?.displayName ??
          (authName == null || authName.isEmpty ? 'Teacher' : authName);
      return MainScreen(teacherName: name);
    },
  );
}
