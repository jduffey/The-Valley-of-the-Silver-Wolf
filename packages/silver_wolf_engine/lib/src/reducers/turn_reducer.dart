import 'dart:math';

import 'package:silver_wolf_engine/src/data/track_details.dart';
import 'package:silver_wolf_engine/src/enums/location_type.dart';
import 'package:silver_wolf_engine/src/enums/school_status.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/models/school.dart';
import 'package:silver_wolf_engine/src/models/undo_snapshot.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';
import 'package:silver_wolf_engine/src/results/command_result.dart';
import 'package:silver_wolf_engine/src/results/state_transition.dart';
import 'package:silver_wolf_engine/src/rules/player_rules.dart';
import 'package:silver_wolf_engine/src/rules/school_rules.dart';
import 'package:silver_wolf_engine/src/rules/silver_wolf_rules.dart';
import 'package:silver_wolf_engine/src/rules/turn_rules.dart';

class TurnReducer {
  const TurnReducer._();

  static CommandResult travel(
    GameState state,
    int direction,
    Randomizer randomizer,
  ) {
    if (!_canSpendAction(state)) {
      return CommandResult.unchanged(state);
    }

    final UndoSnapshot snapshot = _createUndoSnapshot(state);
    final List<Player> updatedPlayers = clonePlayers(state.players);
    final Player currentPlayer = updatedPlayers[state.currentPlayerIndex];

    updatedPlayers[state.currentPlayerIndex] = currentPlayer.copyWith(
      position: normalizeIndex(
        currentPlayer.position + direction,
        trackDetails.length,
      ),
      arrivalOrder: state.nextArrivalOrder,
    );

    return _finalizeAction(
      state.copyWith(
        nextArrivalOrder: state.nextArrivalOrder + 1,
        undoSnapshot: snapshot,
      ),
      updatedPlayers: updatedPlayers,
      updatedSchools: cloneSchools(state.schools),
      randomizer: randomizer,
    );
  }

  static CommandResult passTurn(GameState state, Randomizer randomizer) {
    if (!state.currentPlayer.alive) {
      return CommandResult.unchanged(state);
    }

    return _resolveTurnEnd(
      state.copyWith(pendingRoll: null, undoSnapshot: null),
      randomizer,
    );
  }

  static CommandResult healCurrentPlayer(
    GameState state,
    Randomizer randomizer,
  ) {
    final Player currentPlayer = state.currentPlayer;

    if (!_canSpendAction(state) ||
        !currentPlayer.injured ||
        trackDetails[currentPlayer.position].type != LocationType.town) {
      return CommandResult.unchanged(state);
    }

    final UndoSnapshot snapshot = _createUndoSnapshot(state);
    final List<Player> updatedPlayers = clonePlayers(state.players);
    updatedPlayers[state.currentPlayerIndex] = healPlayer(currentPlayer);

    return _finalizeAction(
      state.copyWith(undoSnapshot: snapshot),
      updatedPlayers: updatedPlayers,
      updatedSchools: cloneSchools(state.schools),
      randomizer: randomizer,
      logEntries: <GameLogEntry>[
        GameLogEntry(
          message:
              '${getPlayerDisplayName(currentPlayer)} heals at ${trackDetails[currentPlayer.position].name}.',
        ),
      ],
    );
  }

  static CommandResult saveCurrentSchool(
    GameState state,
    Randomizer randomizer,
  ) {
    final Player currentPlayer = state.currentPlayer;
    if (!_canSpendAction(state)) {
      return CommandResult.unchanged(state);
    }

    final String locationId = trackDetails[currentPlayer.position].id;
    final School? currentSchool = getSchoolById(state.schools, locationId);

    if (currentSchool == null ||
        currentSchool.status != SchoolStatus.sieged ||
        currentSchool.isCompletingSave) {
      return CommandResult.unchanged(state);
    }

    final UndoSnapshot snapshot = _createUndoSnapshot(state);
    final List<Player> updatedPlayers = clonePlayers(state.players);
    final List<School> updatedSchools = cloneSchools(state.schools);
    final int schoolIndex = updatedSchools.indexWhere(
      (School school) => school.id == locationId,
    );
    final School school = updatedSchools[schoolIndex];
    final int nextProgress = min(3, school.saveProgress + 1);
    final List<String> defenders = school.defenders.contains(currentPlayer.id)
        ? school.defenders
        : <String>[...school.defenders, currentPlayer.id];

    updatedSchools[schoolIndex] = school.copyWith(
      saveProgress: nextProgress,
      defenders: defenders,
    );

    if (nextProgress >= 3) {
      final List<String> defenderNames = updatedPlayers
          .where((Player player) => defenders.contains(player.id))
          .map(getPlayerDisplayName)
          .toList(growable: false);

      for (int index = 0; index < updatedPlayers.length; index += 1) {
        if (defenders.contains(updatedPlayers[index].id)) {
          updatedPlayers[index] = raiseReputation(updatedPlayers[index]);
        }
      }

      updatedSchools[schoolIndex] = updatedSchools[schoolIndex].copyWith(
        status: SchoolStatus.whole,
        isCompletingSave: true,
      );

      final List<GameLogEntry> logEntries = <GameLogEntry>[
        GameLogEntry(
          message:
              '${formatNameList(defenderNames)} saved ${getSchoolEventLabel(updatedSchools[schoolIndex])}!',
        ),
      ];

      return _finalizeAction(
        state.copyWith(undoSnapshot: snapshot),
        updatedPlayers: updatedPlayers,
        updatedSchools: updatedSchools,
        randomizer: randomizer,
        logEntries: logEntries,
        transition: StateTransition(
          logEntries: logEntries,
          completedSchoolIds: <String>[updatedSchools[schoolIndex].id],
        ),
      );
    }

    return _finalizeAction(
      state.copyWith(undoSnapshot: snapshot),
      updatedPlayers: updatedPlayers,
      updatedSchools: updatedSchools,
      randomizer: randomizer,
      logEntries: <GameLogEntry>[
        GameLogEntry(
          message:
              '${getPlayerDisplayName(currentPlayer)} defends ${getSchoolEventLabel(updatedSchools[schoolIndex])}. '
              'Progress is now $nextProgress/3.',
        ),
      ],
    );
  }

  static CommandResult challengeSilverWolf(
    GameState state,
    Randomizer randomizer,
  ) {
    final Player currentPlayer = state.currentPlayer;
    if (!_canSpendAction(state) ||
        state.pendingRoll != null ||
        !canChallengeSilverWolf(currentPlayer)) {
      return CommandResult.unchanged(state);
    }

    final List<Player> updatedPlayers = clonePlayers(state.players);
    final List<School> updatedSchools = cloneSchools(state.schools);
    final Player challenger = updatedPlayers[state.currentPlayerIndex];
    final int wolfStrength =
        getSilverWolfStrength(updatedSchools) + rollDie(randomizer);
    final int challengerStrength = buildCombatScore(challenger, randomizer);
    final List<GameLogEntry> logEntries = <GameLogEntry>[
      GameLogEntry(
        message:
            '${getPlayerDisplayName(challenger)} challenges the Silver Wolf with Power ${challenger.power}, '
            'Stamina ${challenger.stamina}, Agility ${challenger.agility}, Chi ${challenger.chi}, and Wit ${challenger.wit}.',
      ),
    ];

    if (challengerStrength > wolfStrength) {
      logEntries.add(
        GameLogEntry(
          message:
              '${getPlayerDisplayName(challenger)} defeats the Silver Wolf in combat and wins Valley of the Silver Wolf.',
        ),
      );

      final List<GameLogEntry> nextLog = <GameLogEntry>[
        ...logEntries,
        ...state.eventLog,
      ];
      return CommandResult(
        state: state.copyWith(
          players: updatedPlayers,
          schools: updatedSchools,
          actionsRemaining: 0,
          currentTurnBonusActionsRemaining: 0,
          winnerId: challenger.id,
          eventLog: nextLog,
          pendingRoll: null,
          undoSnapshot: null,
        ),
        transition: StateTransition(logEntries: logEntries),
      );
    }

    updatedPlayers[state.currentPlayerIndex] = challenger.copyWith(
      alive: false,
    );
    logEntries.add(
      GameLogEntry(
        message:
            'The Silver Wolf kills ${getPlayerDisplayName(challenger)}. His kung fu was too strong.',
      ),
    );

    return _finalizeAction(
      state.copyWith(undoSnapshot: null),
      updatedPlayers: updatedPlayers,
      updatedSchools: updatedSchools,
      randomizer: randomizer,
      logEntries: logEntries,
    );
  }

  static CommandResult undoLastAction(GameState state) {
    final UndoSnapshot? snapshot = state.undoSnapshot;
    if (!state.currentPlayer.alive ||
        snapshot == null ||
        snapshot.playerId != state.currentPlayer.id ||
        state.challengeState != null ||
        state.combatState != null) {
      return CommandResult.unchanged(state);
    }

    return CommandResult(
      state: state.copyWith(
        players: clonePlayers(snapshot.players),
        schools: cloneSchools(snapshot.schools),
        actionsRemaining: snapshot.actionsRemaining,
        currentTurnBonusActionsRemaining:
            snapshot.currentTurnBonusActionsRemaining,
        nextArrivalOrder: snapshot.nextArrivalOrder,
        eventLog: List<GameLogEntry>.from(snapshot.eventLog),
        pendingRoll: snapshot.pendingRoll,
        undoSnapshot: null,
      ),
    );
  }

  static CommandResult clearCompletedSchoolRescue(
    GameState state,
    String schoolId,
  ) {
    final int schoolIndex = state.schools.indexWhere(
      (School school) => school.id == schoolId,
    );
    if (schoolIndex == -1 || !state.schools[schoolIndex].isCompletingSave) {
      return CommandResult.unchanged(state);
    }

    final List<School> updatedSchools = cloneSchools(state.schools);
    updatedSchools[schoolIndex] = updatedSchools[schoolIndex].copyWith(
      saveProgress: 0,
      isCompletingSave: false,
    );

    return CommandResult(state: state.copyWith(schools: updatedSchools));
  }

  static bool _canSpendAction(GameState state) {
    return state.currentPlayer.alive && state.actionsRemaining > 0;
  }

  static UndoSnapshot _createUndoSnapshot(GameState state) {
    return UndoSnapshot(
      playerId: state.currentPlayer.id,
      players: clonePlayers(state.players),
      schools: cloneSchools(state.schools),
      actionsRemaining: state.actionsRemaining,
      currentTurnBonusActionsRemaining: state.currentTurnBonusActionsRemaining,
      nextArrivalOrder: state.nextArrivalOrder,
      eventLog: List<GameLogEntry>.from(state.eventLog),
      pendingRoll: state.pendingRoll,
    );
  }

  static CommandResult _finalizeAction(
    GameState state, {
    required List<Player> updatedPlayers,
    required List<School> updatedSchools,
    required Randomizer randomizer,
    List<GameLogEntry> logEntries = const <GameLogEntry>[],
    int refundedActions = 0,
    StateTransition? transition,
  }) {
    final List<GameLogEntry> nextLog = <GameLogEntry>[
      ...logEntries,
      ...state.eventLog,
    ];
    final GameState baseState = state.copyWith(
      players: updatedPlayers,
      schools: updatedSchools,
      eventLog: nextLog,
      pendingRoll: null,
    );
    final int nextActionsRemaining = max(
      0,
      state.actionsRemaining - 1 + refundedActions,
    );
    final int nextBonusActionsRemaining = max(
      0,
      state.currentTurnBonusActionsRemaining - 1,
    );
    final StateTransition effectiveTransition =
        transition ?? StateTransition(logEntries: logEntries);

    if (nextActionsRemaining > 0) {
      return CommandResult(
        state: baseState.copyWith(
          actionsRemaining: nextActionsRemaining,
          currentTurnBonusActionsRemaining: nextBonusActionsRemaining,
        ),
        transition: effectiveTransition,
      );
    }

    final CommandResult turnEndResult = _resolveTurnEnd(baseState, randomizer);
    return CommandResult(
      state: turnEndResult.state,
      transition: StateTransition(
        logEntries: <GameLogEntry>[
          ...effectiveTransition.logEntries,
          ...turnEndResult.transition.logEntries,
        ],
        completedSchoolIds: effectiveTransition.completedSchoolIds,
      ),
    );
  }

  static CommandResult _resolveTurnEnd(GameState state, Randomizer randomizer) {
    List<Player> updatedPlayers = clonePlayers(state.players);
    List<School> updatedSchools = cloneSchools(state.schools);
    final List<GameLogEntry> turnLogs = <GameLogEntry>[];

    if (getAlivePlayers(updatedPlayers).isEmpty) {
      return CommandResult(
        state: state.copyWith(
          actionsRemaining: 0,
          currentTurnBonusActionsRemaining: 0,
          pendingRoll: null,
          gameOverReason:
              'Every challenger is dead. The Silver Wolf remains undefeated.',
          undoSnapshot: null,
        ),
      );
    }

    final int destroyedSchoolCountBefore = updatedSchools
        .where((School school) => school.status == SchoolStatus.destroyed)
        .length;
    final SilverWolfAdvanceResult advanceResult = advanceSilverWolf(
      updatedSchools,
      randomizer,
    );
    updatedSchools = advanceResult.schools;
    turnLogs.addAll(advanceResult.logEntries);
    final int destroyedSchoolCountAfter = updatedSchools
        .where((School school) => school.status == SchoolStatus.destroyed)
        .length;
    final Set<String> previouslyDestroyedIds = state.schools
        .where((School school) => school.status == SchoolStatus.destroyed)
        .map((School school) => school.id)
        .toSet();
    final List<String> newlyDestroyedSchoolIds = updatedSchools
        .where(
          (School school) =>
              school.status == SchoolStatus.destroyed &&
              !previouslyDestroyedIds.contains(school.id),
        )
        .map((School school) => school.id)
        .toList(growable: false);

    if (destroyedSchoolCountAfter > destroyedSchoolCountBefore) {
      final int reputationLoss =
          destroyedSchoolCountAfter - destroyedSchoolCountBefore;
      updatedPlayers = updatedPlayers
          .map((Player player) => lowerReputation(player, reputationLoss))
          .toList(growable: false);
    }

    if (newlyDestroyedSchoolIds.isNotEmpty) {
      final List<Player> injuredPlayers = <Player>[];
      updatedPlayers = updatedPlayers
          .map((Player player) {
            final String currentLocationId = trackDetails[player.position].id;
            if (!player.alive ||
                player.injured ||
                !newlyDestroyedSchoolIds.contains(currentLocationId)) {
              return player;
            }
            final Player injuredPlayer = injurePlayer(player);
            injuredPlayers.add(injuredPlayer);
            return injuredPlayer;
          })
          .toList(growable: false);

      for (final Player player in injuredPlayers) {
        final School destroyedSchool = getSchoolById(
          updatedSchools,
          trackDetails[player.position].id,
        )!;
        turnLogs.add(
          GameLogEntry(
            message:
                '${getPlayerDisplayName(player)} is caught in the fall of ${getSchoolEventLabel(destroyedSchool)} and becomes Injured.',
          ),
        );
      }
    }

    final List<GameLogEntry> nextLog = <GameLogEntry>[
      ...turnLogs,
      ...state.eventLog,
    ];

    if (!advanceResult.schoolsStillStanding) {
      return CommandResult(
        state: state.copyWith(
          players: updatedPlayers,
          schools: updatedSchools,
          actionsRemaining: 0,
          currentTurnBonusActionsRemaining: 0,
          pendingRoll: null,
          eventLog: nextLog,
          gameOverReason:
              'The Silver Wolf destroyed all five schools. The valley was not protected.',
          undoSnapshot: null,
        ),
        transition: StateTransition(logEntries: turnLogs),
      );
    }

    final List<Player> aliveAfterTurn = getAlivePlayers(updatedPlayers);
    if (aliveAfterTurn.isEmpty) {
      return CommandResult(
        state: state.copyWith(
          players: updatedPlayers,
          schools: updatedSchools,
          actionsRemaining: 0,
          currentTurnBonusActionsRemaining: 0,
          pendingRoll: null,
          eventLog: nextLog,
          gameOverReason:
              'Every challenger is dead. The Silver Wolf remains undefeated.',
          undoSnapshot: null,
        ),
        transition: StateTransition(logEntries: turnLogs),
      );
    }

    final int nextPlayerIndex = getNextLivingIndex(
      updatedPlayers,
      state.currentPlayerIndex,
    );
    final ({List<Player> players, int actions, int consumedBonusActions})
    preparedTurn = consumeNextTurnActionBonus(updatedPlayers, nextPlayerIndex);

    return CommandResult(
      state: state.copyWith(
        players: preparedTurn.players,
        schools: updatedSchools,
        currentPlayerIndex: nextPlayerIndex,
        actionsRemaining: preparedTurn.actions,
        currentTurnBonusActionsRemaining: preparedTurn.consumedBonusActions,
        pendingRoll: null,
        eventLog: nextLog,
        undoSnapshot: null,
      ),
      transition: StateTransition(logEntries: turnLogs),
    );
  }
}
