import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_result.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser(uid: user.uid, isAnonymous: user.isAnonymous);
    });
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      await _saveUserToFirestore(userCredential.user);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
      return AuthResult.failure(
        'Não foi possível entrar sem conta. Verifica a ligação e tenta novamente.',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResult.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserToFirestore(userCredential.user);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      debugPrint('Failed to sign in with Google: $e');
      return AuthResult.failure(
        'Falha ao entrar com Google. Verifica a internet e tenta novamente.',
      );
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserToFirestore(userCredential.user);
      return const AuthResult.success();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.cancelled();
      }
      return AuthResult.failure('Não foi possível entrar com Apple.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      debugPrint('Failed to sign in with Apple: $e');
      return AuthResult.failure(
        'Falha ao entrar com Apple. Verifica a ligação e tenta novamente.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Anonymous User',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isAnonymous': user.isAnonymous,
        });
      } else {
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'isAnonymous': user.isAnonymous,
        });
      }
    } catch (e) {
      debugPrint('Firestore profile sync skipped: $e');
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Sem ligação à internet. Tenta novamente ou usa "Jogar sem conta".';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarda um momento e tenta de novo.';
      default:
        return 'Não foi possível iniciar sessão. Tenta novamente.';
    }
  }
}
