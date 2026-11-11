import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/data/mock_schedule.dart';
import 'package:sts_kehadiran/models/class_attendance.dart';
import 'package:sts_kehadiran/models/lesson.dart';

DateTime _at(int hour, [int minute = 0]) =>
    DateTime(2026, 11, 11, hour, minute);

void main() {
  const lessons = MockSchedule.lessons;

  group('nextLesson', () {
    test('before school is the first lesson', () {
      expect(nextLesson(lessons, _at(7))?.subject, 'Mathematics');
    });

    test('during a lesson is that lesson', () {
      final lesson = nextLesson(lessons, _at(8, 30));
      expect(lesson?.subject, 'Mathematics');
      expect(lesson?.isInProgress(_at(8, 30)), isTrue);
    });

    test('between lessons is the upcoming one', () {
      final lesson = nextLesson(lessons, _at(9, 10));
      expect(lesson?.subject, 'Physics');
      expect(lesson?.isInProgress(_at(9, 10)), isFalse);
    });

    test('a lesson ending now is over', () {
      expect(nextLesson(lessons, _at(9))?.subject, 'Physics');
    });

    test('after the last lesson is null', () {
      expect(nextLesson(lessons, _at(12, 30)), isNull);
      expect(nextLesson(const [], _at(8)), isNull);
    });

    test('ignores the order lessons are listed in', () {
      expect(
        nextLesson(lessons.reversed.toList(), _at(7))?.subject,
        'Mathematics',
      );
    });
  });

  test('formats times without a leading zero', () {
    expect(lessons.first.timeRange, '8:00–9:00');
    expect(Lesson.formatTime(const TimeOfDay(hour: 13, minute: 5)), '13:05');
  });

  test('attendance statuses have readable labels', () {
    expect(AttendanceStatus.notTaken.label, 'Not taken');
    expect(AttendanceStatus.submitted.label, 'Submitted');
  });
}
