import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../state/user_profile_controller.dart';
import '../admin/admin_shell.dart';
import '../teacher/teacher_shell.dart';
import 'account_status_screens.dart';

/// Opens the interface for the signed-in user's role (FR-01):
/// teacher → [TeacherShell], admin → [AdminShell], and
/// [AccountNotSetUpScreen] when `users/{uid}` is missing or has no known
/// role.
///
/// The profile is watched as a stream, so a role changed in the Firebase
/// console takes effect straight away.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key, required this.user, required this.profileService});

  final AppUser user;
  final ProfileService profileService;

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<UserProfileController>(
        create: (_) =>
            UserProfileController(service: profileService, uid: user.uid),
        child: _RoleSwitch(user: user),
      );
}

class _RoleSwitch extends StatelessWidget {
  const _RoleSwitch({required this.user});

  final AppUser user;

  /// The profile's name, else the account's display name, else [fallback].
  String _nameFor(UserProfile profile, String fallback) {
    final authName = user.displayName?.trim();
    return profile.displayName ??
        (authName == null || authName.isEmpty ? fallback : authName);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserProfileController>();
    final profile = controller.profile;
    return switch (controller.status) {
      ProfileStatus.loading => const AccountLoadingScreen(),
      ProfileStatus.error => AccountErrorScreen(onRetry: controller.retry),
      ProfileStatus.missing => const AccountNotSetUpScreen(),
      ProfileStatus.loaded => switch (profile?.role) {
        UserRole.teacher => TeacherShell(
          teacherName: _nameFor(profile!, 'Teacher'),
        ),
        UserRole.admin => AdminShell(adminName: _nameFor(profile!, 'Admin')),
        null => const AccountNotSetUpScreen(),
      },
    };
  }
}
