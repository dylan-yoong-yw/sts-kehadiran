/// Form validators shared by the login and sign-up screens (FR-01).
///
/// Each returns a message to show under the field, or null when the value
/// is valid.
library;

/// How a teacher can be addressed. Firestore rules accept only these.
const teacherTitles = ['Mr.', 'Ms.', 'Mdm.', 'Dr.'];

/// Shortest password accepted at sign-up.
const minPasswordLength = 8;

/// Longest name accepted at sign-up (also enforced by Firestore rules).
const maxNameLength = 100;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Please enter your email.';
  if (!_emailPattern.hasMatch(email)) {
    return 'Please enter a valid email address.';
  }
  return null;
}

String? validateTitle(String? value) =>
    teacherTitles.contains(value) ? null : 'Please choose your title.';

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Please enter your full name.';
  if (name.length > maxNameLength) {
    return 'Name must be $maxNameLength characters or fewer.';
  }
  return null;
}

String? validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Please enter a password.';
  if (password.length < minPasswordLength) {
    return 'Password must be at least $minPasswordLength characters.';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  final confirm = value ?? '';
  if (confirm.isEmpty) return 'Please confirm your password.';
  if (confirm != password) return 'Passwords do not match.';
  return null;
}
