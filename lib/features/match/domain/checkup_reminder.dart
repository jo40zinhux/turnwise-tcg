/// Pending reminder shown to the player (between turns, triggers, etc.).
class CheckupReminder {
  final String id;
  final String title;
  final String message;
  final List<String> relatedEffectIds;

  const CheckupReminder({
    required this.id,
    required this.title,
    required this.message,
    this.relatedEffectIds = const [],
  });

  factory CheckupReminder.fromJson(Map<String, dynamic> json) {
    return CheckupReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedEffectIds: List<String>.from(json['relatedEffectIds'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      if (relatedEffectIds.isNotEmpty) 'relatedEffectIds': relatedEffectIds,
    };
  }
}
