import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';

class UndoSnapshot {
  const UndoSnapshot({
    required this.playerId,
    required this.players,
    required this.schools,
    required this.actionsRemaining,
    required this.currentTurnBonusActionsRemaining,
    required this.nextArrivalOrder,
    required this.eventLog,
    required this.pendingRoll,
  });

  final String playerId;
  final List<Player> players;
  final List<School> schools;
  final int actionsRemaining;
  final int currentTurnBonusActionsRemaining;
  final int nextArrivalOrder;
  final List<GameLogEntry> eventLog;
  final int? pendingRoll;
}
