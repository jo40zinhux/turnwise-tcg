// lib/features/match/domain/validation_rule.dart

class ValidationRule {
  final String id;
  final String type;
  final Map<String, dynamic> params;
  final String errorMessage;

  const ValidationRule({
    required this.id,
    required this.type,
    required this.params,
    required this.errorMessage,
  });

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      id: json['id'] as String,
      type: json['type'] as String,
      params: json['params'] as Map<String, dynamic>? ?? {},
      errorMessage: json['errorMessage'] as String,
    );
  }
}
