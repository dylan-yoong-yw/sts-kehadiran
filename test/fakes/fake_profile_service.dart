import 'dart:async';

import 'package:sts_kehadiran/models/user_profile.dart';
import 'package:sts_kehadiran/services/profile_service.dart';

const teacherLeong = UserProfile(
  title: 'Mr.',
  name: 'Leong',
  role: UserRole.teacher,
);
const adminAdam = UserProfile(title: 'Mr.', name: 'Adam', role: UserRole.admin);

/// In-memory [ProfileService] for widget tests; never touches Firestore.
class FakeProfileService implements ProfileService {
  FakeProfileService({
    this.defaultProfile = teacherLeong,
    Map<String, UserProfile?>? profiles,
    this.error,
  }) : profiles = profiles ?? {};

  /// Returned for any uid not listed in [profiles].
  final UserProfile? defaultProfile;

  /// Per-uid profiles; a null value means "no profile document".
  final Map<String, UserProfile?> profiles;

  /// When set, every profile read fails with this error. Can be cleared to
  /// test retrying.
  Object? error;

  /// When set, the first profile read waits for this (to test loading).
  Completer<void>? gate;

  /// How many times a profile stream has been opened.
  int reads = 0;

  final _updates = StreamController<(String, UserProfile?)>.broadcast();

  /// Simulates the profile being edited in Firestore.
  void update(String uid, UserProfile? profile) {
    profiles[uid] = profile;
    _updates.add((uid, profile));
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    reads++;
    await gate?.future;
    final failure = error;
    if (failure != null) throw failure;
    yield profiles.containsKey(uid) ? profiles[uid] : defaultProfile;
    yield* _updates.stream
        .where((update) => update.$1 == uid)
        .map((update) => update.$2);
  }
}
