import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sts_kehadiran/models/user_profile.dart';
import 'package:sts_kehadiran/services/auth_service.dart';
import 'package:sts_kehadiran/services/profile_service.dart';
import 'package:sts_kehadiran/services/sign_up_service.dart';

import 'fakes/fake_auth_service.dart';
import 'fakes/fake_profile_service.dart';

const _email = 'aina@school.edu.my';
const _password = 'secret123';

void main() {
  late FakeAuthService auth;
  late FakeProfileService profiles;
  late SignUpService service;

  setUp(() {
    auth = FakeAuthService();
    profiles = FakeProfileService(defaultProfile: null);
    service = SignUpService(
      auth: auth,
      profiles: profiles,
      profileTimeout: const Duration(milliseconds: 50),
    );
  });

  Future<void> signUp({
    String title = 'Ms.',
    String name = 'Aina Binti Ali',
    String email = _email,
    String password = _password,
  }) => service.signUpTeacher(
    title: title,
    name: name,
    email: email,
    password: password,
  );

  group('SignUpService.signUpTeacher', () {
    test(
      'creates the account, then a teacher profile with no classes',
      () async {
        await signUp(name: '  Aina Binti Ali ', email: ' $_email ');

        expect(auth.createdAccounts, [_email]);
        expect(auth.currentUser?.uid, auth.newUid);
        expect(profiles.created.keys, [auth.newUid]);
        expect(profiles.created[auth.newUid], {
          'title': 'Ms.',
          'name': 'Aina Binti Ali',
          'email': _email,
          'role': 'teacher',
          'classIds': <String>[],
          'createdAt': FakeProfileService.serverTime,
        });
        expect(auth.deletedUids, isEmpty);
      },
    );

    test('a failed account creation writes no profile', () async {
      auth.createAccountError = const AuthException(
        'An account with this email already exists. Try logging in instead.',
      );
      await expectLater(
        signUp(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('already exists'),
          ),
        ),
      );
      expect(profiles.created, isEmpty);
      expect(auth.deletedUids, isEmpty);
    });

    test('a failed profile write deletes the new account', () async {
      profiles.createError = Exception('[cloud_firestore/permission-denied]');
      await expectLater(
        signUp(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            SignUpService.profileFailedMessage,
          ),
        ),
      );
      expect(auth.deletedUids, [auth.newUid]);
      expect(auth.currentUser, isNull);
      expect(profiles.created, isEmpty);
    });

    test(
      'a profile write that never completes is timed out and undone',
      () async {
        profiles.createGate = Completer<void>(); // never completed
        await expectLater(
          signUp(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              SignUpService.profileFailedMessage,
            ),
          ),
        );
        expect(auth.deletedUids, [auth.newUid]);
        expect(auth.currentUser, isNull);
      },
    );

    test('signs out when the new account cannot be deleted either', () async {
      profiles.createError = Exception('unavailable');
      auth.deleteError = Exception('network-request-failed');
      await expectLater(signUp(), throwsA(isA<AuthException>()));
      expect(auth.deletedUids, isEmpty);
      expect(auth.signOutCalls, 1);
      expect(auth.currentUser, isNull);
    });

    test('never passes raw error text to the user', () async {
      profiles.createError = Exception('[cloud_firestore/internal] stack…');
      try {
        await signUp();
        fail('Expected an AuthException');
      } on AuthException catch (error) {
        expect(error.message, isNot(contains('cloud_firestore')));
        expect(error.message, isNot(contains('[')));
      }
    });

    test('rejects invalid details without contacting Firebase', () async {
      for (final call in [
        () => signUp(title: 'Prof.'),
        () => signUp(name: '   '),
        () => signUp(email: 'not-an-email'),
        () => signUp(password: 'short'),
      ]) {
        await expectLater(call(), throwsA(isA<AuthException>()));
      }
      expect(auth.createdAccounts, isEmpty);
      expect(profiles.created, isEmpty);
    });
  });

  group('teacherProfileData', () {
    test('always has role "teacher" and no classes', () {
      final data = teacherProfileData(
        title: 'Dr.',
        name: 'Lim',
        email: 'lim@school.edu.my',
        createdAt: 'now',
      );
      expect(data['role'], 'teacher');
      expect(data['classIds'], isEmpty);
      expect(data.keys, {
        'title',
        'name',
        'email',
        'role',
        'classIds',
        'createdAt',
      });
      final profile = UserProfile.fromMap(data);
      expect(profile.role, UserRole.teacher);
      expect(profile.displayName, 'Dr. Lim');
    });
  });

  group('FirebaseAuthService.messageFor', () {
    test('gives friendly sign-up messages', () {
      expect(
        FirebaseAuthService.messageFor('email-already-in-use'),
        'An account with this email already exists. Try logging in instead.',
      );
      expect(
        FirebaseAuthService.messageFor('invalid-email'),
        'That email address doesn’t look right.',
      );
      expect(
        FirebaseAuthService.messageFor('weak-password'),
        startsWith('That password is too weak.'),
      );
      expect(
        FirebaseAuthService.messageFor('network-request-failed'),
        startsWith('No internet connection.'),
      );
    });

    test('falls back to a generic message for anything else', () {
      for (final code in ['operation-not-allowed', 'internal-error', '']) {
        expect(
          FirebaseAuthService.messageFor(code),
          FirebaseAuthService.genericMessage,
          reason: code,
        );
      }
    });
  });
}
