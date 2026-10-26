import 'package:flutter/material.dart';

import '../widgets/dashboard_widgets.dart';

const _green = Color(0xFF00C58B);
const _darkGreen = Color(0xFF064C3D);
const _background = Color(0xFFF2FFFA);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _notImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature: Not implemented yet.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> _selectClass(BuildContext context) async {
    final selectedClass = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select a class'),
        children: ['3 Bestari', '4 Cemerlang']
            .map(
              (name) => SimpleDialogOption(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                onPressed: () => Navigator.pop(context, name),
                child: Row(
                  children: [
                    const Icon(Icons.groups_outlined, color: _darkGreen),
                    const SizedBox(width: 12),
                    Text(name),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selectedClass == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attendance placeholder: $selectedClass'),
        content: const Text(
          'Not implemented yet. No attendance has been marked or saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = _days[now.weekday - 1];
    final dayMonth = '${now.day} ${_months[now.month - 1]}';
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, viewport) {
            // Tighten spacing on phones, without shrinking the whole screen or
            // disabling the user's text-size settings.
            final compact = viewport.maxHeight < 680;
            final shortPhone = viewport.maxHeight < 560;
            final gap = shortPhone
                ? 4.0
                : compact
                ? 8.0
                : 12.0;
            final cardPadding = EdgeInsets.all(
              shortPhone
                  ? 6
                  : compact
                  ? 10
                  : 14,
            );
            final cardTitle = TextStyle(
              fontSize: shortPhone ? 17 : 19,
              fontWeight: FontWeight.w800,
            );
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                // Keep every section reachable on short windows and with
                // enlarged text; navigation stays outside the scroll view.
                child: SingleChildScrollView(
                  key: const Key('dashboard-scroll'),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: shortPhone ? 6 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school, size: 25, color: _darkGreen),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'STS Kehadiran',
                              style: TextStyle(
                                color: _darkGreen,
                                fontSize: shortPhone ? 21 : 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello, Mr. Leong',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$weekday, $dayMonth ${now.year}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2ECE8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Color(0xFF6A7973),
                                  size: 19,
                                ),
                                Text(
                                  '${now.day} ${_months[now.month - 1].substring(0, 3)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF53625D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      DashboardCard(
                        color: const Color(0xFFCFF2E7),
                        padding: cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today’s Attendance', style: cardTitle),
                            const SizedBox(height: 8),
                            const Wrap(
                              spacing: 18,
                              runSpacing: 4,
                              children: [
                                Text(
                                  '• 3 Bestari',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '• 4 Cemerlang',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            SizedBox(height: shortPhone ? 6 : 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  elevation: 2,
                                  shadowColor: const Color(0x5500A67D),
                                ),
                                onPressed: () => _selectClass(context),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Take Attendance',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.north_east, size: 19),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      DashboardCard(
                        color: const Color(0xFFE3F2F9),
                        padding: cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today’s Schedule', style: cardTitle),
                            SizedBox(height: 8),
                            _LessonRow(
                              subject: 'Mathematics',
                              className: '4 Cemerlang',
                              time: '8:00–9:00',
                            ),
                            Divider(
                              color: Color(0xFFCADDE4),
                              height: shortPhone ? 6 : 10,
                            ),
                            _LessonRow(
                              subject: 'Physics',
                              className: '5 Bijak',
                              time: '9:30–10:30',
                            ),
                            Divider(
                              color: Color(0xFFCADDE4),
                              height: shortPhone ? 6 : 10,
                            ),
                            _LessonRow(
                              subject: 'Add. Maths',
                              className: '3 Bestari',
                              time: '11:30–12:30',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardAction(
                              icon: Icons.description,
                              label: 'View Reports',
                              onTap: () =>
                                  _notImplemented(context, 'View Reports'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DashboardAction(
                              icon: Icons.groups,
                              label: 'Manage Classes',
                              onTap: () =>
                                  _notImplemented(context, 'Manage Classes'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: shortPhone ? 6 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7EFF7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 26,
                              color: Color(0xFF4E9AAB),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Have a great day of teaching, Mr. Leong!',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.edit,
                              size: 22,
                              color: Color(0xFFDCAB4D),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Sample classes and lessons',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF63796F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                  selected: true,
                  onTap: () {},
                ),
                _NavigationItem(
                  icon: Icons.checklist_rounded,
                  label: 'Attendance',
                  onTap: () => _notImplemented(context, 'Attendance'),
                ),
                _NavigationItem(
                  icon: Icons.groups_rounded,
                  label: 'Students',
                  onTap: () => _notImplemented(context, 'Students'),
                ),
                _NavigationItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Timetable',
                  onTap: () => _notImplemented(context, 'Timetable'),
                ),
                _NavigationItem(
                  icon: Icons.account_circle_rounded,
                  label: 'Profile',
                  onTap: () => _notImplemented(context, 'Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.subject,
    required this.className,
    required this.time,
  });
  final String subject;
  final String className;
  final String time;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 4,
        child: Text(subject, style: const TextStyle(fontSize: 13)),
      ),
      const SizedBox(width: 4),
      Expanded(
        flex: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFC9E2E8),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            className,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        flex: 4,
        child: Text(
          time,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    ],
  );
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
                    color: selected ? _darkGreen : const Color(0xFF647082),
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
