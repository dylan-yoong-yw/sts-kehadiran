/// A teacher's details, stored in Firestore at `users/{uid}`.
///
/// Fields: `name` (required, e.g. "Dylan") and `title` (optional, e.g. "Mr.").
class TeacherProfile {
  const TeacherProfile({required this.name, this.title});

  final String name;
  final String? title;

  /// How the teacher is addressed, e.g. "Mr. Dylan", or "Dylan" without a title.
  String get displayName {
    final prefix = title;
    return prefix == null ? name : '$prefix $name';
  }

  /// Returns null when the document is missing or has no usable name.
  static TeacherProfile? fromMap(Map<String, dynamic>? data) {
    String? text(String key) {
      final value = data?[key];
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final name = text('name');
    if (name == null) return null;
    return TeacherProfile(name: name, title: text('title'));
  }
}
