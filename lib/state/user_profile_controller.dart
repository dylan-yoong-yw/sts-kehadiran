import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';

enum ProfileStatus {
  /// Waiting for the first read of `users/{uid}`.
  loading,

  /// The document exists; see [UserProfileController.profile].
  loaded,

  /// There is no `users/{uid}` document.
  missing,

  /// The document could not be read (e.g. offline or permission denied).
  error,
}

/// The signed-in user's profile, kept up to date from [ProfileService] and
/// shared with the screens through Provider.
class UserProfileController extends ChangeNotifier {
  UserProfileController({required this.service, required this.uid}) {
    _listen();
  }

  final ProfileService service;
  final String uid;
  StreamSubscription<UserProfile?>? _subscription;

  ProfileStatus _status = ProfileStatus.loading;
  ProfileStatus get status => _status;

  UserProfile? _profile;

  /// The latest profile; null unless [status] is [ProfileStatus.loaded].
  UserProfile? get profile => _profile;

  Object? _error;
  Object? get error => _error;

  void _listen() {
    _subscription?.cancel();
    _subscription = service
        .watchProfile(uid)
        .listen(
          (profile) {
            _profile = profile;
            _error = null;
            _status = profile == null
                ? ProfileStatus.missing
                : ProfileStatus.loaded;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Could not load profile for $uid: $error');
            _error = error;
            _status = ProfileStatus.error;
            notifyListeners();
          },
        );
  }

  /// Reads the profile again after an error.
  void retry() {
    _status = ProfileStatus.loading;
    _error = null;
    notifyListeners();
    _listen();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
