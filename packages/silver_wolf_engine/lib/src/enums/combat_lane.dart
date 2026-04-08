enum CombatLane {
  high,
  middle,
  low;

  String get label => switch (this) {
    CombatLane.high => 'High',
    CombatLane.middle => 'Middle',
    CombatLane.low => 'Low',
  };
}
