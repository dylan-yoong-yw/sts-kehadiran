/// Whether today's attendance for a class has been submitted (FR-03).
enum AttendanceStatus {
  notTaken('Not taken'),
  submitted('Submitted');

  const AttendanceStatus(this.label);

  final String label;
}

/// Today's attendance status for one class the teacher is responsible for.
class ClassAttendance {
  const ClassAttendance({required this.className, required this.status});

  final String className;
  final AttendanceStatus status;
}
