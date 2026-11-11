import 'package:flutter/material.dart';

import '../widgets/app_navigation_bar.dart';
import 'attendance_screen.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'students_screen.dart';
import 'timetable_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.teacherName = 'Teacher', this.now});

  /// How the signed-in teacher is addressed, e.g. "Mr. Dylan".
  final String teacherName;

  /// Clock for the date and next lesson; overridable in tests.
  final DateTime Function()? now;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;

  void _selectTab(int index) => setState(() => _selectedTab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            HomeTab(
              teacherName: widget.teacherName,
              now: (widget.now ?? DateTime.now)(),
            ),
            const AttendanceScreen(),
            const StudentsScreen(),
            const TimetableScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      // Material 3 navigation bar; colours, indicator and the always-visible
      // labels come from AppTheme.
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
