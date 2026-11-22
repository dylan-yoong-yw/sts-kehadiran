import 'package:flutter/foundation.dart';

import '../core/validators.dart';
import 'auth_service.dart';
import 'profile_service.dart';

/// Registers a new teacher (FR-01): creates the Firebase Auth account, then
/// the `users/{uid}` profile. If the profile cannot be saved, the new
/// account is deleted again so no half-created account is left behind.
///
/// Screens call this instead of Firebase directly, so tests can run it over
/// fake [AuthService] and [ProfileService] implementations.
class SignUpService {
  SignUpService({
    required this._auth,
    required this._profiles,
    this.profileTimeout = const Duration(seconds: 15),
  });

  final AuthService _auth;
  final ProfileService _profiles;

  /// How long to wait for the server to save the profile. Firestore keeps
  /// an offline write pending instead of failing, so without a limit a lost
  /// connection would leave the sign-up spinning forever.
  final Duration profileTimeout;

  static const profileFailedMessage =
      'We couldn’t finish creating your account. Please check your internet '
      'connection and try again.';

  /// Signs up a teacher; on success the new teacher is signed in.
  ///
  /// Throws [AuthException] with a message safe to show to the user.
  Future<void> signUpTeacher({
    required String title,
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    // The screen validates first; this guards against other callers.
    if (validateTitle(title) != null ||
        validateName(trimmedName) != null ||
        validateEmail(trimmedEmail) != null ||
        validateNewPassword(password) != null) {
      throw const AuthException('Please check the details you entered.');
    }

    final user = await _auth.createAccount(
      email: trimmedEmail,
      password: password,
    );
    try {
      await _profiles
          .createTeacherProfile(
            uid: user.uid,
            title: title,
            name: trimmedName,
            // The address as Firebase stored it, which is what the rules
            // compare against.
            email: user.email ?? trimmedEmail,
          )
          .timeout(profileTimeout);
    } catch (error) {
      debugPrint('Sign-up: profile for ${user.uid} not saved: $error');
      await _undoAccount();
      throw const AuthException(profileFailedMessage);
    }
  }

  /// Deletes the just-created account; if that fails too (e.g. offline),
  /// at least signs it out so the user is not left in a broken state.
  Future<void> _undoAccount() async {
    try {
      await _auth.deleteCurrentUser();
    } catch (error) {
      debugPrint('Sign-up: could not delete the new account: $error');
      try {
        await _auth.signOut();
      } catch (_) {}
    }
  }
}
