import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/mock_schedule.dart';
import '../models/lesson.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/fill_scroll_view.dart';
import '../widgets/schedule_widgets.dart';

const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
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

/// The teacher's home dashboard (the first tab of [MainScreen]).
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.teacherName, required this.now});

  final String teacherName;
  final DateTime now;

  static void showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature: Not implemented yet.'),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
  }

  Future<void> _selectClass(BuildContext context) async {
    final selectedClass = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select a class'),
        children: MockSchedule.classes
            .map(
              (item) => SimpleDialogOption(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                onPressed: () => Navigator.pop(context, item.className),
                child: ClassAttendanceRow(attendance: item),
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
    final text = Theme.of(context).textTheme;
    final upcoming = nextLesson(MockSchedule.lessons, now);
    const gap = SizedBox(height: AppSpacing.section);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        // Quick Actions sit just above the navigation bar on tall phones
        // instead of leaving an empty band; shorter phones scroll.
        child: FillScrollView(
          scrollKey: const Key('dashboard-scroll'),
          sections: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gap,
                Row(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 28,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'STS Kehadiran',
                        style: text.titleLarge?.copyWith(
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                gap,
                _Greeting(teacherName: teacherName, now: now),
                const SizedBox(height: 20),
                DashboardCard(
                  color: AppColors.attendanceCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Today’s Attendance', style: text.titleMedium),
                      Text(
                        'Submit to the admin by '
                        '${Lesson.formatTime(MockSchedule.reportDeadline)} '
                        'AM',
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),
                      for (final item in MockSchedule.classes)
                        ClassAttendanceRow(attendance: item),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: AppTheme.primaryButton,
                        onPressed: () => _selectClass(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Take Attendance',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.north_east, size: 22),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gap,
                NextLessonCard(lesson: upcoming, now: now),
                gap,
                DashboardCard(
                  color: AppColors.scheduleCard,
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Today’s Schedule',
                          style: text.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final (i, lesson)
                          in MockSchedule.lessons.indexed) ...[
                        if (i > 0) const SizedBox(height: 4),
                        LessonRow(
                          lesson: lesson,
                          highlighted: identical(lesson, upcoming),
                        ),
                      ],
                    ],
                  ),
                ),
                gap,
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Quick Actions', style: text.titleMedium),
                const SizedBox(height: 12),
                QuickActionsGrid(
                  actions: [
                    for (final (icon, label) in [
                      (Icons.description, 'View Reports'),
                      // Parent/guardian contact for absences (FR-02).
                      (Icons.contact_phone_rounded, 'Contact Parents'),
                      (Icons.groups, 'Manage Classes'),
                    ])
                      QuickAction(
                        icon: icon,
                        label: label,
                        onTap: () => showNotImplemented(context, label),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sample classes and lessons',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                gap,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.teacherName, required this.now});

  final String teacherName;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final month = _months[now.month - 1];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $teacherName', style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${_days[now.weekday - 1]}, ${now.day} $month ${now.year}',
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.dateChip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.dateChipIcon,
              ),
              Text(
                '${now.day} ${month.substring(0, 3)}',
                style: text.labelMedium?.copyWith(
                  color: AppColors.dateChipText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
