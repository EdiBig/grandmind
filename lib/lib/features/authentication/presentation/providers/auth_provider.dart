import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState.initial());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      await _authRepository.signInWithGoogle();
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _authRepository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthState.loading();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = const AuthState.passwordResetSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        errorMessage = null;

  const AuthState.authenticated()
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        errorMessage = null;

  const AuthState.error(this.errorMessage) : status = AuthStatus.error;

  const AuthState.passwordResetSent()
      : status = AuthStatus.passwordResetSent,
        errorMessage = null;
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  passwordResetSent,
}
