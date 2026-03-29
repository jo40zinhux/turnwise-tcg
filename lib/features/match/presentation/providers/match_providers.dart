import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/match_phase.dart';

class MatchStateNotifier extends StateNotifier<MatchPhase> {
  MatchStateNotifier() : super(MatchPhase.draw);

  // Friendly error message for UI
  String? currentFeedback;

  void nextPhase() {
    switch (state) {
      case MatchPhase.draw:
        state = MatchPhase.main1;
        currentFeedback = null;
        break;
      case MatchPhase.main1:
        state = MatchPhase.combat;
        currentFeedback = null;
        break;
      case MatchPhase.combat:
        state = MatchPhase.main2;
        currentFeedback = null;
        break;
      case MatchPhase.main2:
        state = MatchPhase.end;
        currentFeedback = null;
        break;
      case MatchPhase.end:
        state = MatchPhase.draw;
        currentFeedback = "Novo turno iniciado! Não esqueça de desvirar suas cartas.";
        break;
    }
  }

  void attemptInvalidAction(String actionName) {
    if (state == MatchPhase.draw) {
      currentFeedback = "Você não pode $actionName durante a Draw Phase. Primeiro compre sua carta!";
    } else if (state == MatchPhase.combat && actionName.contains('baixar carta')) {
      currentFeedback = "Você deve focar no combate agora. Cartas só podem ser jogadas nas Main Phases.";
    } else if (state == MatchPhase.end) {
      currentFeedback = "O turno está acabando. Ações de $actionName não são permitidas agora.";
    } else {
      currentFeedback = "Ação de $actionName bloqueada nesta fase do jogo. Revise as regras do seu TCG.";
    }
    // Forces UI to update with error message
    state = state; 
  }

  void clearFeedback() {
    currentFeedback = null;
    state = state;
  }
}

final matchStateProvider = StateNotifierProvider<MatchStateNotifier, MatchPhase>((ref) {
  return MatchStateNotifier();
});
