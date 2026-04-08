import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixed_randomizer.dart';

CombatantState buildCombatant({
  required String id,
  required String keyword,
  required List<CombatCard> hand,
  List<CombatCard> drawPile = const <CombatCard>[],
  List<CombatCard> discard = const <CombatCard>[],
  CombatMode? selectedMode,
  String? selectedCardId,
  String? effectiveCardId,
  int currentHitPoints = 3,
  int currentFormPoints = 2,
  bool stumbleTriggered = false,
}) {
  return CombatantState(
    id: id,
    name: id,
    displayName: id,
    hometownName: 'Test',
    keyword: keyword,
    maxHitPoints: 3,
    currentHitPoints: currentHitPoints,
    maxFormPoints: 2,
    currentFormPoints: currentFormPoints,
    drawPile: drawPile,
    hand: hand,
    discard: discard,
    selectedCardId: selectedCardId,
    selectedMode: selectedMode,
    effectiveCardId: effectiveCardId,
    stumbleTriggered: stumbleTriggered,
    reactionLocked: false,
  );
}

CombatState buildCombatState({
  required CombatPhase phase,
  required CombatantState attacker,
  required CombatantState defender,
  int clashNumber = 1,
  List<String> clashLog = const <String>[],
  CombatResolutionSummary? resolutionSummary,
}) {
  return CombatState(
    attackerId: attacker.id,
    defenderId: defender.id,
    clashNumber: clashNumber,
    phase: phase,
    clashLog: clashLog,
    combatants: <String, CombatantState>{
      attacker.id: attacker,
      defender.id: defender,
    },
    resolutionSummary: resolutionSummary,
  );
}

List<int> challengeSetupRolls() {
  return <int>[...List<int>.filled(18, 0), 5, 0];
}

GameState buildChallengeReadyState({int actionsRemaining = 2}) {
  final GameState initialState = InitialStateFactory.create();
  final List<Player> players = <Player>[
    initialState.players[0],
    initialState.players[1].copyWith(
      position: initialState.players[0].position,
    ),
    ...initialState.players.skip(2),
  ];

  return initialState.copyWith(
    players: players,
    actionsRemaining: actionsRemaining,
    challengeState: const ChallengeState(
      challengerId: 'p1',
      opponentIds: <String>['p2'],
      targetId: 'p2',
    ),
  );
}

void main() {
  group('combat reducer flow', () {
    test('open challenge targets the lone rival on the current space', () {
      final GameState initialState = InitialStateFactory.create();
      final GameState state = initialState.copyWith(
        players: <Player>[
          initialState.players[0],
          initialState.players[1].copyWith(
            position: initialState.players[0].position,
          ),
          ...initialState.players.skip(2),
        ],
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const OpenChallengeCommand(),
        FixedRandomizer(const <int>[0]),
      );

      expect(result.state.challengeState, isNotNull);
      expect(result.state.challengeState!.challengerId, 'p1');
      expect(result.state.challengeState!.targetId, 'p2');
    });

    test(
      'accept challenge starts combat and banks the spent action when needed',
      () {
        final GameState state = buildChallengeReadyState(actionsRemaining: 2);

        final CommandResult result = GameReducer.reduce(
          state,
          const AcceptChallengeCommand(),
          FixedRandomizer(challengeSetupRolls()),
        );

        expect(result.state.challengeState, isNull);
        expect(result.state.combatState, isNotNull);
        expect(result.state.combatState!.attackerId, 'p1');
        expect(result.state.currentPlayerIndex, 1);
        expect(result.state.actionsRemaining, 2);
        expect(result.state.players.first.bonusActionsNextTurn, 1);
      },
    );

    test(
      'decline challenge lowers the target reputation and spends the action',
      () {
        final GameState state = buildChallengeReadyState(actionsRemaining: 1);

        final CommandResult result = GameReducer.reduce(
          state,
          const DeclineChallengeCommand(),
          FixedRandomizer(const <int>[0]),
        );

        expect(result.state.challengeState, isNull);
        expect(result.state.players[1].reputation, 2);
        expect(result.state.actionsRemaining, 0);
        expect(
          result.transition.logEntries.single.message,
          contains("declines Player 1's challenge"),
        );
      },
    );

    test('selection advance deducts form points and moves to reveal', () {
      final GameState initialState = InitialStateFactory.create();
      final CombatState combatState = CombatStateFactory.create(
        initialState.players,
        'p1',
        'p2',
        FixedRandomizer(List<int>.filled(18, 0)),
      )!;
      final String attackerCardId = combatState.combatants['p1']!.hand.first.id;
      final String defenderCardId = combatState.combatants['p2']!.hand.first.id;

      GameState state = initialState.copyWith(combatState: combatState);
      state = GameReducer.reduce(
        state,
        SelectCombatCardCommand('p1', attackerCardId),
        FixedRandomizer(const <int>[0]),
      ).state;
      state = GameReducer.reduce(
        state,
        SelectCombatCardCommand('p2', defenderCardId),
        FixedRandomizer(const <int>[0]),
      ).state;
      state = GameReducer.reduce(
        state,
        const SelectCombatModeCommand('p1', CombatMode.swapAttack),
        FixedRandomizer(const <int>[0]),
      ).state;
      state = GameReducer.reduce(
        state,
        const SelectCombatModeCommand('p2', CombatMode.swapAttack),
        FixedRandomizer(const <int>[0]),
      ).state;

      final CommandResult result = GameReducer.reduce(
        state,
        const AdvanceCombatPhaseCommand(),
        FixedRandomizer(const <int>[0]),
      );

      expect(result.state.combatState!.phase, CombatPhase.reveal);
      expect(result.state.combatState!.combatants['p1']!.currentFormPoints, 1);
      expect(result.state.combatState!.combatants['p2']!.currentFormPoints, 1);
    });

    test('stumble swaps to another card during the reaction phase', () {
      final CombatCard selectedCard = baseCombatDeckCards.first;
      final CombatCard alternateCard = baseCombatDeckCards[1];
      final CombatState combatState = buildCombatState(
        phase: CombatPhase.reaction,
        attacker: buildCombatant(
          id: 'p5',
          keyword: 'Stumble',
          hand: <CombatCard>[selectedCard, alternateCard],
          selectedCardId: selectedCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: selectedCard.id,
        ),
        defender: buildCombatant(
          id: 'p1',
          keyword: 'Reversal',
          hand: <CombatCard>[baseCombatDeckCards[2]],
          selectedCardId: baseCombatDeckCards[2].id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: baseCombatDeckCards[2].id,
        ),
      );
      final GameState state = InitialStateFactory.create().copyWith(
        combatState: combatState,
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const TriggerCombatStumbleCommand('p5'),
        FixedRandomizer(const <int>[0]),
      );

      expect(
        result.state.combatState!.combatants['p5']!.effectiveCardId,
        alternateCard.id,
      );
      expect(
        result.state.combatState!.combatants['p5']!.stumbleTriggered,
        isTrue,
      );
      expect(
        result.state.combatState!.clashLog.first,
        contains(alternateCard.title),
      );
    });

    test('reaction advance calculates damage and stores the clash summary', () {
      final CombatCard leftCard = baseCombatDeckCards[1];
      final CombatCard rightCard = baseCombatDeckCards[3];
      final CombatState combatState = buildCombatState(
        phase: CombatPhase.reaction,
        attacker: buildCombatant(
          id: 'p1',
          keyword: 'Reversal',
          hand: <CombatCard>[leftCard],
          selectedCardId: leftCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: leftCard.id,
        ),
        defender: buildCombatant(
          id: 'p2',
          keyword: 'Keyword',
          hand: <CombatCard>[rightCard],
          selectedCardId: rightCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: rightCard.id,
        ),
      );
      final GameState state = InitialStateFactory.create().copyWith(
        combatState: combatState,
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const AdvanceCombatPhaseCommand(),
        FixedRandomizer(const <int>[0]),
      );

      expect(result.state.combatState!.phase, CombatPhase.calculation);
      expect(result.state.combatState!.combatants['p1']!.currentHitPoints, 3);
      expect(result.state.combatState!.combatants['p2']!.currentHitPoints, 2);
      expect(
        result.state.combatState!.resolutionSummary!.leftSummary,
        contains('deals 1 total damage'),
      );
    });

    test(
      'calculation advance resolves simultaneous defeat in the attackers favor',
      () {
        final CombatState combatState = buildCombatState(
          phase: CombatPhase.calculation,
          attacker: buildCombatant(
            id: 'p1',
            keyword: 'Reversal',
            hand: <CombatCard>[baseCombatDeckCards.first],
            currentHitPoints: 0,
          ),
          defender: buildCombatant(
            id: 'p2',
            keyword: 'Endure',
            hand: <CombatCard>[baseCombatDeckCards[1]],
            currentHitPoints: 0,
          ),
        );
        final GameState state = InitialStateFactory.create().copyWith(
          combatState: combatState,
        );

        final CommandResult result = GameReducer.reduce(
          state,
          const AdvanceCombatPhaseCommand(),
          FixedRandomizer(const <int>[0]),
        );

        expect(result.state.combatState, isNull);
        expect(result.state.players[0].reputation, 4);
        expect(result.state.players[0].bonusActionsNextTurn, 1);
        expect(result.state.players[1].injured, isTrue);
        expect(result.state.players[1].reputation, 2);
        expect(
          result.transition.logEntries.single.message,
          contains('Player 1 defeats Player 2'),
        );
      },
    );

    test('activation advance settles used cards and starts the next clash', () {
      final CombatCard leftCard = baseCombatDeckCards.first;
      final CombatCard leftDraw = baseCombatDeckCards[1];
      final CombatCard rightCard = baseCombatDeckCards[2];
      final CombatCard rightDraw = baseCombatDeckCards[3];
      final CombatState combatState = buildCombatState(
        phase: CombatPhase.activation,
        attacker: buildCombatant(
          id: 'p1',
          keyword: 'Reversal',
          hand: <CombatCard>[leftCard],
          drawPile: <CombatCard>[leftDraw],
          selectedCardId: leftCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: leftCard.id,
        ),
        defender: buildCombatant(
          id: 'p2',
          keyword: 'Endure',
          hand: <CombatCard>[rightCard],
          drawPile: <CombatCard>[rightDraw],
          selectedCardId: rightCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: rightCard.id,
        ),
      );
      final GameState state = InitialStateFactory.create().copyWith(
        combatState: combatState,
      );

      final CommandResult result = GameReducer.reduce(
        state,
        const AdvanceCombatPhaseCommand(),
        FixedRandomizer(List<int>.filled(8, 0)),
      );

      expect(result.state.combatState!.clashNumber, 2);
      expect(result.state.combatState!.phase, CombatPhase.selection);
      expect(result.state.combatState!.combatants['p1']!.hand, <CombatCard>[
        leftDraw,
      ]);
      expect(result.state.combatState!.combatants['p2']!.hand, <CombatCard>[
        rightDraw,
      ]);
      expect(
        result.state.combatState!.combatants['p1']!.selectedCardId,
        isNull,
      );
      expect(
        result.state.combatState!.combatants['p2']!.selectedCardId,
        isNull,
      );
    });
  });
}
