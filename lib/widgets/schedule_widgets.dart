import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/class_attendance.dart';
import '../models/lesson.dart';

/// Pill showing whether a class's attendance is submitted (FR-03).
class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({super.key, required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final submitted = status == AttendanceStatus.submitted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: submitted ? AppColors.mintTint : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: submitted ? AppColors.mintTint : AppColors.amber,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            submitted ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: submitted ? AppColors.navSelected : AppColors.amber,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.darkGreen),
            ),
          ),
        ],
      ),
    );
  }
}

/// A class with its attendance status, e.g. "3 Bestari   [Not taken]".
class ClassAttendanceRow extends StatelessWidget {
  const ClassAttendanceRow({super.key, required this.attendance});

  final ClassAttendance attendance;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    // Wraps the chip onto its own line when large text needs the room.
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_outlined, color: AppColors.darkGreen),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                attendance.className,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        AttendanceStatusChip(status: attendance.status),
      ],
    ),
  );
}

/// One lesson in "Today's Schedule": subject and time, with the class.
class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson, this.highlighted = false});

  final Lesson lesson;

  /// Marks the lesson happening now or next.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: highlighted
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            )
          : null,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.subject,
                style: highlighted
                    ? text.titleSmall
                    : text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                lesson.timeRange,
                style: text.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.classChip,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(lesson.className, style: text.labelMedium),
          ),
        ],
      ),
    );
  }
}

/// The lesson happening now or next, so the teacher knows where to go.
class NextLessonCard extends StatelessWidget {
  const NextLessonCard({super.key, required this.lesson, required this.now});

  /// Null when today's lessons are over.
  final Lesson? lesson;
  final DateTime now;

  String _when(Lesson lesson) {
    if (lesson.isInProgress(now)) {
      return 'In progress · ends ${Lesson.formatTime(lesson.end)}';
    }
    final minutes = lesson.startOn(now).difference(now).inMinutes;
    if (minutes < 60) return 'Starts in $minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return 'Starts in ${hours}h${rest == 0 ? '' : ' $rest min'}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final current = lesson;
    return Card(
      key: const Key('next-lesson'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.scheduleCard,
                shape: BoxShape.circle,
              ),
              child: Icon(
                current == null
                    ? Icons.task_alt_rounded
                    : Icons.menu_book_rounded,
                size: 28,
                color: AppColors.lessonBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: current == null
                    ? [
                        Text('Next lesson', style: text.bodySmall),
                        Text('No more lessons today', style: text.titleMedium),
                      ]
                    : [
                        Text(
                          current.isInProgress(now) ? 'Now' : 'Next lesson',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(current.subject, style: text.titleMedium),
                        Text(
                          '${current.className} · ${current.timeRange}',
                          style: text.bodyLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _when(current),
                          style: text.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
