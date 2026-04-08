import 'package:silver_wolf_engine/src/constants/game_constants.dart';
import 'package:silver_wolf_engine/src/data/starting_players.dart';
import 'package:silver_wolf_engine/src/data/track_details.dart';
import 'package:silver_wolf_engine/src/enums/location_type.dart';
import 'package:silver_wolf_engine/src/enums/school_status.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/models/location.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';
import 'package:silver_wolf_engine/src/models/technique_counts.dart';

class InitialStateFactory {
  const InitialStateFactory._();

  static GameState create() {
    final List<Player> players = createPlayers();

    return GameState(
      players: players,
      schools: createSchools(),
      currentPlayerIndex: 0,
      actionsRemaining: players.first.injured ? 1 : 2,
      currentTurnBonusActionsRemaining: 0,
      nextArrivalOrder: startingPlayers.length,
      pendingRoll: null,
      eventLog: const <GameLogEntry>[],
      winnerId: null,
      gameOverReason: null,
      challengeState: null,
      combatState: null,
      undoSnapshot: null,
    );
  }

  static List<Player> createPlayers() {
    return List<Player>.generate(startingPlayers.length, (int index) {
      final StartingPlayerSeed seed = startingPlayers[index];
      final Map<String, int> stats = playerStartingStats[seed.name]!;

      return Player(
        id: seed.id,
        name: seed.name,
        color: seed.color,
        position: seed.locationIndex,
        power: stats['power']!,
        stamina: stats['stamina']!,
        agility: stats['agility']!,
        chi: stats['chi']!,
        wit: stats['wit']!,
        reputation: initialReputation,
        techniques: const TechniqueCounts(),
        hitPoints: initialHitPoints,
        formPoints: initialFormPoints,
        bonusActionsNextTurn: 0,
        injured: false,
        arrivalOrder: index,
        alive: true,
      );
    });
  }

  static List<School> createSchools() {
    return trackDetails
        .where((Location location) => location.type == LocationType.town)
        .map(
          (Location location) => School(
            id: location.id,
            name: location.name,
            status: SchoolStatus.whole,
            saveProgress: 0,
            isCompletingSave: false,
            defenders: const <String>[],
          ),
        )
        .toList(growable: false);
  }
}
