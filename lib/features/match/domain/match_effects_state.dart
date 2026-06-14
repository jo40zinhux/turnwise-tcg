import 'active_effect.dart';
import 'board_undo_entry.dart';
import 'checkup_reminder.dart';
import 'match_board_state.dart';
import 'match_resources_state.dart';

/// Effect + checkup runtime state carried by [MatchEngineState].
class MatchEffectsState {
  final List<ActiveEffect> activeEffects;
  final int turnNumber;
  final List<CheckupReminder> pendingCheckups;

  /// Whether the local player won the coin flip and goes first (match setup).
  final bool? playerWentFirst;

  final MatchResourcesState resources;

  final MatchBoardState board;

  /// LIFO snapshots for undoing board changes per action.
  final List<BoardUndoEntry> boardUndoStack;

  /// LIFO snapshots for manual board panel edits (flags, slots).
  final List<MatchBoardState> manualBoardUndoStack;

  /// True while the opponent is taking their turn (between your end step and next turn).
  final bool isOpponentTurn;

  const MatchEffectsState({
    this.activeEffects = const [],
    this.turnNumber = 1,
    this.pendingCheckups = const [],
    this.playerWentFirst,
    this.resources = const MatchResourcesState(),
    this.board = const MatchBoardState(),
    this.boardUndoStack = const [],
    this.manualBoardUndoStack = const [],
    this.isOpponentTurn = false,
  });

  static const maxManualBoardUndoDepth = 10;

  bool get hasManualBoardUndo => manualBoardUndoStack.isNotEmpty;

  static MatchEffectsState initialForGame(String gameId) {
    return MatchEffectsState(
      resources: MatchResourcesState.initialForGame(gameId),
      board: MatchBoardState.initialForGame(gameId),
    );
  }

  static const empty = MatchEffectsState();

  List<ActiveEffect> get nonExpiredEffects =>
      activeEffects.where((effect) => !effect.isExpired).toList();

  Set<String> get lockedActionIds {
    final locks = <String>{};
    for (final effect in nonExpiredEffects) {
      if (effect.type.storageKey == 'action_lock' ||
          effect.type.storageKey == 'attack_restriction') {
        locks.addAll(effect.lockedActionIds);
      }
    }
    return locks;
  }

  MatchEffectsState copyWith({
    List<ActiveEffect>? activeEffects,
    int? turnNumber,
    List<CheckupReminder>? pendingCheckups,
    bool? playerWentFirst,
    MatchResourcesState? resources,
    MatchBoardState? board,
    List<BoardUndoEntry>? boardUndoStack,
    List<MatchBoardState>? manualBoardUndoStack,
    bool? isOpponentTurn,
    bool clearPlayerWentFirst = false,
    bool clearCheckups = false,
  }) {
    return MatchEffectsState(
      activeEffects: activeEffects ?? this.activeEffects,
      turnNumber: turnNumber ?? this.turnNumber,
      pendingCheckups:
          clearCheckups ? const [] : (pendingCheckups ?? this.pendingCheckups),
      playerWentFirst: clearPlayerWentFirst
          ? null
          : (playerWentFirst ?? this.playerWentFirst),
      resources: resources ?? this.resources,
      board: board ?? this.board,
      boardUndoStack: boardUndoStack ?? this.boardUndoStack,
      manualBoardUndoStack:
          manualBoardUndoStack ?? this.manualBoardUndoStack,
      isOpponentTurn: isOpponentTurn ?? this.isOpponentTurn,
    );
  }

  MatchEffectsState pushManualBoardUndo(MatchBoardState snapshot) {
    final next = [...manualBoardUndoStack, snapshot];
    if (next.length > maxManualBoardUndoDepth) {
      next.removeAt(0);
    }
    return copyWith(manualBoardUndoStack: next);
  }

  MatchEffectsState popManualBoardUndo() {
    if (manualBoardUndoStack.isEmpty) return this;
    final previous = manualBoardUndoStack.last;
    return copyWith(
      board: previous,
      manualBoardUndoStack: manualBoardUndoStack.sublist(
        0,
        manualBoardUndoStack.length - 1,
      ),
    );
  }

  MatchEffectsState pushBoardUndo(BoardUndoEntry entry) {
    return copyWith(boardUndoStack: [...boardUndoStack, entry]);
  }

  MatchEffectsState popBoardUndoFor(String actionId) {
    for (var i = boardUndoStack.length - 1; i >= 0; i--) {
      if (boardUndoStack[i].actionId == actionId) {
        final entry = boardUndoStack[i];
        final nextStack = [...boardUndoStack]..removeAt(i);
        return copyWith(board: entry.board, boardUndoStack: nextStack);
      }
    }
    return this;
  }

  factory MatchEffectsState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MatchEffectsState.empty;

    return MatchEffectsState(
      activeEffects: (json['activeEffects'] as List<dynamic>?)
              ?.map((e) => ActiveEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      turnNumber: json['turnNumber'] as int? ?? 1,
      pendingCheckups: (json['pendingCheckups'] as List<dynamic>?)
              ?.map((e) => CheckupReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      playerWentFirst: json['playerWentFirst'] as bool?,
      resources: MatchResourcesState.fromJson(
        json['resources'] as Map<String, dynamic>?,
      ),
      board: MatchBoardState.fromJson(json['board'] as Map<String, dynamic>?),
      boardUndoStack: (json['boardUndoStack'] as List<dynamic>?)
              ?.map((e) => BoardUndoEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      manualBoardUndoStack: (json['manualBoardUndoStack'] as List<dynamic>?)
              ?.map(
                (e) => MatchBoardState.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      isOpponentTurn: json['isOpponentTurn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeEffects': activeEffects.map((e) => e.toJson()).toList(),
      'turnNumber': turnNumber,
      'pendingCheckups': pendingCheckups.map((e) => e.toJson()).toList(),
      if (playerWentFirst != null) 'playerWentFirst': playerWentFirst,
      'resources': resources.toJson(),
      'board': board.toJson(),
      'boardUndoStack': boardUndoStack.map((e) => e.toJson()).toList(),
      'manualBoardUndoStack':
          manualBoardUndoStack.map((e) => e.toJson()).toList(),
      'isOpponentTurn': isOpponentTurn,
    };
  }
}
