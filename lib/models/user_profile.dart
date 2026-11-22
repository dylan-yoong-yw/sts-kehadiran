import 'package:flutter/foundation.dart';

/// Which interface a signed-in user sees (FR-01).
enum UserRole {
  teacher,
  admin;

  /// Reads the `role` field; null when it is missing or not a known role.
  /// Case and surrounding spaces are ignored, since the field is typed by
  /// hand in the Firebase console.
  static UserRole? parse(Object? value) {
    if (value is! String) return null;
    return switch (value.trim().toLowerCase()) {
      'teacher' => UserRole.teacher,
      'admin' => UserRole.admin,
      _ => null,
    };
  }
}

/// A user's details, stored in Firestore at `users/{uid}`.
///
/// Fields: `title` (e.g. "Mr."), `name` (e.g. "Adam"), `role` ("teacher" or
/// "admin") and `classIds` (the classes an admin has assigned). Teachers
/// create their own document at sign-up; admins are set up in the Firebase
/// console.
class UserProfile {
  const UserProfile({
    this.name,
    this.title,
    this.role,
    this.classIds = const [],
  });

  final String? name;
  final String? title;

  /// Null when the document has no role, or one the app does not know.
  final UserRole? role;

  /// Classes assigned by an admin; empty for a newly signed-up teacher.
  final List<String> classIds;

  /// How the user is addressed, e.g. "Mr. Adam", "Adam" without a title,
  /// or null without a name.
  String? get displayName {
    final name = this.name;
    if (name == null) return null;
    final title = this.title;
    return title == null ? name : '$title $name';
  }

  /// Reads a `users/{uid}` document. Blank or non-text fields count as
  /// missing, and blank or non-text class ids are skipped.
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    String? text(String key) {
      final value = data[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return UserProfile(
      name: text('name'),
      title: text('title'),
      role: UserRole.parse(data['role']),
      classIds: switch (data['classIds']) {
        final List<dynamic> ids => [
          for (final id in ids)
            if (id is String && id.trim().isNotEmpty) id.trim(),
        ],
        _ => const [],
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.name == name &&
      other.title == title &&
      other.role == role &&
      listEquals(other.classIds, classIds);

  @override
  int get hashCode => Object.hash(name, title, role, Object.hashAll(classIds));
}
