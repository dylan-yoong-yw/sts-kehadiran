import 'package:flutter/material.dart' show TimeOfDay;

import '../models/class_attendance.dart';
import '../models/lesson.dart';

/// Sample data shown until classes and timetables come from Firestore.
abstract final class MockSchedule {
  static const lessons = [
    Lesson(
      subject: 'Mathematics',
      className: '4 Cemerlang',
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
    ),
    Lesson(
      subject: 'Physics',
      className: '5 Bijak',
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 10, minute: 30),
    ),
    Lesson(
      subject: 'Add. Maths',
      className: '3 Bestari',
      start: TimeOfDay(hour: 11, minute: 30),
      end: TimeOfDay(hour: 12, minute: 30),
    ),
  ];

  static const classes = [
    ClassAttendance(className: '3 Bestari', status: AttendanceStatus.notTaken),
    ClassAttendance(
      className: '4 Cemerlang',
      status: AttendanceStatus.submitted,
    ),
  ];

  /// Attendance reports are due to the school admin by this time (FR-03).
  static const reportDeadline = TimeOfDay(hour: 7, minute: 30);
}
