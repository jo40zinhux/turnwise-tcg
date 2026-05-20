enum AuthStatus { success, failure, cancelled }

class AuthResult {
  final AuthStatus status;
  final String? message;

  const AuthResult._(this.status, [this.message]);

  const AuthResult.success() : this._(AuthStatus.success);

  const AuthResult.cancelled() : this._(AuthStatus.cancelled);

  const AuthResult.failure(String message) : this._(AuthStatus.failure, message);

  bool get isSuccess => status == AuthStatus.success;
  bool get isCancelled => status == AuthStatus.cancelled;
}
