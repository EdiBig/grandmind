import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kinesa/features/authentication/data/repositories/auth_repository.dart';
import 'package:kinesa/features/user/data/services/firestore_service.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';
import 'package:kinesa/core/errors/exceptions.dart';
import '../../helpers/test_helpers.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFirestoreService extends Mock implements FirestoreService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserInfo extends Mock implements UserInfo {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late AuthRepository authRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFirestoreService mockFirestoreService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFirestoreService = MockFirestoreService();

    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      firestoreService: mockFirestoreService,
      analytics: MockAnalyticsService(),
    );
  });

  setUpAll(() {
    registerFallbackValue(UserModel(
      id: 'test',
      email: 'test@test.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(FakeAuthCredential());
  });

  group('AuthRepository', () {
    group('currentUser', () {
      test('returns current user when signed in', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        expect(authRepository.currentUser, mockUser);
      });

      test('returns null when no user signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(authRepository.currentUser, isNull);
      });
    });

    group('authStateChanges', () {
      test('returns auth state changes stream', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        expect(authRepository.authStateChanges, emits(mockUser));
      });

      test('emits null when user signs out', () {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        expect(authRepository.authStateChanges, emits(null));
      });
    });

    group('signInWithEmailAndPassword', () {
      test('returns UserCredential on successful sign in', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([]);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockFirestoreService.getUser(any()))
            .thenAnswer((_) async => UserModel(
                  id: 'test-uid',
                  email: 'test@example.com',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ));

        final result = await authRepository.signInWithEmailAndPassword(
          'test@example.com',
          'Password123',
        );

        expect(result, mockCredential);
        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'Password123',
            )).called(1);
      });

      test('creates user profile if not exists after sign in', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([]);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockFirestoreService.getUser(any()))
            .thenAnswer((_) async => null);

        when(() => mockFirestoreService.createUser(any()))
            .thenAnswer((_) async {});

        await authRepository.signInWithEmailAndPassword(
          'test@example.com',
          'Password123',
        );

        verify(() => mockFirestoreService.createUser(any())).called(1);
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('creates new user and profile on successful sign up', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        final mockUserInfo = MockUserInfo();

        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('new-user-uid');
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);
        when(() => mockUserInfo.providerId).thenReturn('password');
        when(() => mockUser.updateDisplayName(any()))
            .thenAnswer((_) async {});

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockFirestoreService.createUser(any()))
            .thenAnswer((_) async {});

        final result = await authRepository.signUpWithEmailAndPassword(
          'newuser@example.com',
          'Password123',
          displayName: 'New User',
        );

        expect(result, mockCredential);
        verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'newuser@example.com',
              password: 'Password123',
            )).called(1);
        verify(() => mockFirestoreService.createUser(any())).called(1);
        verify(() => mockUser.updateDisplayName('New User')).called(1);
      });

      test('does not update display name if not provided', () async {
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();
        final mockUserInfo = MockUserInfo();

        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('new-user-uid');
        when(() => mockUser.providerData).thenReturn([mockUserInfo]);
        when(() => mockUserInfo.providerId).thenReturn('password');

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        when(() => mockFirestoreService.createUser(any()))
            .thenAnswer((_) async {});

        await authRepository.signUpWithEmailAndPassword(
          'newuser@example.com',
          'Password123',
        );

        verifyNever(() => mockUser.updateDisplayName(any()));
      });
    });

    group('signInWithGoogle', () {
      test('throws AuthException when Google sign-in is cancelled', () async {
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        expect(
          () => authRepository.signInWithGoogle(),
          throwsA(isA<AuthException>()),
        );
      });

      test('completes Google sign-in flow successfully', () async {
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleAuth.idToken).thenReturn('id-token');

        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('google-uid');
        when(() => mockUser.email).thenReturn('google@example.com');
        when(() => mockUser.displayName).thenReturn('Google User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([]);

        when(() => mockFirestoreService.getUser(any()))
            .thenAnswer((_) async => UserModel(
                  id: 'google-uid',
                  email: 'google@example.com',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ));

        await authRepository.signInWithGoogle();

        verify(() => mockGoogleSignIn.signIn()).called(1);
        verify(() => mockGoogleAccount.authentication).called(1);
        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      });
    });

    group('signOut', () {
      test('signs out from both Firebase and Google', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authRepository.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('sends password reset email successfully', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenAnswer((_) async {});

        await authRepository.sendPasswordResetEmail('test@example.com');

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: 'test@example.com',
            )).called(1);
      });
    });

    group('ensureUserProfile', () {
      test('returns existing user if found', () async {
        final mockUser = MockUser();
        final existingUserModel = UserModel(
          id: 'existing-uid',
          email: 'existing@example.com',
          displayName: 'Existing User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockUser.uid).thenReturn('existing-uid');

        when(() => mockFirestoreService.getUser('existing-uid'))
            .thenAnswer((_) async => existingUserModel);

        final result = await authRepository.ensureUserProfile(mockUser);

        expect(result.id, 'existing-uid');
        expect(result.email, 'existing@example.com');
        verifyNever(() => mockFirestoreService.createUser(any()));
      });

      test('creates new user profile if not exists', () async {
        final mockUser = MockUser();

        when(() => mockUser.uid).thenReturn('new-uid');
        when(() => mockUser.email).thenReturn('new@example.com');
        when(() => mockUser.displayName).thenReturn('New User');
        when(() => mockUser.photoURL).thenReturn('https://photo.url');
        when(() => mockUser.providerData).thenReturn([]);

        when(() => mockFirestoreService.getUser('new-uid'))
            .thenAnswer((_) async => null);
        when(() => mockFirestoreService.createUser(any()))
            .thenAnswer((_) async {});

        final result = await authRepository.ensureUserProfile(mockUser);

        expect(result.id, 'new-uid');
        expect(result.email, 'new@example.com');
        verify(() => mockFirestoreService.createUser(any())).called(1);
      });

      test('uses override display name when provided', () async {
        final mockUser = MockUser();

        when(() => mockUser.uid).thenReturn('new-uid');
        when(() => mockUser.email).thenReturn('new@example.com');
        when(() => mockUser.displayName).thenReturn('Original Name');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([]);

        when(() => mockFirestoreService.getUser('new-uid'))
            .thenAnswer((_) async => null);
        when(() => mockFirestoreService.createUser(any()))
            .thenAnswer((_) async {});

        final result = await authRepository.ensureUserProfile(
          mockUser,
          overrideDisplayName: 'Override Name',
        );

        expect(result.displayName, 'Override Name');
      });
    });
  });
}
