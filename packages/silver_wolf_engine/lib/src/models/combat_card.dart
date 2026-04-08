import 'package:silver_wolf_engine/src/enums/combat_lane.dart';

class CombatCard {
  const CombatCard({
    required this.id,
    required this.attack,
    required this.defense,
    required this.swapLane,
    required this.isSpecial,
    required this.title,
  });

  final String id;
  final CombatLane attack;
  final CombatLane defense;
  final CombatLane swapLane;
  final bool isSpecial;
  final String title;
}
