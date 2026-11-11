import 'dart:async';

import 'package:sts_kehadiran/models/app_user.dart';
import 'package:sts_kehadiran/services/auth_service.dart';

const testEmail = 'teacher@test.com';
const testPassword = 'secret123';

/// In-memory [AuthService] for widget tests; never touches Firebase.
class FakeAuthService implements AuthService {
  FakeAuthService({this.user});

  factory FakeAuthService.signedIn() => FakeAuthService(
    user: const AppUser(uid: 'teacher-1', email: testEmail),
  );

  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? user;

  /// When set, the next sign-in waits for this to complete (to test loading).
  Completer<void>? signInGate;

  /// When set, the next password reset fails with this error.
  AuthException? resetError;

  final resetRequests = <String>[];
  int signInAttempts = 0;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> authStateChanges() => _changes.stream;

  void _emit(AppUser? user) {
    this.user = user;
    _changes.add(user);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInAttempts++;
    await signInGate?.future;
    if (email != testEmail || password != testPassword) {
      throw const AuthException('Incorrect email or password.');
    }
    _emit(AppUser(uid: 'teacher-1', email: email));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final error = resetError;
    if (error != null) throw error;
    resetRequests.add(email);
  }

  @override
  Future<void> signOut() async => _emit(null);
}
