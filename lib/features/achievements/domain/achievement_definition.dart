import 'achievement_metric.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int target;
  final String iconCode;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.iconCode,
  });

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) {
    return AchievementDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      metric: AchievementMetric.fromStorageKey(json['metric'] as String?) ??
          AchievementMetric.matchCount,
      target: json['target'] as int? ?? 1,
      iconCode: json['iconCode'] as String? ?? 'emoji_events_outlined',
    );
  }
}
