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

/// Date formats shared by the teacher and admin home screens.
abstract final class DateFormats {
  /// e.g. "Wednesday, 21 October 2026".
  static String long(DateTime date) =>
      '${_days[date.weekday - 1]}, ${date.day} '
      '${_months[date.month - 1]} ${date.year}';

  /// e.g. "21 Oct".
  static String dayMonth(DateTime date) =>
      '${date.day} ${_months[date.month - 1].substring(0, 3)}';
}
