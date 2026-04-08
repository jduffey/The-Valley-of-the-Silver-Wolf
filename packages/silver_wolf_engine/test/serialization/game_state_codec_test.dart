import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixed_randomizer.dart';

void main() {
  test('GameStateCodec round-trips a challenge state with undo data', () {
    final GameState initialState = InitialStateFactory.create();
    final List<Player> players = initialState.players
        .map(
          (Player player) => switch (player.id) {
            'p1' => player.copyWith(position: 0, injured: true, hitPoints: 1),
            'p2' => player.copyWith(position: 0, reputation: 4),
            'p3' => player.copyWith(position: 0),
            _ => player,
          },
        )
        .toList(growable: false);
    final List<School> schools = initialState.schools
        .map(
          (School school) => school.id == '#Leap-Creek'
              ? school.copyWith(
                  status: SchoolStatus.sieged,
                  saveProgress: 2,
                  defenders: <String>['p1'],
                )
              : school,
        )
        .toList(growable: false);
    final UndoSnapshot undoSnapshot = UndoSnapshot(
      playerId: 'p1',
      players: initialState.players,
      schools: initialState.schools,
      actionsRemaining: 2,
      currentTurnBonusActionsRemaining: 0,
      nextArrivalOrder: initialState.nextArrivalOrder,
      eventLog: const <GameLogEntry>[
        GameLogEntry(
          message: 'Player 1 healed at Leap-Creek.',
          type: 'heal',
          metadata: <String, Object?>{
            'playerId': 'p1',
            'locationId': '#Leap-Creek',
          },
        ),
      ],
      pendingRoll: 4,
    );
    final GameState gameState = initialState.copyWith(
      players: players,
      schools: schools,
      actionsRemaining: 1,
      pendingRoll: 2,
      challengeState: const ChallengeState(
        challengerId: 'p1',
        opponentIds: <String>['p2', 'p3'],
        targetId: 'p2',
      ),
      eventLog: const <GameLogEntry>[
        GameLogEntry(
          message: 'Player 2 declines Player 1\'s challenge.',
          type: 'challenge_declined',
          metadata: <String, Object?>{'challengerId': 'p1', 'targetId': 'p2'},
        ),
      ],
      undoSnapshot: undoSnapshot,
    );

    final String encoded = GameStateCodec.encode(gameState);
    final GameState decoded = GameStateCodec.decode(encoded);

    expect(
      GameStateCodec.toJson(decoded),
      equals(GameStateCodec.toJson(gameState)),
    );
  });

  test('GameStateCodec round-trips an active combat state', () {
    final GameState initialState = InitialStateFactory.create();
    final List<Player> players = initialState.players
        .map(
          (Player player) => switch (player.id) {
            'p1' => player.copyWith(hitPoints: 1, bonusActionsNextTurn: 1),
            'p2' => player.copyWith(hitPoints: 1, injured: true),
            _ => player,
          },
        )
        .toList(growable: false);
    final CombatState combatState = CombatStateFactory.create(
      players,
      'p1',
      'p2',
      FixedRandomizer(List<int>.filled(32, 0)),
    )!;
    final CombatantState attacker = combatState.combatants['p1']!;
    final CombatantState defender = combatState.combatants['p2']!;
    final CombatCard attackerCard = attacker.hand.first;
    final CombatCard defenderCard = defender.hand.first;
    final CombatState richCombatState = combatState.copyWith(
      clashNumber: 2,
      phase: CombatPhase.reaction,
      clashLog: const <String>[
        'Player 1 deals 1 strike damage.',
        'Player 2 deals 1 strike damage.',
      ],
      combatants: <String, CombatantState>{
        ...combatState.combatants,
        'p1': attacker.copyWith(
          selectedCardId: attackerCard.id,
          effectiveCardId: attackerCard.id,
          selectedMode: CombatMode.keyword,
          currentFormPoints: 1,
        ),
        'p2': defender.copyWith(
          selectedCardId: defenderCard.id,
          effectiveCardId: defenderCard.id,
          selectedMode: CombatMode.swapDefense,
          stumbleTriggered: true,
        ),
      },
      resolutionSummary: const CombatResolutionSummary(
        leftSummary: 'Player 1 blocks 1 attack.',
        rightSummary: 'Player 2 deals 1 total damage.',
      ),
    );
    final GameState gameState = initialState.copyWith(
      players: players,
      combatState: richCombatState,
      eventLog: const <GameLogEntry>[
        GameLogEntry(
          message: 'Player 1 defeats Player 2 in combat.',
          type: 'combat_victory',
          metadata: <String, Object?>{'winnerId': 'p1', 'loserId': 'p2'},
        ),
      ],
    );

    final Map<String, Object?> json = GameStateCodec.toJson(gameState);
    final GameState decoded = GameStateCodec.fromJson(json);

    expect(GameStateCodec.toJson(decoded), equals(json));
  });
}
