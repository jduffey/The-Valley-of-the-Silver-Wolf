import 'package:silver_wolf_engine/src/models/challenge_state.dart';
import 'package:silver_wolf_engine/src/models/combat_state.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';
import 'package:silver_wolf_engine/src/models/undo_snapshot.dart';

class GameState {
  static const Object _sentinel = Object();

  const GameState({
    required this.players,
    required this.schools,
    required this.currentPlayerIndex,
    required this.actionsRemaining,
    required this.currentTurnBonusActionsRemaining,
    required this.nextArrivalOrder,
    required this.pendingRoll,
    required this.eventLog,
    required this.winnerId,
    required this.gameOverReason,
    required this.challengeState,
    required this.combatState,
    required this.undoSnapshot,
  });

  final List<Player> players;
  final List<School> schools;
  final int currentPlayerIndex;
  final int actionsRemaining;
  final int currentTurnBonusActionsRemaining;
  final int nextArrivalOrder;
  final int? pendingRoll;
  final List<GameLogEntry> eventLog;
  final String? winnerId;
  final String? gameOverReason;
  final ChallengeState? challengeState;
  final CombatState? combatState;
  final UndoSnapshot? undoSnapshot;

  Player get currentPlayer => players[currentPlayerIndex];

  GameState copyWith({
    List<Player>? players,
    List<School>? schools,
    int? currentPlayerIndex,
    int? actionsRemaining,
    int? currentTurnBonusActionsRemaining,
    int? nextArrivalOrder,
    Object? pendingRoll = _sentinel,
    List<GameLogEntry>? eventLog,
    Object? winnerId = _sentinel,
    Object? gameOverReason = _sentinel,
    Object? challengeState = _sentinel,
    Object? combatState = _sentinel,
    Object? undoSnapshot = _sentinel,
  }) {
    return GameState(
      players: players ?? this.players,
      schools: schools ?? this.schools,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      actionsRemaining: actionsRemaining ?? this.actionsRemaining,
      currentTurnBonusActionsRemaining:
          currentTurnBonusActionsRemaining ??
          this.currentTurnBonusActionsRemaining,
      nextArrivalOrder: nextArrivalOrder ?? this.nextArrivalOrder,
      pendingRoll: pendingRoll == _sentinel
          ? this.pendingRoll
          : pendingRoll as int?,
      eventLog: eventLog ?? this.eventLog,
      winnerId: winnerId == _sentinel ? this.winnerId : winnerId as String?,
      gameOverReason: gameOverReason == _sentinel
          ? this.gameOverReason
          : gameOverReason as String?,
      challengeState: challengeState == _sentinel
          ? this.challengeState
          : challengeState as ChallengeState?,
      combatState: combatState == _sentinel
          ? this.combatState
          : combatState as CombatState?,
      undoSnapshot: undoSnapshot == _sentinel
          ? this.undoSnapshot
          : undoSnapshot as UndoSnapshot?,
    );
  }
}
