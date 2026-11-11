import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../models/app_user.dart';

/// A sign-in failure with a message that is safe to show to the user.
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
      throw AuthException(_messageFor(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      // Don't reveal whether an account exists for this email.
      if (error.code == 'user-not-found') return;
      throw AuthException(_messageFor(error.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static String _messageFor(String code) => switch (code) {
    'invalid-email' => 'That email address doesn’t look right.',
    'user-disabled' =>
      'This account has been disabled. Please contact your school admin.',
    'invalid-credential' ||
    'user-not-found' ||
    'wrong-password' => 'Incorrect email or password.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment and try again.',
    'network-request-failed' =>
      'No internet connection. Please check your network and try again.',
    _ => 'Something went wrong. Please try again.',
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
