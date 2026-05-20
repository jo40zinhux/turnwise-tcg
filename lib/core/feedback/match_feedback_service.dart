import 'haptics_player.dart';
import '../../features/settings/domain/feedback_preferences.dart';

/// Centralised haptic (and, in the future, audio) feedback for match events.
///
/// Respects [FeedbackPreferences] so users can disable haptics globally
/// without touching call sites. Sound hooks are kept as stubs until audio
/// assets are bundled — adding them later does not change any call site.
class MatchFeedbackService {
  final HapticsPlayer _haptics;
  final FeedbackPreferences Function() _preferences;

  const MatchFeedbackService({
    required HapticsPlayer haptics,
    required FeedbackPreferences Function() preferencesProvider,
  })  : _haptics = haptics,
        _preferences = preferencesProvider;

  bool get _hapticOn => _preferences().hapticEnabled;

  /// Selection-tick: ação válida usada.
  Future<void> actionUsed() async {
    if (!_hapticOn) return;
    await _haptics.selection();
  }

  /// Light impact + sem snackbar: ação esgotada/indisponível.
  Future<void> actionUnavailable() async {
    if (!_hapticOn) return;
    await _haptics.light();
  }

  /// Heavy impact: erro de regra ("fase errada", "limite atingido").
  Future<void> actionInvalid() async {
    if (!_hapticOn) return;
    await _haptics.heavy();
  }

  /// Selection-tick: avanço de fase.
  Future<void> phaseAdvance() async {
    if (!_hapticOn) return;
    await _haptics.selection();
  }

  /// Medium impact: fim de turno completo.
  Future<void> turnEnd() async {
    if (!_hapticOn) return;
    await _haptics.medium();
  }

  /// Heavy impact: conquista desbloqueada (celebração).
  Future<void> achievementUnlocked() async {
    if (!_hapticOn) return;
    await _haptics.heavy();
  }

  /// Light impact: timer entrou em aviso (≤5 min).
  Future<void> timerWarning() async {
    if (!_hapticOn) return;
    await _haptics.light();
  }

  /// Heavy impact: timer expirou.
  Future<void> timerExpired() async {
    if (!_hapticOn) return;
    await _haptics.heavy();
  }
}
