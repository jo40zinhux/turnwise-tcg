import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/auth/data/apple_auth_nonce.dart';

void main() {
  group('apple_auth_nonce', () {
    test('generateAppleSignInRawNonce produces requested length', () {
      expect(generateAppleSignInRawNonce(16).length, 16);
      expect(generateAppleSignInRawNonce().length, 32);
    });

    test('sha256Nonce is stable hex digest', () {
      final hash = sha256Nonce('test-nonce');
      expect(hash, sha256Nonce('test-nonce'));
      expect(hash.length, 64);
    });
  });
}
