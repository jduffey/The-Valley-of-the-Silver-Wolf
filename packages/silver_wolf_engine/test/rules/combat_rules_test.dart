import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

import '../helpers/fixed_randomizer.dart';

CombatantState buildCombatant({
  required String id,
  required String keyword,
  required List<CombatCard> hand,
  List<CombatCard> drawPile = const <CombatCard>[],
  List<CombatCard> discard = const <CombatCard>[],
  String? selectedCardId,
  CombatMode? selectedMode,
  String? effectiveCardId,
  bool stumbleTriggered = false,
}) {
  return CombatantState(
    id: id,
    name: id,
    displayName: id,
    hometownName: 'Test',
    keyword: keyword,
    maxHitPoints: 3,
    currentHitPoints: 3,
    maxFormPoints: 2,
    currentFormPoints: 2,
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

void main() {
  group('combat rules', () {
    test('available modes keep base cards playable even at zero form points', () {
      final CombatCard normalCard = baseCombatDeckCards.first;
      final CombatCard specialCard = combatDeckLibrary['Pouch']!.last;

      expect(
        getAvailableModes(normalCard).map((CombatModeOption mode) => mode.id),
        <CombatMode>[
          CombatMode.normal,
          CombatMode.keyword,
          CombatMode.swapAttack,
          CombatMode.swapDefense,
        ],
        reason:
            'Base combat cards need a zero-cost normal mode or combat can deadlock when a fighter reaches 0 form points.',
      );
      expect(
        getAvailableModes(specialCard).map((CombatModeOption mode) => mode.id),
        <CombatMode>[
          CombatMode.normal,
          CombatMode.swapAttack,
          CombatMode.swapDefense,
        ],
      );
      expect(
        getAvailableModes(normalCard)
            .firstWhere((CombatModeOption mode) => mode.id == CombatMode.normal)
            .cost,
        0,
      );
    });

    test('mode cost follows the current combat prototype', () {
      final CombatCard normalCard = baseCombatDeckCards.first;
      final CombatCard specialCard = combatDeckLibrary['Pouch']!.last;

      expect(getModeCost(normalCard, CombatMode.keyword), 1);
      expect(getModeCost(normalCard, CombatMode.swapAttack), 1);
      expect(getModeCost(specialCard, CombatMode.normal), 0);
      expect(getModeCost(specialCard, CombatMode.swapDefense), 1);
    });

    test('effective cards activate keyword lane changes', () {
      final CombatCard card = baseCombatDeckCards[1];
      final CombatantState combatant = buildCombatant(
        id: 'p3',
        keyword: 'Flurry',
        hand: <CombatCard>[card],
        selectedCardId: card.id,
        selectedMode: CombatMode.keyword,
        effectiveCardId: card.id,
      );

      final EffectiveCombatCard? effectiveCard = getEffectiveCardForCombatant(
        combatant,
      );

      expect(effectiveCard, isNotNull);
      expect(effectiveCard!.attackLanes, <CombatLane>[
        card.attack,
        card.swapLane,
      ]);
      expect(effectiveCard.defenseLanes, <CombatLane>[card.defense]);
    });

    test(
      'lane resolution counts hits and blocks, including overwhelm ignores',
      () {
        final EffectiveCombatCard attacker = (
          card: baseCombatDeckCards.first,
          attackLanes: <CombatLane>[CombatLane.high, CombatLane.low],
          defenseLanes: <CombatLane>[CombatLane.middle],
          keywordActive: false,
          keyword: 'Keyword',
          ignoresIncomingAttack: false,
          grantsReversal: false,
          allowsReactionStumble: false,
        );
        final EffectiveCombatCard defender = (
          card: baseCombatDeckCards[1],
          attackLanes: <CombatLane>[CombatLane.middle],
          defenseLanes: <CombatLane>[CombatLane.high],
          keywordActive: false,
          keyword: 'Keyword',
          ignoresIncomingAttack: false,
          grantsReversal: false,
          allowsReactionStumble: false,
        );
        final EffectiveCombatCard overwhelmDefender = (
          card: baseCombatDeckCards[2],
          attackLanes: <CombatLane>[CombatLane.low],
          defenseLanes: <CombatLane>[CombatLane.low],
          keywordActive: true,
          keyword: 'Overwhelm',
          ignoresIncomingAttack: true,
          grantsReversal: false,
          allowsReactionStumble: false,
        );

        expect(resolveAttackAgainstDefender(attacker, defender), (
          hits: 1,
          blocks: 1,
          ignored: 0,
        ));
        expect(resolveAttackAgainstDefender(attacker, overwhelmDefender), (
          hits: 0,
          blocks: 0,
          ignored: 2,
        ));
      },
    );

    test(
      'settleCombatCardUse discards and redraws from reshuffled discard',
      () {
        final CombatCard selectedCard = baseCombatDeckCards.first;
        final CombatCard discardCard = baseCombatDeckCards[1];
        final CombatantState combatant = buildCombatant(
          id: 'p1',
          keyword: 'Reversal',
          hand: <CombatCard>[selectedCard],
          drawPile: const <CombatCard>[],
          discard: <CombatCard>[discardCard],
          selectedCardId: selectedCard.id,
          selectedMode: CombatMode.keyword,
          effectiveCardId: selectedCard.id,
        );

        final CombatantState settled = settleCombatCardUse(
          combatant,
          FixedRandomizer(List<int>.filled(8, 0)),
        );

        expect(settled.hand, hasLength(2));
        expect(settled.drawPile, isEmpty);
        expect(settled.discard, isEmpty);
        expect(settled.selectedCardId, isNull);
        expect(settled.selectedMode, isNull);
        expect(settled.effectiveCardId, isNull);
      },
    );
  });
}
