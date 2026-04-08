import 'package:collection/collection.dart';
import 'package:silver_wolf_engine/src/enums/combat_phase.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';
import 'package:silver_wolf_engine/src/models/combat_state.dart';
import 'package:silver_wolf_engine/src/models/combatant_state.dart';
import 'package:silver_wolf_engine/src/models/player.dart';
import 'package:silver_wolf_engine/src/random/randomizer.dart';
import 'package:silver_wolf_engine/src/rules/combat_rules.dart';
import 'package:silver_wolf_engine/src/rules/player_rules.dart';

class CombatStateFactory {
  const CombatStateFactory._();

  static CombatState? create(
    List<Player> players,
    String attackerId,
    String defenderId,
    Randomizer randomizer,
  ) {
    final Player? attacker = players
        .where((Player player) => player.id == attackerId)
        .firstOrNull;
    final Player? defender = players
        .where((Player player) => player.id == defenderId)
        .firstOrNull;

    if (attacker == null || defender == null) {
      return null;
    }

    return CombatState(
      attackerId: attackerId,
      defenderId: defenderId,
      clashNumber: 1,
      phase: CombatPhase.selection,
      clashLog: const <String>[],
      combatants: <String, CombatantState>{
        attackerId: createCombatantState(attacker, randomizer),
        defenderId: createCombatantState(defender, randomizer),
      },
      resolutionSummary: null,
    );
  }

  static CombatantState createCombatantState(
    Player player,
    Randomizer randomizer,
  ) {
    final List<CombatCard> shuffledDeck = shuffleCombatDeck(
      createCombatDeckForPlayer(player),
      randomizer,
    );
    final ({List<CombatCard> drawnCards, List<CombatCard> remainingDrawPile})
    openingDraw = drawCombatCards(shuffledDeck, 5);

    return CombatantState(
      id: player.id,
      name: getPlayerDisplayName(player),
      displayName: getPlayerDisplayName(player),
      hometownName: player.name,
      keyword: getCombatantKeyword(player.name),
      maxHitPoints: player.hitPoints,
      currentHitPoints: player.hitPoints,
      maxFormPoints: player.formPoints,
      currentFormPoints: player.formPoints,
      drawPile: openingDraw.remainingDrawPile,
      hand: openingDraw.drawnCards,
      discard: const <CombatCard>[],
      selectedCardId: null,
      selectedMode: null,
      effectiveCardId: null,
      stumbleTriggered: false,
      reactionLocked: false,
    );
  }
}
