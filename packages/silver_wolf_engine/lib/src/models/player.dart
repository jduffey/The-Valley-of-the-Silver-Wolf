import 'package:silver_wolf_engine/src/models/technique_counts.dart';

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
    required this.power,
    required this.stamina,
    required this.agility,
    required this.chi,
    required this.wit,
    required this.reputation,
    required this.techniques,
    required this.hitPoints,
    required this.formPoints,
    required this.bonusActionsNextTurn,
    required this.injured,
    required this.arrivalOrder,
    required this.alive,
  });

  final String id;
  final String name;
  final String color;
  final int position;
  final int power;
  final int stamina;
  final int agility;
  final int chi;
  final int wit;
  final int reputation;
  final TechniqueCounts techniques;
  final int hitPoints;
  final int formPoints;
  final int bonusActionsNextTurn;
  final bool injured;
  final int arrivalOrder;
  final bool alive;

  int get totalStats => power + stamina + agility + chi + wit;

  Player copyWith({
    String? id,
    String? name,
    String? color,
    int? position,
    int? power,
    int? stamina,
    int? agility,
    int? chi,
    int? wit,
    int? reputation,
    TechniqueCounts? techniques,
    int? hitPoints,
    int? formPoints,
    int? bonusActionsNextTurn,
    bool? injured,
    int? arrivalOrder,
    bool? alive,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
      power: power ?? this.power,
      stamina: stamina ?? this.stamina,
      agility: agility ?? this.agility,
      chi: chi ?? this.chi,
      wit: wit ?? this.wit,
      reputation: reputation ?? this.reputation,
      techniques: techniques ?? this.techniques,
      hitPoints: hitPoints ?? this.hitPoints,
      formPoints: formPoints ?? this.formPoints,
      bonusActionsNextTurn: bonusActionsNextTurn ?? this.bonusActionsNextTurn,
      injured: injured ?? this.injured,
      arrivalOrder: arrivalOrder ?? this.arrivalOrder,
      alive: alive ?? this.alive,
    );
  }
}
