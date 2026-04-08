import 'package:silver_wolf_engine/src/enums/combat_lane.dart';
import 'package:silver_wolf_engine/src/models/combat_card.dart';

const List<CombatCard> baseCombatDeckCards = <CombatCard>[
  CombatCard(
    id: 'shared-hh',
    attack: CombatLane.high,
    defense: CombatLane.high,
    swapLane: CombatLane.middle,
    isSpecial: false,
    title: 'High Wall',
  ),
  CombatCard(
    id: 'shared-hm',
    attack: CombatLane.high,
    defense: CombatLane.middle,
    swapLane: CombatLane.low,
    isSpecial: false,
    title: 'Rising Split',
  ),
  CombatCard(
    id: 'shared-hl',
    attack: CombatLane.high,
    defense: CombatLane.low,
    swapLane: CombatLane.middle,
    isSpecial: false,
    title: 'Sky Hook',
  ),
  CombatCard(
    id: 'shared-mh',
    attack: CombatLane.middle,
    defense: CombatLane.high,
    swapLane: CombatLane.low,
    isSpecial: false,
    title: 'Center Break',
  ),
  CombatCard(
    id: 'shared-mm',
    attack: CombatLane.middle,
    defense: CombatLane.middle,
    swapLane: CombatLane.high,
    isSpecial: false,
    title: 'Mirror Gate',
  ),
  CombatCard(
    id: 'shared-ml',
    attack: CombatLane.middle,
    defense: CombatLane.low,
    swapLane: CombatLane.high,
    isSpecial: false,
    title: 'Cross Step',
  ),
  CombatCard(
    id: 'shared-lh',
    attack: CombatLane.low,
    defense: CombatLane.high,
    swapLane: CombatLane.middle,
    isSpecial: false,
    title: 'Shin Sweep',
  ),
  CombatCard(
    id: 'shared-lm',
    attack: CombatLane.low,
    defense: CombatLane.middle,
    swapLane: CombatLane.high,
    isSpecial: false,
    title: 'River Cut',
  ),
  CombatCard(
    id: 'shared-ll',
    attack: CombatLane.low,
    defense: CombatLane.low,
    swapLane: CombatLane.middle,
    isSpecial: false,
    title: 'Rooted Hook',
  ),
];

const Map<String, List<CombatCard>> combatDeckLibrary =
    <String, List<CombatCard>>{
      'Leap-Creek': <CombatCard>[
        ...baseCombatDeckCards,
        CombatCard(
          id: 'special-mm-leap-creek',
          attack: CombatLane.middle,
          defense: CombatLane.middle,
          swapLane: CombatLane.low,
          isSpecial: true,
          title: 'Hidden Whirlpool',
        ),
      ],
      'Fangmarsh': <CombatCard>[
        ...baseCombatDeckCards,
        CombatCard(
          id: 'special-mm-fangmarsh',
          attack: CombatLane.middle,
          defense: CombatLane.middle,
          swapLane: CombatLane.low,
          isSpecial: true,
          title: 'Billowing Rush',
        ),
      ],
      'Blackstone': <CombatCard>[
        ...baseCombatDeckCards,
        CombatCard(
          id: 'special-mm-blackstone',
          attack: CombatLane.middle,
          defense: CombatLane.middle,
          swapLane: CombatLane.low,
          isSpecial: true,
          title: 'Tempered Veil',
        ),
      ],
      'Underclaw': <CombatCard>[
        ...baseCombatDeckCards,
        CombatCard(
          id: 'special-mm-underclaw',
          attack: CombatLane.middle,
          defense: CombatLane.middle,
          swapLane: CombatLane.low,
          isSpecial: true,
          title: 'Smothering Soil',
        ),
      ],
      'Pouch': <CombatCard>[
        ...baseCombatDeckCards,
        CombatCard(
          id: 'special-mm-pouch',
          attack: CombatLane.middle,
          defense: CombatLane.middle,
          swapLane: CombatLane.low,
          isSpecial: true,
          title: 'Splintered Step',
        ),
      ],
    };
