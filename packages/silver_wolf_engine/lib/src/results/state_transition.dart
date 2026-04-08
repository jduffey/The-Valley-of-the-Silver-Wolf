import 'package:silver_wolf_engine/src/models/game_log_entry.dart';

class StateTransition {
  const StateTransition({
    this.logEntries = const <GameLogEntry>[],
    this.completedSchoolIds = const <String>[],
  });

  final List<GameLogEntry> logEntries;
  final List<String> completedSchoolIds;
}
