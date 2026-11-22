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

  /// When set, the next sign-up waits for this to complete (to test loading).
  Completer<void>? createAccountGate;

  /// When set, creating an account fails with this error.
  AuthException? createAccountError;

  /// When set, deleting the signed-in account fails with this error.
  Object? deleteError;

  /// Emails of accounts created, in order.
  final createdAccounts = <String>[];

  /// Uids of accounts deleted, in order.
  final deletedUids = <String>[];
  int signOutCalls = 0;

  /// The uid given to the next account created.
  String newUid = 'new-teacher-1';

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
  Future<AppUser> createAccount({
    required String email,
    required String password,
  }) async {
    await createAccountGate?.future;
    final error = createAccountError;
    if (error != null) throw error;
    createdAccounts.add(email);
    final created = AppUser(uid: newUid, email: email);
    _emit(created);
    return created;
  }

  @override
  Future<void> deleteCurrentUser() async {
    final error = deleteError;
    if (error != null) throw error;
    final current = user;
    if (current == null) return;
    deletedUids.add(current.uid);
    _emit(null);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _emit(null);
  }
}
