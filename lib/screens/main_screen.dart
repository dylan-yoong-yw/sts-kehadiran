import 'package:flutter/material.dart';

import '../core/theme.dart';
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x180D483A),
              blurRadius: 14,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                _NavigationItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: _selectedTab == 0,
                  onTap: () => _selectTab(0),
                ),
                _NavigationItem(
                  icon: Icons.checklist_rounded,
                  label: 'Attendance',
                  selected: _selectedTab == 1,
                  onTap: () => _selectTab(1),
                ),
                _NavigationItem(
                  icon: Icons.groups_rounded,
                  label: 'Students',
                  selected: _selectedTab == 2,
                  onTap: () => _selectTab(2),
                ),
                _NavigationItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Timetable',
                  selected: _selectedTab == 3,
                  onTap: () => _selectTab(3),
                ),
                _NavigationItem(
                  icon: Icons.account_circle_rounded,
                  label: 'Profile',
                  selected: _selectedTab == 4,
                  onTap: () => _selectTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      selected: selected,
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: selected
                      ? const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x6600DA9B),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    icon,
                    size: 25,
                    color: selected
                        ? const Color(0xFF008D67)
                        : const Color(0xFF9BA6B5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.darkGreen
                        : const Color(0xFF647082),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
