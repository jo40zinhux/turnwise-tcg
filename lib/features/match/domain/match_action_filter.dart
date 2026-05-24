import 'action_rule.dart';

/// Filters declarative actions for the active turn phase.
abstract final class MatchActionFilter {
  static List<ActionRule> forPhase(
    List<ActionRule> actions,
    String phaseId,
  ) {
    return actions
        .where((action) => action.allowedPhases.contains(phaseId))
        .toList();
  }

  static String? actionDisplayName(
    List<ActionRule> actions,
    String actionId,
  ) {
    for (final action in actions) {
      if (action.id == actionId) return action.name;
    }
    return null;
  }

  static List<String> resolveActionLabels(
    List<ActionRule> actions,
    Iterable<String> actionIds,
  ) {
    return actionIds
        .map((id) => actionDisplayName(actions, id) ?? id)
        .toList();
  }
}
