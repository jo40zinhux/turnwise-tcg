enum AuthStatus { success, failure, cancelled }

class AuthResult {
  final AuthStatus status;
  final String? message;
  final String? userId;

  const AuthResult._(this.status, [this.message, this.userId]);

  const AuthResult.success({String? userId})
      : this._(AuthStatus.success, null, userId);

  const AuthResult.cancelled() : this._(AuthStatus.cancelled);

  const AuthResult.failure(String message) : this._(AuthStatus.failure, message);

  bool get isSuccess => status == AuthStatus.success;
  bool get isCancelled => status == AuthStatus.cancelled;
}
