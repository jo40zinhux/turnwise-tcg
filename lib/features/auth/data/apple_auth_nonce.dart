import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically secure nonce for Sign in with Apple + Firebase.
///
/// See: https://firebase.google.com/docs/auth/ios/apple
String generateAppleSignInRawNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// SHA-256 hash of [input] as lowercase hex (sent to Apple in the sign-in request).
String sha256Nonce(String input) {
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString();
}
