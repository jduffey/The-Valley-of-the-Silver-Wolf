import 'dart:math' as math;

import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_controller.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

typedef CombatChoice = ({
  CombatCard attackerCard,
  CombatMode attackerMode,
  CombatCard defenderCard,
  CombatMode defenderMode,
});

typedef CombatFixture = ({GameState gameState, CombatChoice choice});

class FixedRandomizer implements Randomizer {
  FixedRandomizer(this.values);

  final List<int> values;
  int _index = 0;

  @override
  int nextInt(int max) {
    final int value = values[_index % values.length];
    _index += 1;
    return value.clamp(0, max - 1);
  }
}

class PreparedGameSessionController extends GameSessionController {
  PreparedGameSessionController(this._initialViewState);

  final GameSessionViewState _initialViewState;

  @override
  GameSessionViewState build() => _initialViewState;
}

GameSessionViewState buildViewState(GameState gameState) {
  return GameSessionViewState(
    gameState: gameState,
    selectedProfilePlayerId: gameState.currentPlayer.id,
    openDialog: gameState.combatState != null
        ? GameSessionDialog.combat
        : gameState.challengeState != null
        ? GameSessionDialog.challenge
        : null,
    isAnimatingSaveCompletion: false,
  );
}

GameState createChallengeDialogGameState({
  int actionsRemaining = 1,
  bool lethalHitPoints = false,
}) {
  final GameState initialState = InitialStateFactory.create();
  final List<Player> players = initialState.players
      .map((Player player) {
        if (player.id == 'p1' || player.id == 'p2' || player.id == 'p3') {
          return player.copyWith(
            position: 0,
            hitPoints:
                lethalHitPoints && (player.id == 'p1' || player.id == 'p2')
                ? 1
                : player.hitPoints,
          );
        }

        return player;
      })
      .toList(growable: false);

  return initialState.copyWith(
    players: players,
    actionsRemaining: actionsRemaining,
    challengeState: const ChallengeState(
      challengerId: 'p1',
      opponentIds: <String>['p2', 'p3'],
      targetId: null,
    ),
  );
}

CombatFixture createLethalCombatFixture() {
  final GameState initialState = InitialStateFactory.create();
  final List<Player> players = initialState.players
      .map((Player player) {
        if (player.id == 'p1' || player.id == 'p2') {
          return player.copyWith(hitPoints: 1);
        }

        return player;
      })
      .toList(growable: false);
  final CombatState combatState = CombatStateFactory.create(
    players,
    'p1',
    'p2',
    FixedRandomizer(List<int>.filled(32, 0)),
  )!;
  final CombatChoice choice = chooseLethalCombatChoice(combatState);

  return (
    gameState: initialState.copyWith(
      players: players,
      combatState: combatState,
    ),
    choice: choice,
  );
}

GameState createCombatGameStateAtPhase(CombatPhase phase) {
  final FixedRandomizer randomizer = FixedRandomizer(List<int>.filled(32, 0));
  final CombatFixture fixture = createLethalCombatFixture();
  GameState state = fixture.gameState;

  if (phase == CombatPhase.selection) {
    return state;
  }

  state = GameReducer.reduce(
    state,
    GameCommandFactory.selectCombatCard('p1', fixture.choice.attackerCard.id),
    randomizer,
  ).state;
  state = GameReducer.reduce(
    state,
    GameCommandFactory.selectCombatMode('p1', fixture.choice.attackerMode),
    randomizer,
  ).state;
  state = GameReducer.reduce(
    state,
    GameCommandFactory.selectCombatCard('p2', fixture.choice.defenderCard.id),
    randomizer,
  ).state;
  state = GameReducer.reduce(
    state,
    GameCommandFactory.selectCombatMode('p2', fixture.choice.defenderMode),
    randomizer,
  ).state;
  state = GameReducer.reduce(
    state,
    GameCommandFactory.advanceCombatPhase,
    randomizer,
  ).state;

  if (phase == CombatPhase.reveal) {
    return state;
  }

  state = GameReducer.reduce(
    state,
    GameCommandFactory.advanceCombatPhase,
    randomizer,
  ).state;
  if (phase == CombatPhase.reaction) {
    return state;
  }

  state = GameReducer.reduce(
    state,
    GameCommandFactory.advanceCombatPhase,
    randomizer,
  ).state;
  if (phase == CombatPhase.calculation) {
    return state;
  }

  state = GameReducer.reduce(
    state,
    GameCommandFactory.advanceCombatPhase,
    randomizer,
  ).state;
  if (phase == CombatPhase.activation || state.combatState == null) {
    return state;
  }

  return state;
}

CombatChoice chooseLethalCombatChoice(CombatState combatState) {
  final CombatantState attacker =
      combatState.combatants[combatState.attackerId]!;
  final CombatantState defender =
      combatState.combatants[combatState.defenderId]!;

  for (final CombatCard attackerCard in attacker.hand) {
    for (final CombatModeOption attackerOption in getAvailableModes(
      attackerCard,
    )) {
      if (attackerOption.cost > attacker.currentFormPoints) {
        continue;
      }

      final EffectiveCombatCard attackerConfig = getEffectiveCardForCombatant(
        attacker.copyWith(
          selectedCardId: attackerCard.id,
          effectiveCardId: attackerCard.id,
          selectedMode: attackerOption.id,
        ),
      )!;

      for (final CombatCard defenderCard in defender.hand) {
        for (final CombatModeOption defenderOption in getAvailableModes(
          defenderCard,
        )) {
          if (defenderOption.cost > defender.currentFormPoints) {
            continue;
          }

          final EffectiveCombatCard defenderConfig =
              getEffectiveCardForCombatant(
                defender.copyWith(
                  selectedCardId: defenderCard.id,
                  effectiveCardId: defenderCard.id,
                  selectedMode: defenderOption.id,
                ),
              )!;
          final AttackResolution leftOutcome = resolveAttackAgainstDefender(
            attackerConfig,
            defenderConfig,
          );
          final AttackResolution rightOutcome = resolveAttackAgainstDefender(
            defenderConfig,
            attackerConfig,
          );
          final int leftReversalHits = attackerConfig.grantsReversal
              ? leftOutcome.blocks
              : 0;
          final int rightReversalHits = defenderConfig.grantsReversal
              ? rightOutcome.blocks
              : 0;
          final int nextAttackerHitPoints = math.max(
            0,
            attacker.currentHitPoints - rightOutcome.hits - rightReversalHits,
          );
          final int nextDefenderHitPoints = math.max(
            0,
            defender.currentHitPoints - leftOutcome.hits - leftReversalHits,
          );

          if (nextAttackerHitPoints <= 0 || nextDefenderHitPoints <= 0) {
            return (
              attackerCard: attackerCard,
              attackerMode: attackerOption.id,
              defenderCard: defenderCard,
              defenderMode: defenderOption.id,
            );
          }
        }
      }
    }
  }

  throw StateError('No lethal combat pairing found for the prepared fixture.');
}
