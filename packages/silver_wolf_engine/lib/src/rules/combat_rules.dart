import 'dart:math';

import 'package:collection/collection.dart';
import 'package:silver_wolf_engine/src/data/combat_deck_library.dart';
import 'package:silver_wolf_engine/src/data/fighter_style_copy.dart';
import 'package:silver_wolf_engine/src/enums/combat_lane.dart';
import 'package:silver_wolf_engine/src/enums/combat_mode.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';
import 'package:silver_wolf_engine/src/models/combat_state.dart';
import 'package:silver_wolf_engine/src/models/combatant_state.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';

typedef CombatModeOption = ({
  CombatMode id,
  String label,
  String copy,
  int cost,
});
typedef EffectiveCombatCard = ({
  CombatCard card,
  List<CombatLane> attackLanes,
  List<CombatLane> defenseLanes,
  bool keywordActive,
  String keyword,
  bool ignoresIncomingAttack,
  bool grantsReversal,
  bool allowsReactionStumble,
});
typedef AttackResolution = ({int hits, int blocks, int ignored});

String getCombatantKeyword(String hometownName) {
  return fighterStyleCopy[hometownName]?.keyword ?? 'Keyword';
}

List<Player> getRivalsAtPosition(List<Player> players, int activeIndex) {
  final Player? activePlayer = players.elementAtOrNull(activeIndex);
  if (activePlayer == null || !activePlayer.alive) {
    return const <Player>[];
  }

  return players
      .where(
        (Player player) =>
            player.id != activePlayer.id &&
            player.alive &&
            player.position == activePlayer.position,
      )
      .toList(growable: false);
}

List<CombatCard> createCombatDeckForPlayer(Player player) {
  final List<CombatCard>? hometownDeck = combatDeckLibrary[player.name];
  return List<CombatCard>.from(hometownDeck ?? combatDeckLibrary['Pouch']!);
}

List<CombatCard> shuffleCombatDeck(
  List<CombatCard> cards,
  Randomizer randomizer,
) {
  final List<CombatCard> result = List<CombatCard>.from(cards);

  for (int index = result.length - 1; index > 0; index -= 1) {
    final int swapIndex = randomizer.nextInt(index + 1);
    final CombatCard current = result[index];
    result[index] = result[swapIndex];
    result[swapIndex] = current;
  }

  return result;
}

({List<CombatCard> drawnCards, List<CombatCard> remainingDrawPile})
drawCombatCards(List<CombatCard> drawPile, int amount) {
  final int drawCount = min(amount, drawPile.length);
  return (
    drawnCards: drawPile.take(drawCount).toList(growable: false),
    remainingDrawPile: drawPile.skip(drawCount).toList(growable: false),
  );
}

CombatCard? getCombatCardById(CombatantState combatant, String? cardId) {
  if (cardId == null) {
    return null;
  }

  return combatant.hand.firstWhereOrNull(
        (CombatCard card) => card.id == cardId,
      ) ??
      combatant.discard.firstWhereOrNull(
        (CombatCard card) => card.id == cardId,
      ) ??
      combatant.drawPile.firstWhereOrNull(
        (CombatCard card) => card.id == cardId,
      );
}

EffectiveCombatCard? getEffectiveCardForCombatant(CombatantState combatant) {
  final CombatCard? card = getCombatCardById(
    combatant,
    combatant.effectiveCardId ?? combatant.selectedCardId,
  );

  if (card == null) {
    return null;
  }

  final bool keywordActive =
      card.isSpecial || combatant.selectedMode == CombatMode.keyword;
  final List<CombatLane> attackLanes = <CombatLane>[card.attack];
  final List<CombatLane> defenseLanes = <CombatLane>[card.defense];

  if (keywordActive && combatant.keyword == 'Flurry') {
    attackLanes.add(card.swapLane);
  }

  if (keywordActive && combatant.keyword == 'Endure') {
    defenseLanes.add(card.swapLane);
  }

  if (combatant.selectedMode == CombatMode.swapAttack) {
    attackLanes
      ..clear()
      ..add(card.swapLane);
  }

  if (combatant.selectedMode == CombatMode.swapDefense) {
    defenseLanes
      ..clear()
      ..add(card.swapLane);
  }

  return (
    card: card,
    attackLanes: attackLanes,
    defenseLanes: defenseLanes,
    keywordActive: keywordActive,
    keyword: combatant.keyword,
    ignoresIncomingAttack: keywordActive && combatant.keyword == 'Overwhelm',
    grantsReversal: keywordActive && combatant.keyword == 'Reversal',
    allowsReactionStumble: keywordActive && combatant.keyword == 'Stumble',
  );
}

int getModeCost(CombatCard card, CombatMode mode) {
  if (card.isSpecial) {
    return switch (mode) {
      CombatMode.swapAttack || CombatMode.swapDefense => 1,
      CombatMode.normal => 0,
      CombatMode.keyword => 0,
    };
  }

  return mode == CombatMode.normal ? 0 : 1;
}

List<CombatModeOption> getAvailableModes(CombatCard card) {
  if (card.isSpecial) {
    return <CombatModeOption>[
      (
        id: CombatMode.normal,
        label: 'Keyword Active',
        copy: 'Keyword is always on for this card.',
        cost: 0,
      ),
      (
        id: CombatMode.swapAttack,
        label: 'Swap Attack',
        copy: 'Replace attack with ${card.swapLane.name}.',
        cost: 1,
      ),
      (
        id: CombatMode.swapDefense,
        label: 'Swap Defense',
        copy: 'Replace defense with ${card.swapLane.name}.',
        cost: 1,
      ),
    ];
  }

  return <CombatModeOption>[
    (
      id: CombatMode.keyword,
      label: 'School Special',
      copy: "Use this fighter's keyword.",
      cost: 1,
    ),
    (
      id: CombatMode.swapAttack,
      label: 'Swap Attack',
      copy: 'Replace attack with ${card.swapLane.name}.',
      cost: 1,
    ),
    (
      id: CombatMode.swapDefense,
      label: 'Swap Defense',
      copy: 'Replace defense with ${card.swapLane.name}.',
      cost: 1,
    ),
  ];
}

AttackResolution resolveAttackAgainstDefender(
  EffectiveCombatCard attackerConfig,
  EffectiveCombatCard defenderConfig,
) {
  if (defenderConfig.ignoresIncomingAttack) {
    return (hits: 0, blocks: 0, ignored: attackerConfig.attackLanes.length);
  }

  int hits = 0;
  int blocks = 0;

  for (final CombatLane lane in attackerConfig.attackLanes) {
    if (defenderConfig.defenseLanes.contains(lane)) {
      blocks += 1;
    } else {
      hits += 1;
    }
  }

  return (hits: hits, blocks: blocks, ignored: 0);
}

CombatantState settleCombatCardUse(
  CombatantState combatant,
  Randomizer randomizer,
) {
  final String? consumedCardId =
      combatant.effectiveCardId ?? combatant.selectedCardId;
  final CombatCard? consumedCard = getCombatCardById(combatant, consumedCardId);
  final List<CombatCard> currentHand = combatant.hand
      .where((CombatCard card) => card.id != consumedCardId)
      .toList(growable: false);
  List<CombatCard> nextDrawPile = List<CombatCard>.from(combatant.drawPile);
  List<CombatCard> nextDiscard = <CombatCard>[
    ...combatant.discard,
    if (consumedCard != null) consumedCard,
  ];
  List<CombatCard> replenishedHand = List<CombatCard>.from(currentHand);

  if (replenishedHand.isEmpty) {
    if (nextDrawPile.isEmpty && nextDiscard.isNotEmpty) {
      final List<CombatCard> reshuffledDeck = shuffleCombatDeck(
        nextDiscard,
        randomizer,
      );
      final ({List<CombatCard> drawnCards, List<CombatCard> remainingDrawPile})
      redraw = drawCombatCards(reshuffledDeck, min(5, reshuffledDeck.length));
      replenishedHand = redraw.drawnCards;
      nextDrawPile = redraw.remainingDrawPile;
      nextDiscard = const <CombatCard>[];
    } else if (nextDrawPile.isNotEmpty) {
      final ({List<CombatCard> drawnCards, List<CombatCard> remainingDrawPile})
      redraw = drawCombatCards(nextDrawPile, min(5, nextDrawPile.length));
      replenishedHand = redraw.drawnCards;
      nextDrawPile = redraw.remainingDrawPile;
    }
  }

  return combatant.copyWith(
    hand: replenishedHand,
    drawPile: nextDrawPile,
    discard: nextDiscard,
    selectedCardId: null,
    selectedMode: null,
    effectiveCardId: null,
    stumbleTriggered: false,
    reactionLocked: false,
  );
}

String? getCombatLoserId(CombatState combatState) {
  final CombatantState? leftCombatant =
      combatState.combatants[combatState.attackerId];
  final CombatantState? rightCombatant =
      combatState.combatants[combatState.defenderId];

  if (leftCombatant == null || rightCombatant == null) {
    return null;
  }

  final bool bothDown =
      leftCombatant.currentHitPoints <= 0 &&
      rightCombatant.currentHitPoints <= 0;
  if (bothDown) {
    return combatState.defenderId;
  }
  if (leftCombatant.currentHitPoints <= 0) {
    return combatState.attackerId;
  }
  if (rightCombatant.currentHitPoints <= 0) {
    return combatState.defenderId;
  }

  return null;
}
