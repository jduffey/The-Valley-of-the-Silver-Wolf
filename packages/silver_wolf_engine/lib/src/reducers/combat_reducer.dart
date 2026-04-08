import 'dart:math';

import 'package:collection/collection.dart';
import 'package:silver_wolf_engine/src/enums/combat_mode.dart';
import 'package:silver_wolf_engine/src/enums/combat_phase.dart';
import 'package:silver_wolf_engine/src/factories/combat_state_factory.dart';
import 'package:silver_wolf_engine/src/models/challenge_state.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';
import 'package:silver_wolf_engine/src/models/combat_resolution_summary.dart';
import 'package:silver_wolf_engine/src/models/combat_state.dart';
import 'package:silver_wolf_engine/src/models/combatant_state.dart';
import 'package:silver_wolf_engine/src/models/game_log_entry.dart';
import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';
import 'package:silver_wolf_engine/src/reducers/turn_reducer.dart';
import 'package:silver_wolf_engine/src/results/command_result.dart';
import 'package:silver_wolf_engine/src/results/state_transition.dart';
import 'package:silver_wolf_engine/src/rules/combat_rules.dart';
import 'package:silver_wolf_engine/src/rules/player_rules.dart';

class CombatReducer {
  const CombatReducer._();

  static CommandResult openChallenge(GameState state) {
    if (_isInteractionLocked(state) ||
        !state.currentPlayer.alive ||
        state.actionsRemaining < 1) {
      return CommandResult.unchanged(state);
    }

    final List<Player> rivals = getRivalsAtPosition(
      state.players,
      state.currentPlayerIndex,
    );
    if (rivals.isEmpty) {
      return CommandResult.unchanged(state);
    }

    return CommandResult(
      state: state.copyWith(
        challengeState: ChallengeState(
          challengerId: state.currentPlayer.id,
          opponentIds: rivals
              .map((Player player) => player.id)
              .toList(growable: false),
          targetId: rivals.length == 1 ? rivals.first.id : null,
        ),
        undoSnapshot: null,
      ),
    );
  }

  static CommandResult chooseChallengeTarget(GameState state, String targetId) {
    final ChallengeState? challengeState = state.challengeState;
    if (challengeState == null ||
        !challengeState.opponentIds.contains(targetId)) {
      return CommandResult.unchanged(state);
    }

    return CommandResult(
      state: state.copyWith(
        challengeState: challengeState.copyWith(targetId: targetId),
      ),
    );
  }

  static CommandResult acceptChallenge(GameState state, Randomizer randomizer) {
    final ChallengeState? challengeState = state.challengeState;
    if (challengeState == null ||
        challengeState.targetId == null ||
        state.currentPlayer.id != challengeState.challengerId ||
        state.combatState != null) {
      return CommandResult.unchanged(state);
    }

    final bool shouldBankAction = state.actionsRemaining > 1;
    final List<Player> updatedPlayers = clonePlayers(state.players);
    final List<Player> playersAfterBonus = shouldBankAction
        ? grantSingleUseActionForNextTurn(
            updatedPlayers,
            challengeState.challengerId,
          )
        : updatedPlayers;
    final CombatState? combatState = CombatStateFactory.create(
      playersAfterBonus,
      challengeState.challengerId,
      challengeState.targetId!,
      randomizer,
    );

    if (combatState == null) {
      return CommandResult.unchanged(state);
    }

    final GameState baseState = state.copyWith(
      players: playersAfterBonus,
      pendingRoll: null,
      challengeState: null,
      combatState: combatState,
      undoSnapshot: null,
    );

    if (shouldBankAction) {
      return TurnReducer.resolveTurnEnd(baseState, randomizer);
    }

    return CommandResult(
      state: baseState.copyWith(
        actionsRemaining: max(0, state.actionsRemaining - 1),
        currentTurnBonusActionsRemaining: max(
          0,
          state.currentTurnBonusActionsRemaining - 1,
        ),
      ),
    );
  }

  static CommandResult declineChallenge(
    GameState state,
    Randomizer randomizer,
  ) {
    final ChallengeState? challengeState = state.challengeState;
    if (challengeState == null ||
        challengeState.targetId == null ||
        state.currentPlayer.id != challengeState.challengerId) {
      return CommandResult.unchanged(state);
    }

    final Player? challenger = state.players
        .where((Player player) => player.id == challengeState.challengerId)
        .firstOrNull;
    final Player? target = state.players
        .where((Player player) => player.id == challengeState.targetId)
        .firstOrNull;
    final List<Player> updatedPlayers = clonePlayers(state.players);
    final int targetIndex = updatedPlayers.indexWhere(
      (Player player) => player.id == challengeState.targetId,
    );

    if (targetIndex == -1) {
      return CommandResult.unchanged(state);
    }

    updatedPlayers[targetIndex] = lowerReputation(updatedPlayers[targetIndex]);
    final bool shouldBankAction = state.actionsRemaining > 1;
    final List<Player> playersAfterBonus = shouldBankAction
        ? grantSingleUseActionForNextTurn(
            updatedPlayers,
            challengeState.challengerId,
          )
        : updatedPlayers;
    final List<GameLogEntry> logEntries = challenger != null && target != null
        ? <GameLogEntry>[
            GameLogEntry(
              message:
                  "${getPlayerDisplayName(target)} declines ${getPlayerDisplayName(challenger)}'s challenge and loses 1 Reputation.",
            ),
          ]
        : const <GameLogEntry>[];
    final GameState baseState = state.copyWith(
      players: playersAfterBonus,
      pendingRoll: null,
      challengeState: null,
      eventLog: <GameLogEntry>[...logEntries, ...state.eventLog],
      undoSnapshot: null,
    );

    if (shouldBankAction) {
      final CommandResult turnEndResult = TurnReducer.resolveTurnEnd(
        baseState,
        randomizer,
      );

      return CommandResult(
        state: turnEndResult.state,
        transition: StateTransition(
          logEntries: <GameLogEntry>[
            ...logEntries,
            ...turnEndResult.transition.logEntries,
          ],
          completedSchoolIds: turnEndResult.transition.completedSchoolIds,
        ),
      );
    }

    return CommandResult(
      state: baseState.copyWith(
        actionsRemaining: max(0, state.actionsRemaining - 1),
        currentTurnBonusActionsRemaining: max(
          0,
          state.currentTurnBonusActionsRemaining - 1,
        ),
      ),
      transition: StateTransition(logEntries: logEntries),
    );
  }

  static CommandResult selectCombatCard(
    GameState state,
    String fighterId,
    String cardId,
  ) {
    final CombatState? combatState = state.combatState;
    if (combatState == null || combatState.phase != CombatPhase.selection) {
      return CommandResult.unchanged(state);
    }

    final CombatantState? combatant = combatState.combatants[fighterId];
    if (combatant == null ||
        !combatant.hand.any((CombatCard card) => card.id == cardId)) {
      return CommandResult.unchanged(state);
    }

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(
          combatants: <String, CombatantState>{
            ...combatState.combatants,
            fighterId: combatant.copyWith(
              selectedCardId: cardId,
              effectiveCardId: cardId,
              selectedMode: null,
              stumbleTriggered: false,
            ),
          },
        ),
      ),
    );
  }

  static CommandResult selectCombatMode(
    GameState state,
    String fighterId,
    CombatMode mode,
  ) {
    final CombatState? combatState = state.combatState;
    if (combatState == null || combatState.phase != CombatPhase.selection) {
      return CommandResult.unchanged(state);
    }

    final CombatantState? combatant = combatState.combatants[fighterId];
    final CombatCard? selectedCard = combatant == null
        ? null
        : getCombatCardById(combatant, combatant.selectedCardId);
    if (combatant == null || selectedCard == null) {
      return CommandResult.unchanged(state);
    }

    final bool modeAllowed = getAvailableModes(
      selectedCard,
    ).any((CombatModeOption option) => option.id == mode);
    if (!modeAllowed ||
        getModeCost(selectedCard, mode) > combatant.currentFormPoints) {
      return CommandResult.unchanged(state);
    }

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(
          combatants: <String, CombatantState>{
            ...combatState.combatants,
            fighterId: combatant.copyWith(
              selectedMode: mode,
              effectiveCardId: combatant.selectedCardId,
              stumbleTriggered: false,
            ),
          },
        ),
      ),
    );
  }

  static CommandResult triggerCombatStumble(
    GameState state,
    String fighterId,
    Randomizer randomizer,
  ) {
    final CombatState? combatState = state.combatState;
    if (combatState == null || combatState.phase != CombatPhase.reaction) {
      return CommandResult.unchanged(state);
    }

    final CombatantState? combatant = combatState.combatants[fighterId];
    final CombatCard? selectedCard = combatant == null
        ? null
        : getCombatCardById(combatant, combatant.selectedCardId);
    final EffectiveCombatCard? effectiveCard = combatant == null
        ? null
        : getEffectiveCardForCombatant(combatant);
    if (combatant == null ||
        selectedCard == null ||
        effectiveCard == null ||
        combatant.stumbleTriggered ||
        !effectiveCard.allowsReactionStumble) {
      return CommandResult.unchanged(state);
    }

    final List<CombatCard> availableCards = combatant.hand
        .where((CombatCard card) => card.id != combatant.selectedCardId)
        .toList(growable: false);
    if (availableCards.isEmpty) {
      return CommandResult.unchanged(state);
    }

    final CombatCard randomCard =
        availableCards[randomizer.nextInt(availableCards.length)];

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(
          clashLog: <String>[
            '${combatant.name} triggers Stumble and swaps into ${randomCard.title}.',
            ...combatState.clashLog,
          ],
          combatants: <String, CombatantState>{
            ...combatState.combatants,
            fighterId: combatant.copyWith(
              effectiveCardId: randomCard.id,
              stumbleTriggered: true,
            ),
          },
        ),
      ),
    );
  }

  static CommandResult advanceCombatPhase(
    GameState state,
    Randomizer randomizer,
  ) {
    final CombatState? combatState = state.combatState;
    if (combatState == null) {
      return CommandResult.unchanged(state);
    }

    final CombatantState? leftCombatant =
        combatState.combatants[combatState.attackerId];
    final CombatantState? rightCombatant =
        combatState.combatants[combatState.defenderId];
    if (leftCombatant == null || rightCombatant == null) {
      return CommandResult.unchanged(state);
    }

    switch (combatState.phase) {
      case CombatPhase.selection:
        return _advanceSelectionPhase(
          state,
          combatState,
          leftCombatant,
          rightCombatant,
        );
      case CombatPhase.reveal:
        return CommandResult(
          state: state.copyWith(
            combatState: combatState.copyWith(phase: CombatPhase.reaction),
          ),
        );
      case CombatPhase.reaction:
        return _advanceReactionPhase(
          state,
          combatState,
          leftCombatant,
          rightCombatant,
        );
      case CombatPhase.calculation:
        return _advanceCalculationPhase(state, combatState);
      case CombatPhase.activation:
        return CommandResult(
          state: state.copyWith(
            combatState: combatState.copyWith(
              clashNumber: combatState.clashNumber + 1,
              phase: CombatPhase.selection,
              resolutionSummary: null,
              combatants: <String, CombatantState>{
                ...combatState.combatants,
                combatState.attackerId: settleCombatCardUse(
                  leftCombatant,
                  randomizer,
                ),
                combatState.defenderId: settleCombatCardUse(
                  rightCombatant,
                  randomizer,
                ),
              },
            ),
          ),
        );
    }
  }

  static CommandResult _advanceSelectionPhase(
    GameState state,
    CombatState combatState,
    CombatantState leftCombatant,
    CombatantState rightCombatant,
  ) {
    if (leftCombatant.selectedCardId == null ||
        rightCombatant.selectedCardId == null ||
        leftCombatant.selectedMode == null ||
        rightCombatant.selectedMode == null) {
      return CommandResult.unchanged(state);
    }

    final CombatCard? leftSelectedCard = getCombatCardById(
      leftCombatant,
      leftCombatant.selectedCardId,
    );
    final CombatCard? rightSelectedCard = getCombatCardById(
      rightCombatant,
      rightCombatant.selectedCardId,
    );
    if (leftSelectedCard == null || rightSelectedCard == null) {
      return CommandResult.unchanged(state);
    }

    final int leftCost = getModeCost(
      leftSelectedCard,
      leftCombatant.selectedMode!,
    );
    final int rightCost = getModeCost(
      rightSelectedCard,
      rightCombatant.selectedMode!,
    );

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(
          phase: CombatPhase.reveal,
          combatants: <String, CombatantState>{
            ...combatState.combatants,
            combatState.attackerId: leftCombatant.copyWith(
              currentFormPoints: max(
                0,
                leftCombatant.currentFormPoints - leftCost,
              ),
            ),
            combatState.defenderId: rightCombatant.copyWith(
              currentFormPoints: max(
                0,
                rightCombatant.currentFormPoints - rightCost,
              ),
            ),
          },
        ),
      ),
    );
  }

  static CommandResult _advanceReactionPhase(
    GameState state,
    CombatState combatState,
    CombatantState leftCombatant,
    CombatantState rightCombatant,
  ) {
    final EffectiveCombatCard? leftConfig = getEffectiveCardForCombatant(
      leftCombatant,
    );
    final EffectiveCombatCard? rightConfig = getEffectiveCardForCombatant(
      rightCombatant,
    );
    if (leftConfig == null || rightConfig == null) {
      return CommandResult.unchanged(state);
    }

    final AttackResolution leftOutcome = resolveAttackAgainstDefender(
      leftConfig,
      rightConfig,
    );
    final AttackResolution rightOutcome = resolveAttackAgainstDefender(
      rightConfig,
      leftConfig,
    );
    final int leftReversalHits = leftConfig.grantsReversal
        ? leftOutcome.blocks
        : 0;
    final int rightReversalHits = rightConfig.grantsReversal
        ? rightOutcome.blocks
        : 0;
    final int nextLeftHitPoints = max(
      0,
      leftCombatant.currentHitPoints - rightOutcome.hits - rightReversalHits,
    );
    final int nextRightHitPoints = max(
      0,
      rightCombatant.currentHitPoints - leftOutcome.hits - leftReversalHits,
    );

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(
          phase: CombatPhase.calculation,
          clashLog: <String>[
            '${leftCombatant.name} deals ${leftOutcome.hits} strike damage${leftReversalHits > 0 ? ' and $leftReversalHits Reversal damage' : ''}. '
                '${rightCombatant.name} deals ${rightOutcome.hits} strike damage${rightReversalHits > 0 ? ' and $rightReversalHits Reversal damage' : ''}.',
            ...combatState.clashLog,
          ],
          resolutionSummary: CombatResolutionSummary(
            leftSummary:
                '${leftCombatant.name} deals ${leftOutcome.hits + leftReversalHits} total damage and blocks ${rightOutcome.blocks} attack(s).',
            rightSummary:
                '${rightCombatant.name} deals ${rightOutcome.hits + rightReversalHits} total damage and blocks ${leftOutcome.blocks} attack(s).',
          ),
          combatants: <String, CombatantState>{
            ...combatState.combatants,
            combatState.attackerId: leftCombatant.copyWith(
              currentHitPoints: nextLeftHitPoints,
            ),
            combatState.defenderId: rightCombatant.copyWith(
              currentHitPoints: nextRightHitPoints,
            ),
          },
        ),
      ),
    );
  }

  static CommandResult _advanceCalculationPhase(
    GameState state,
    CombatState combatState,
  ) {
    final String? loserId = getCombatLoserId(combatState);
    if (loserId != null) {
      return _resolveCombatOutcome(state, combatState, loserId);
    }

    return CommandResult(
      state: state.copyWith(
        combatState: combatState.copyWith(phase: CombatPhase.activation),
      ),
    );
  }

  static CommandResult _resolveCombatOutcome(
    GameState state,
    CombatState combatState,
    String loserId,
  ) {
    final CombatantState leftCombatant =
        combatState.combatants[combatState.attackerId]!;
    final CombatantState rightCombatant =
        combatState.combatants[combatState.defenderId]!;
    final CombatantState winnerCombatant = loserId == combatState.attackerId
        ? rightCombatant
        : leftCombatant;
    final CombatantState loserCombatant = loserId == combatState.attackerId
        ? leftCombatant
        : rightCombatant;
    final List<Player> updatedPlayers = clonePlayers(state.players);
    final int loserIndex = updatedPlayers.indexWhere(
      (Player player) => player.id == loserId,
    );
    final int winnerIndex = updatedPlayers.indexWhere(
      (Player player) => player.id == winnerCombatant.id,
    );

    if (loserIndex != -1) {
      updatedPlayers[loserIndex] = lowerReputation(
        injurePlayer(updatedPlayers[loserIndex]),
      );
    }

    if (winnerIndex != -1) {
      updatedPlayers[winnerIndex] = raiseReputation(updatedPlayers[winnerIndex])
          .copyWith(
            bonusActionsNextTurn:
                updatedPlayers[winnerIndex].bonusActionsNextTurn + 1,
          );
    }

    final String winnerName = winnerIndex != -1
        ? getPlayerDisplayName(updatedPlayers[winnerIndex])
        : winnerCombatant.name;
    final String loserName = loserIndex != -1
        ? getPlayerDisplayName(updatedPlayers[loserIndex])
        : loserCombatant.name;

    final List<GameLogEntry> logEntries = <GameLogEntry>[
      GameLogEntry(
        message:
            '$winnerName defeats $loserName in combat. $winnerName gains 1 Reputation and a temporary extra action next turn. $loserName becomes Injured and loses 1 Reputation.',
      ),
    ];

    return CommandResult(
      state: state.copyWith(
        players: updatedPlayers,
        combatState: null,
        eventLog: <GameLogEntry>[...logEntries, ...state.eventLog],
      ),
      transition: StateTransition(logEntries: logEntries),
    );
  }

  static bool _isInteractionLocked(GameState state) {
    return state.winnerId != null ||
        state.gameOverReason != null ||
        state.challengeState != null ||
        state.combatState != null;
  }
}
