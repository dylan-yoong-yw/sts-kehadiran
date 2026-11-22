import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// The `users/{uid}` document written when a teacher signs up (FR-01).
///
/// The role is always "teacher" and `classIds` always empty: there is no
/// parameter for either, and Firestore rules reject anything else. Only an
/// admin, in the Firebase console, can change them. [createdAt] is
/// `FieldValue.serverTimestamp()` in the app.
Map<String, Object> teacherProfileData({
  required String title,
  required String name,
  required String email,
  required Object createdAt,
}) => {
  'title': title,
  'name': name,
  'email': email,
  'role': 'teacher',
  'classIds': const <String>[],
  'createdAt': createdAt,
};

/// Reads and creates user profiles. Screens depend on this interface so
/// widget tests can use a fake instead of Firestore.
abstract class ProfileService {
  /// Emits the user's profile, and again whenever it changes (for example
  /// when an admin edits the role in the console). Emits null when no
  /// `users/{uid}` document exists.
  Stream<UserProfile?> watchProfile(String uid);

  /// Creates `users/{uid}` for a teacher who has just signed up, with the
  /// fields in [teacherProfileData]. Completes once the server has saved it.
  Future<void> createTeacherProfile({
    required String uid,
    required String title,
    required String name,
    required String email,
  });
}

class FirestoreProfileService implements ProfileService {
  FirestoreProfileService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<UserProfile?> watchProfile(String uid) => _db
      .collection('users')
      .doc(uid)
      // Metadata changes tell us when the server has confirmed a document
      // that the offline cache did not have.
      .snapshots(includeMetadataChanges: true)
      // "No document" from the cache only means it was never cached (e.g.
      // the first launch offline); wait for the server before treating the
      // account as not set up.
      .where((snapshot) => snapshot.exists || !snapshot.metadata.isFromCache)
      .map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : UserProfile.fromMap(data);
      })
      .distinct();

  @override
  Future<void> createTeacherProfile({
    required String uid,
    required String title,
    required String name,
    required String email,
  }) => _db
      .collection('users')
      .doc(uid)
      .set(
        teacherProfileData(
          title: title,
          name: name,
          email: email,
          createdAt: FieldValue.serverTimestamp(),
        ),
      );
}
