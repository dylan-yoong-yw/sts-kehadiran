import 'package:flutter/material.dart';

import 'screens/main_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'STS Kehadiran',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27665B)),
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      useMaterial3: true,
    ),
    home: const MainScreen(),
  );
}

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  String selectedClass = '1 Amanah';
  int selectedTab = 0;
  static const tabs = ['Home', 'Students', 'Attendance', 'Timetable', 'More'];

  void showPreview(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(message),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get dateLabel {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
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
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get greeting {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good morning, Teacher'
        : hour < 18
        ? 'Good afternoon, Teacher'
        : 'Good evening, Teacher';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedTab == 0
              ? 'STS Kehadiran'
              : selectedTab == 3
              ? 'My Timetable'
              : tabs[selectedTab],
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            tooltip: 'Teacher profile',
            onPressed: () => showPreview(
              'Teacher profile',
              'Your teacher profile will be available here in a later step.',
            ),
            icon: const Icon(Icons.account_circle_outlined, size: 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab == 2
              ? 1
              : selectedTab == 3
              ? 2
              : 0,
          children: [
            selectedTab == 0
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'My class',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClass,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['1 Amanah', '2 Bestari']
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedClass = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      _HomeCard(
                        children: [
                          Text(
                            'Today’s attendance',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Not submitted',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF795B2B),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => showPreview(
                                'Take Attendance',
                                'The attendance form for $selectedClass will be built next. No attendance has been submitted.',
                              ),
                              icon: const Icon(Icons.fact_check_outlined),
                              label: const Text(
                                'Take Attendance',
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _HomeCard(
                        children: [
                          Text(
                            'Next class',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Mathematics • 2 Bestari',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '9:00 – 10:00 AM',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Icon(Icons.notifications_none, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Reminder: 10 minutes before'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sample lesson • reminders are not enabled yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            [
                              Icons.home_outlined,
                              Icons.people_outline,
                              Icons.fact_check_outlined,
                              Icons.calendar_month_outlined,
                              Icons.more_horiz,
                            ][selectedTab],
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tabs[selectedTab],
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'We’ll build this screen in the next steps.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
            const Center(child: Text('Attendance: Not implemented yet.')),
            const Center(child: Text('Timetable: Not implemented yet.')),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Timetable',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFDDE5E1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
