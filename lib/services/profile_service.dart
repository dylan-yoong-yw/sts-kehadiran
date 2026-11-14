import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Reads user profiles. Screens depend on this interface so widget tests
/// can use a fake instead of Firestore.
abstract class ProfileService {
  /// Emits the user's profile, and again whenever it changes (for example
  /// when an admin edits the role in the console). Emits null when no
  /// `users/{uid}` document exists.
  Stream<UserProfile?> watchProfile(String uid);
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
}
