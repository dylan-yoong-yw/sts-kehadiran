import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/teacher_profile.dart';

/// Reads teacher profiles. Screens depend on this interface so widget tests
/// can use a fake instead of Firestore.
abstract class ProfileService {
  /// Emits the teacher's profile, and again whenever it changes. Emits null
  /// when no profile exists for [uid].
  Stream<TeacherProfile?> watchProfile(String uid);
}

class FirestoreProfileService implements ProfileService {
  FirestoreProfileService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<TeacherProfile?> watchProfile(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => TeacherProfile.fromMap(snapshot.data()));
}
