import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_result.dart';
import 'apple_auth_nonce.dart';
import 'google_sign_in_gateway.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignInGateway.instance;

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
      return AuthResult.success(userId: userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e, stack) {
      debugPrint('Failed to sign in anonymously: $e\n$stack');
      return AuthResult.failure(
        'Não foi possível entrar sem conta. Verifica a ligação e tenta novamente.',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const AuthResult.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint(
          'Google Sign-In: idToken is null. '
          'Check serverClientId (web) and SHA-1 in Firebase Console.',
        );
        return AuthResult.failure(
          'Não foi possível validar a conta Google. Tenta novamente.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );

      final userCredential = await _signInOrLink(credential);
      await _saveUserToFirestore(userCredential.user);
      return AuthResult.success(userId: userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      debugPrint('Google FirebaseAuthException: ${e.code} ${e.message}');
      return AuthResult.failure(_mapAuthError(e));
    } catch (e, stack) {
      debugPrint('Failed to sign in with Google: $e\n$stack');
      return AuthResult.failure(
        'Falha ao entrar com Google. Verifica a internet e tenta novamente.',
      );
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        return await _signInWithAppleNative();
      }
      return await _signInWithAppleOAuthProvider();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.cancelled();
      }
      debugPrint('Apple authorization error: ${e.code}');
      return AuthResult.failure('Não foi possível entrar com Apple.');
    } on FirebaseAuthException catch (e) {
      debugPrint('Apple FirebaseAuthException: ${e.code} ${e.message}');
      return AuthResult.failure(_mapAuthError(e));
    } catch (e, stack) {
      debugPrint('Failed to sign in with Apple: $e\n$stack');
      return AuthResult.failure(
        'Falha ao entrar com Apple. Verifica a ligação e tenta novamente.',
      );
    }
  }

  /// Native Sign in with Apple (iOS) — nonce + [AppleAuthProvider.credentialWithIDToken].
  Future<AuthResult> _signInWithAppleNative() async {
    final rawNonce = generateAppleSignInRawNonce();
    final hashedNonce = sha256Nonce(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      return AuthResult.failure(
        'Não foi possível obter credencial Apple. Tenta novamente.',
      );
    }

    final fullName = AppleFullPersonName(
      givenName: appleCredential.givenName,
      familyName: appleCredential.familyName,
    );

    final credential = AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      fullName,
    );

    final userCredential = await _signInOrLink(credential);
    await _updateAppleDisplayName(userCredential.user, appleCredential);
    await _saveUserToFirestore(userCredential.user);
    return AuthResult.success(userId: userCredential.user?.uid);
  }

  /// OAuth web flow (Android) — uses Firebase handler:
  /// https://turnwise-tcg.firebaseapp.com/__/auth/handler
  Future<AuthResult> _signInWithAppleOAuthProvider() async {
    final appleProvider = AppleAuthProvider()..addScope('email');
    appleProvider.setCustomParameters({'locale': 'pt'});

    final userCredential = await _signInOrLinkWithProvider(appleProvider);
    await _saveUserToFirestore(userCredential.user);
    return AuthResult.success(userId: userCredential.user?.uid);
  }

  Future<UserCredential> _signInOrLink(AuthCredential credential) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      return currentUser.linkWithCredential(credential);
    }
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> _signInOrLinkWithProvider(
    AuthProvider provider,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      return currentUser.linkWithProvider(provider);
    }
    return _auth.signInWithProvider(provider);
  }

  Future<void> _updateAppleDisplayName(
    User? user,
    AuthorizationCredentialAppleID appleCredential,
  ) async {
    if (user == null) return;
    if (user.displayName != null && user.displayName!.isNotEmpty) return;

    final given = appleCredential.givenName;
    final family = appleCredential.familyName;
    if (given == null && family == null) return;

    final displayName = [given, family].whereType<String>().join(' ').trim();
    if (displayName.isEmpty) return;

    try {
      await user.updateDisplayName(displayName);
    } catch (e) {
      debugPrint('Apple display name update skipped: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
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
          if (user.email != null) 'email': user.email,
          if (user.displayName != null) 'displayName': user.displayName,
        });
      }
    } catch (e, stack) {
      debugPrint('Firestore profile sync skipped: $e\n$stack');
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Sem ligação à internet. Tenta novamente ou usa "Jogar sem conta".';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarda um momento e tenta de novo.';
      case 'invalid-credential':
      case 'user-disabled':
        return 'Credencial inválida ou conta desativada. Tenta outro método de entrada.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este email. Entra com o método original.';
      case 'credential-already-in-use':
        return 'Esta conta já está associada a outro utilizador.';
      case 'operation-not-allowed':
        return 'Este método de entrada não está ativo. Contacta o suporte.';
      case 'popup-closed-by-user':
        return 'Entrada cancelada.';
      default:
        debugPrint('Unhandled auth error code: ${e.code}');
        return 'Não foi possível iniciar sessão (${e.code}). Tenta novamente.';
    }
  }
}
