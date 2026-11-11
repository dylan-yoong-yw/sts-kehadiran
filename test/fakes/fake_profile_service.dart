import 'dart:async';

import 'package:sts_kehadiran/models/teacher_profile.dart';
import 'package:sts_kehadiran/services/profile_service.dart';

/// In-memory [ProfileService] for widget tests; never touches Firestore.
class FakeProfileService implements ProfileService {
  FakeProfileService({
    this.defaultProfile = const TeacherProfile(title: 'Mr.', name: 'Leong'),
    Map<String, TeacherProfile?>? profiles,
    this.error,
  }) : profiles = profiles ?? {};

  /// Returned for any uid not listed in [profiles].
  final TeacherProfile? defaultProfile;

  /// Per-uid profiles; a null value means "no profile document".
  final Map<String, TeacherProfile?> profiles;

  /// When set, every profile read fails with this error.
  final Object? error;

  final _updates = StreamController<(String, TeacherProfile?)>.broadcast();

  /// Simulates the profile being edited in Firestore.
  void update(String uid, TeacherProfile? profile) {
    profiles[uid] = profile;
    _updates.add((uid, profile));
  }

  @override
  Stream<TeacherProfile?> watchProfile(String uid) async* {
    final failure = error;
    if (failure != null) throw failure;
    yield profiles.containsKey(uid) ? profiles[uid] : defaultProfile;
    yield* _updates.stream
        .where((update) => update.$1 == uid)
        .map((update) => update.$2);
  }
}
