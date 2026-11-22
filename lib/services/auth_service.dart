import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../models/app_user.dart';

/// A sign-in or sign-up failure with a message that is safe to show to the
/// user. It never carries Firebase's own error text.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication used by the app. Screens depend on this interface, not on
/// Firebase directly, so widget tests can use a fake implementation.
abstract class AuthService {
  /// The user restored from the last session, known as soon as Firebase is
  /// initialised on Android and iOS.
  AppUser? get currentUser;

  /// Emits on every sign-in and sign-out.
  Stream<AppUser?> authStateChanges();

  /// Throws [AuthException] when sign-in fails.
  Future<void> signIn({required String email, required String password});

  /// Throws [AuthException] when the reset email cannot be requested.
  Future<void> sendPasswordReset(String email);

  /// Creates an email/password account and signs it in (FR-01). Throws
  /// [AuthException] when the account cannot be created.
  Future<AppUser> createAccount({
    required String email,
    required String password,
  });

  /// Deletes the signed-in account. Used only to undo a sign-up whose
  /// profile could not be saved.
  Future<void> deleteCurrentUser();

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        );

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAppUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      throw AuthException(messageFor(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      // Don't reveal whether an account exists for this email.
      if (error.code == 'user-not-found') return;
      throw AuthException(messageFor(error.code));
    }
  }

  @override
  Future<AppUser> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _toAppUser(credential.user);
      if (user == null) throw const AuthException(genericMessage);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthException(messageFor(error.code));
    }
  }

  @override
  Future<void> deleteCurrentUser() async => _auth.currentUser?.delete();

  @override
  Future<void> signOut() => _auth.signOut();

  static const genericMessage = 'Something went wrong. Please try again.';

  /// A friendly message for a Firebase Auth error [code].
  @visibleForTesting
  static String messageFor(String code) => switch (code) {
    'invalid-email' => 'That email address doesn’t look right.',
    'email-already-in-use' =>
      'An account with this email already exists. Try logging in instead.',
    'weak-password' =>
      'That password is too weak. Use at least 8 characters, mixing '
          'letters and numbers.',
    'user-disabled' =>
      'This account has been disabled. Please contact your school admin.',
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => 'Incorrect email or password.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment and try again.',
    'network-request-failed' =>
      'No internet connection. Please check your network and try again.',
    _ => genericMessage,
  };
}

/// Makes the [AuthService] available to every screen below it.
class AuthScope extends InheritedWidget {
  const AuthScope({super.key, required this.service, required super.child});

  final AuthService service;

  static AuthService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.service;

  static AuthService of(BuildContext context) {
    final service = maybeOf(context);
    assert(service != null, 'No AuthScope found in the widget tree.');
    return service!;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) => service != oldWidget.service;
}
