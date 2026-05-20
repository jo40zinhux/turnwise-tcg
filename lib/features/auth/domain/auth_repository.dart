import 'auth_result.dart';

/// Auth user identifier exposed to presentation without Firebase types.
class AuthUser {
  final String uid;
  final bool isAnonymous;

  const AuthUser({required this.uid, required this.isAnonymous});
}

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<AuthResult> signInAnonymously();

  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> signInWithApple();

  Future<void> signOut();
}
