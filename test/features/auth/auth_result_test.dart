import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/auth/domain/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('success state', () {
      const result = AuthResult.success();
      expect(result.isSuccess, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.message, isNull);
    });

    test('cancelled state', () {
      const result = AuthResult.cancelled();
      expect(result.isSuccess, isFalse);
      expect(result.isCancelled, isTrue);
    });

    test('failure carries message', () {
      const result = AuthResult.failure('Sem internet');
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Sem internet');
    });
  });
}
