import 'package:flutter/material.dart' show TimeOfDay;

/// One lesson in a teacher's daily timetable.
class Lesson {
  const Lesson({
    required this.subject,
    required this.className,
    required this.start,
    required this.end,
  });

  final String subject;
  final String className;
  final TimeOfDay start;
  final TimeOfDay end;

  DateTime startOn(DateTime day) =>
      DateTime(day.year, day.month, day.day, start.hour, start.minute);

  DateTime endOn(DateTime day) =>
      DateTime(day.year, day.month, day.day, end.hour, end.minute);

  bool isInProgress(DateTime now) =>
      !now.isBefore(startOn(now)) && now.isBefore(endOn(now));

  /// e.g. "8:00–9:00".
  String get timeRange => '${formatTime(start)}–${formatTime(end)}';

  /// 24-hour time without a leading zero, e.g. "8:00" or "13:30".
  static String formatTime(TimeOfDay time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

/// The lesson happening now, or else the next one today; null when today's
/// lessons are over.
Lesson? nextLesson(List<Lesson> lessons, DateTime now) {
  final remaining = lessons.where((l) => now.isBefore(l.endOn(now))).toList()
    ..sort((a, b) => a.startOn(now).compareTo(b.startOn(now)));
  return remaining.isEmpty ? null : remaining.first;
}
