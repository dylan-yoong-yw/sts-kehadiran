import 'package:flutter/material.dart';

import '../../widgets/app_navigation_bar.dart';
import 'admin_home_tab.dart';
import 'admin_profile_screen.dart';
import 'admin_submissions_screen.dart';
import 'classes_screen.dart';

/// The admin interface: home dashboard plus placeholder tabs, sharing one
/// navigation bar (FR-01, FR-05).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, this.adminName = 'Admin', this.now});

  /// How the signed-in admin is addressed, e.g. "Mr. Adam".
  final String adminName;

  /// Clock for the date; overridable in tests.
  final DateTime Function()? now;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const submissionsTab = 1;

  int _selectedTab = 0;

  void _selectTab(int index) => setState(() => _selectedTab = index);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: _selectedTab,
        children: [
          AdminHomeTab(
            adminName: widget.adminName,
            now: (widget.now ?? DateTime.now)(),
            onOpenSubmissions: () => _selectTab(submissionsTab),
          ),
          const AdminSubmissionsScreen(),
          const ClassesScreen(),
          const AdminProfileScreen(),
        ],
      ),
    ),
    bottomNavigationBar: AppNavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: _selectTab,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        // "Attendance Submission" cannot fit one line in a quarter of a
        // phone's width, so the bar shows a short label; the tooltip and the
        // screen title give the full name.
        NavigationDestination(
          icon: Icon(Icons.checklist_rtl_rounded),
          label: 'Submissions',
          tooltip: 'Attendance Submission',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_rounded),
          label: 'Classes',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );
}
